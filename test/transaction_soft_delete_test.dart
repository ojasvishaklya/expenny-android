import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
// Scoped: sqflite exports its own `Transaction`, which would clash with the
// model type under test.
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

import 'package:expenny/controllers/TransactionController.dart';
import 'package:expenny/models/SmsRecord.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/repository/TransactionRepository.dart';
import 'package:expenny/service/ConfigService.dart';
import 'package:expenny/service/SmsParserService.dart';
import 'package:expenny/service/SmsReaderService.dart';
import 'package:expenny/service/SmsSyncService.dart';

import 'support/dashboard_harness.dart';

/// Regression coverage for deleted transactions reappearing after a restart.
///
/// These tests drive the real [TransactionRepository] against a real SQLite
/// file through `sqflite_common_ffi`. The bug lived in the interaction between
/// the delete statement and the dedup read, so a hand-written fake repository
/// would only assert the fix's own assumptions. A file rather than an
/// in-memory database, because the central claim is that a tombstone survives
/// the process that wrote it.

/// An inbox that never changes, mirroring the real reader's window semantics:
/// a null [since] means the 90-day default lookback.
class _FakeSmsReader implements SmsReaderService {
  _FakeSmsReader(this.inbox);

  final List<SmsRecord> inbox;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<List<SmsRecord>> readInbox({DateTime? since}) async {
    final cutoff = since ?? DateTime.now().subtract(const Duration(days: 90));
    return inbox.where((sms) => !sms.date.isBefore(cutoff)).toList();
  }
}

/// One app launch: a freshly opened repository, its controller, and a sync
/// service over a fixed inbox. Re-launching over the same [dbPath] is how
/// these tests model an app restart.
class _Launch {
  _Launch({
    required this.repository,
    required this.controller,
    required this.sync,
  });

  final TransactionRepository repository;
  final TransactionController controller;
  final SmsSyncService sync;
}

Future<_Launch> _launch(String dbPath, List<SmsRecord> inbox) async {
  final repository = TransactionRepository();
  await repository.open(path: dbPath);
  final controller = TransactionController(repository);
  Get.put<TransactionController>(controller);
  return _Launch(
    repository: repository,
    controller: controller,
    sync: SmsSyncService(
      smsReader: _FakeSmsReader(inbox),
      smsParser: SmsParserService(),
      repository: repository,
      controller: controller,
    ),
  );
}

SmsRecord bankSms({
  required String id,
  required double amount,
  required String merchant,
  DateTime? date,
}) {
  return SmsRecord(
    id: id,
    sender: 'HDFCBK',
    body: 'Rs.${amount.toStringAsFixed(2)} debited from a/c XX1234 '
        'on 04-10-26 to $merchant. Avl Bal Rs.12000.00',
    date: date ?? DateTime.now().subtract(const Duration(hours: 2)),
  );
}

Transaction manualTxn({
  required double amount,
  required String description,
  String tag = 'food',
}) {
  return Transaction(
    date: DateTime.now().subtract(const Duration(hours: 1)),
    amount: -amount.abs(),
    description: description,
    isExpense: true,
    isStarred: false,
    tag: tag,
    paymentMethod: 'Cash',
  );
}

void main() {
  late Directory tempDir;
  late String dbPath;
  late ConfigService config;

  setUpAll(() {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('expenny_soft_delete');
    dbPath = '${tempDir.path}/transactions.db';
    // SmsSyncService reads and writes lastSyncedAt through ConfigService.
    config = await registerConfigService();
    addTearDown(() async {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });
  });

  group('SMS-imported transactions', () {
    test('a deleted transaction is not re-imported after a restart', () async {
      final inbox = [
        bankSms(id: 'sms-1', amount: 860, merchant: 'LITTLEITALY')
      ];

      // First launch: the message imports.
      final first = await _launch(dbPath, inbox);
      final firstResult = await first.sync.syncIfPermissionGranted();
      expect(firstResult.imported, 1, reason: 'inbox message should import');

      // The user deletes it.
      final imported = (await first.repository.getTransactions()).single;
      await first.controller.deleteTransaction(imported);
      expect(await first.repository.getTransactions(), isEmpty);
      await first.repository.close();

      // Restart: a fresh repository over the same file, same inbox. The
      // startup sync window covers the message, so only the tombstone can
      // keep it out. This failed before soft delete — the row was gone, its
      // smsId with it, and the message imported a second time.
      final second = await _launch(dbPath, inbox);
      final secondResult = await second.sync.syncIfPermissionGranted();

      expect(secondResult.imported, 0);
      expect(secondResult.skippedDuplicate, 1);
      expect(await second.repository.getTransactions(), isEmpty);
      await second.repository.close();
    });

    test('the tombstone keeps its smsId for dedup', () async {
      final session = await _launch(
        dbPath,
        [bankSms(id: 'sms-1', amount: 500, merchant: 'CAFE')],
      );
      await session.sync.syncIfPermissionGranted();

      final imported = (await session.repository.getTransactions()).single;
      await session.controller.deleteTransaction(imported);

      // Gone from every read the UI uses, but still visible to dedup.
      expect(await session.repository.getTransactions(), isEmpty);
      expect(await session.repository.getExistingSmsIds(), {'sms-1'});
      await session.repository.close();
    });

    test('deleting marks the passed object so it cannot be saved back active',
        () async {
      final session = await _launch(dbPath, []);
      final txn = manualTxn(amount: 100, description: 'Chai');
      txn.id = await session.repository.insertTransaction(txn);

      await session.controller.deleteTransaction(txn);

      expect(txn.status, Transaction.statusDeleted);
      await session.repository.close();
    });
  });

  group('delete all data', () {
    test('tombstones every row and survives a full 90-day re-sync', () async {
      final inbox = [
        bankSms(id: 'sms-1', amount: 860, merchant: 'LITTLEITALY'),
        bankSms(id: 'sms-2', amount: 240, merchant: 'METROCARD'),
      ];

      final first = await _launch(dbPath, inbox);
      final firstResult = await first.sync.syncIfPermissionGranted();
      expect(firstResult.imported, 2);

      await first.controller.deleteAllTransactions();
      expect(await first.repository.getTransactions(), isEmpty);
      await first.repository.close();

      // DataService.deleteAllTransactions erases GetStorage, which drops
      // lastSyncedAt. Clearing it here reproduces the state the next launch
      // reads: no timestamp, so the reader falls back to its 90-day window and
      // every message is offered to the pipeline again.
      config.setLastSyncedAt(null);

      final second = await _launch(dbPath, inbox);
      final secondResult = await second.sync.syncIfPermissionGranted();

      expect(secondResult.imported, 0);
      expect(secondResult.skippedDuplicate, 2);
      expect(await second.repository.getTransactions(), isEmpty);
      await second.repository.close();
    });

    test('completes the write before the future resolves', () async {
      final session = await _launch(dbPath, []);
      final txn = manualTxn(amount: 100, description: 'Chai');
      await session.repository.insertTransaction(txn);

      // deleteAllTransactions used to be `void async`, so a caller awaiting it
      // was not actually waiting for the delete.
      await session.controller.deleteAllTransactions();

      expect(await session.repository.getTransactions(), isEmpty);
      await session.repository.close();
    });
  });

  group('manual transactions', () {
    test('a deleted transaction stays deleted after a restart', () async {
      final first = await _launch(dbPath, []);
      final keep = manualTxn(amount: 200, description: 'Groceries');
      final remove = manualTxn(amount: 50, description: 'Bus fare');
      keep.id = await first.repository.insertTransaction(keep);
      remove.id = await first.repository.insertTransaction(remove);

      await first.controller.deleteTransaction(remove);
      await first.repository.close();

      final second = await _launch(dbPath, []);
      final survivors = await second.repository.getTransactions();

      expect(survivors.map((t) => t.description), ['Groceries']);
      await second.repository.close();
    });
  });

  group('read gating', () {
    test('deleted rows are excluded from queries, search, and totals',
        () async {
      final session = await _launch(dbPath, []);
      final keep = manualTxn(amount: 200, description: 'Groceries');
      final remove = manualTxn(amount: 50, description: 'Bus fare');
      keep.id = await session.repository.insertTransaction(keep);
      remove.id = await session.repository.insertTransaction(remove);

      await session.controller.deleteTransaction(remove);
      await session.controller.loadCurrentMonthTransactions();

      // getTransactionsRawQuery, via the date-range and search helpers.
      final inRange = await session.controller.getTransactionsBetweenDates(
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        tagSet: null,
      );
      expect(inRange.map((t) => t.description), ['Groceries']);
      expect(await session.controller.searchTransaction('Bus'), isEmpty);

      // Controller totals are derived from the loaded list.
      expect(session.controller.expense, -200);
      expect(session.controller.balance, -200);
      await session.repository.close();
    });

    test('a soft-deleted row is still physically present', () async {
      // The point of the fix: the row is retained, not removed. If this ever
      // fails, deletes have silently gone back to being hard deletes and the
      // dedup key is being destroyed again.
      final session = await _launch(dbPath, []);
      final txn = manualTxn(amount: 75, description: 'Auto');
      txn.id = await session.repository.insertTransaction(txn);

      await session.controller.deleteTransaction(txn);

      // Naming the table directly bypasses the `tableName` token the gated
      // read path substitutes, so this sees tombstones.
      final tombstones = await session.repository.getTransactionsRawQuery(
        "SELECT * FROM transactions WHERE status = '${Transaction.statusDeleted}'",
      );
      expect(tombstones.map((t) => t.description), ['Auto']);

      // The same row is invisible through the gated path.
      final visible = await session.repository.getTransactionsRawQuery(
        'SELECT * FROM tableName',
      );
      expect(visible, isEmpty);
      await session.repository.close();
    });
  });
}
