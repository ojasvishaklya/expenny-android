import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/Transaction.dart';

Transaction smsTxn() => Transaction(
      id: 7,
      date: DateTime(2026, 10, 4, 11, 30),
      amount: -860,
      description: 'LITTLE ITALY',
      isExpense: true,
      isStarred: false,
      tag: 'food',
      paymentMethod: 'Card/UPI',
      smsId: 'sms-1',
      source: 'sms',
      bank: 'HDFC Bank',
      rawSms: 'Spent Rs.860.00 At LITTLE ITALY',
    );

void main() {
  group('Transaction.status', () {
    test('defaults to active', () {
      expect(smsTxn().status, Transaction.statusActive);
      expect(Transaction.defaults().status, Transaction.statusActive);
    });

    test('round-trips through the database map', () {
      final tombstone = smsTxn()..status = Transaction.statusDeleted;
      final map = tombstone.toMap();

      expect(map['status'], Transaction.statusDeleted);
      expect(Transaction.fromMap(map).status, Transaction.statusDeleted);
    });

    test('round-trips through JSON', () {
      // The JSON path is what a future export/import builds on, so a tombstone
      // has to survive it — otherwise a restore would resurrect deleted rows.
      final tombstone = smsTxn()..status = Transaction.statusDeleted;
      final json = tombstone.toJson();

      expect(json['status'], Transaction.statusDeleted);
      expect(Transaction.fromJson(json).status, Transaction.statusDeleted);
    });

    test('carries the identity fields a tombstone needs', () {
      // smsId is the dedup key; without it a tombstone cannot suppress
      // anything, through the database or through a restore.
      final restored = Transaction.fromJson(
        (smsTxn()..status = Transaction.statusDeleted).toJson(),
      );

      expect(restored.smsId, 'sms-1');
      expect(restored.source, 'sms');
      expect(restored.status, Transaction.statusDeleted);
    });
  });
}
