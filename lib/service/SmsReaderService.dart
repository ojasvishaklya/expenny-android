import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/SmsRecord.dart';

/// Abstraction over SMS inbox access.
/// Implementations: real (telephony plugin) and fake (for testing).
abstract class SmsReaderService {
  /// Requests READ_SMS permission. Returns true if granted.
  Future<bool> requestPermission();

  /// Checks if permission was previously granted without prompting.
  Future<bool> hasPermission();

  /// Reads SMS from the inbox since [since]. Returns empty list on failure.
  /// Defaults to 3 months ago if not specified.
  Future<List<SmsRecord>> readInbox({DateTime? since});
}

class TelephonySmsReaderService implements SmsReaderService {
  final Telephony _telephony = Telephony.instance;

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  @override
  Future<bool> hasPermission() async {
    return await Permission.sms.isGranted;
  }

  @override
  Future<List<SmsRecord>> readInbox({DateTime? since}) async {
    try {
      final cutoff = since ?? DateTime.now().subtract(const Duration(days: 90));
      final filter = SmsFilter.where(SmsColumn.DATE)
          .greaterThanOrEqualTo(cutoff.millisecondsSinceEpoch.toString());

      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ID, SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        filter: filter,
      );
      return messages.map((sms) => SmsRecord(
        id: sms.id?.toString() ?? '',
        sender: sms.address,
        body: sms.body ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
      )).toList();
    } catch (e) {
      return [];
    }
  }
}
