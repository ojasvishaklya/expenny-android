import 'package:get_storage/get_storage.dart';

import '../controllers/TransactionController.dart';
import '../models/ParseResult.dart';
import '../models/PaymentMethod.dart';
import '../models/SmsRecord.dart';
import '../models/SyncResult.dart';
import '../models/Transaction.dart';
import '../repository/TransactionRepository.dart';
import 'SmsParserService.dart';
import 'SmsReaderService.dart';

/// Orchestrates the full SMS import pipeline:
/// read → keyword filter → parse → dedup → insert → refresh UI.
class SmsSyncService {
  final SmsReaderService _smsReader;
  final SmsParserService _smsParser;
  final TransactionRepository _repository;
  final TransactionController _controller;

  /// Re-read window applied to [lastSyncedAt] so messages arriving between the
  /// inbox read and the timestamp write are not skipped permanently.
  /// Overlap is free — smsId dedup filters anything already imported.
  static const _syncOverlapBuffer = Duration(days: 1);

  SmsSyncService({
    required SmsReaderService smsReader,
    required SmsParserService smsParser,
    required TransactionRepository repository,
    required TransactionController controller,
  })  : _smsReader = smsReader,
        _smsParser = smsParser,
        _repository = repository,
        _controller = controller;

  /// Full sync with permission request (for manual trigger).
  Future<SyncResult> syncFromSms() async {
    final granted = await _smsReader.requestPermission();
    if (!granted) {
      return const SyncResult(error: SyncError.permissionDenied);
    }
    return _executeSyncPipeline();
  }

  /// Silent sync — only runs if permission already granted.
  /// No-op if permission was never granted.
  Future<SyncResult> syncIfPermissionGranted() async {
    final hasPermission = await _smsReader.hasPermission();
    if (!hasPermission) {
      return const SyncResult();
    }
    return _executeSyncPipeline();
  }

  Future<SyncResult> _executeSyncPipeline() async {
    // Read inbox with lastSyncedAt or default 3-month lookback
    final lastSyncedStr = GetStorage().read<String>('lastSyncedAt');
    final since = lastSyncedStr != null
        ? DateTime.parse(lastSyncedStr).subtract(_syncOverlapBuffer)
        : null;

    final allSms = await _smsReader.readInbox(since: since);

    // Parse each SMS — the parser's validity gate rejects non-transaction messages
    final List<_ParsedRecord> parsed = [];
    int unparsedCount = 0;

    for (final sms in allSms) {
      final result = _smsParser.parse(sms.body);
      if (result != null) {
        parsed.add(_ParsedRecord(sms: sms, parsed: result));
      } else {
        unparsedCount++;
      }
    }

    // Dedup against existing SMS IDs
    final existingSmsIds = await _repository.getExistingSmsIds();
    final newRecords = parsed
        .where((r) => !existingSmsIds.contains(r.sms.id))
        .toList();

    final skippedCount = parsed.length - newRecords.length;

    if (newRecords.isEmpty) {
      _storeLastSyncTimestamp();
      return SyncResult(
        imported: 0,
        skippedDuplicate: skippedCount,
        unparsed: unparsedCount,
      );
    }

    // Build Transaction objects
    final transactions = newRecords.map((r) => _buildTransaction(r)).toList();

    // Batch insert
    await _repository.batchInsertTransactions(transactions);

    // Reload transactions from DB (batch insert doesn't return IDs,
    // and the UI needs objects with valid DB ids for editing)
    await _controller.loadCurrentMonthTransactions();

    // Store timestamp
    _storeLastSyncTimestamp();

    return SyncResult(
      imported: transactions.length,
      skippedDuplicate: skippedCount,
      unparsed: unparsedCount,
    );
  }

  Transaction _buildTransaction(_ParsedRecord record) {
    final isExpense = record.parsed.type == 'debit';
    final description = record.parsed.merchant
        ?? record.sms.sender
        ?? 'Bank transaction';

    return Transaction(
      date: record.sms.date,
      amount: isExpense ? -record.parsed.amount : record.parsed.amount,
      description: description,
      isExpense: isExpense,
      isStarred: false,
      tag: 'miscellaneous',
      paymentMethod: PaymentMethod.ONLINE.name,
      smsId: record.sms.id,
      source: 'sms',
      bank: record.sms.sender,
      rawSms: record.sms.body,
    );
  }

  void _storeLastSyncTimestamp() {
    GetStorage().write('lastSyncedAt', DateTime.now().toIso8601String());
  }
}

class _ParsedRecord {
  final SmsRecord sms;
  final ParseResult parsed;

  const _ParsedRecord({required this.sms, required this.parsed});
}
