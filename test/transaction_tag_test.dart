import 'package:flutter_test/flutter_test.dart';
import 'package:expenny/models/TransactionTag.dart';

void main() {
  group('TransactionTag.normalizeTagId', () {
    test('maps every retired id to a live tag id', () {
      const expected = {
        'football_turf': 'entertainment',
        'wifi_bill': 'bills',
        'phone_bill': 'bills',
        'metro_recharge': 'transport',
        'cab': 'transport',
        'loan': 'finance',
        'gym': 'health',
        'gym_supplements': 'health',
        'healthcare': 'health',
        'apparel': 'shopping',
      };
      final liveIds = TransactionTag.tags.map((t) => t.id).toSet();

      expected.forEach((oldId, newId) {
        expect(TransactionTag.normalizeTagId(oldId), newId,
            reason: '$oldId should map to $newId');
        expect(liveIds, contains(newId),
            reason: '$newId must be a live tag id');
      });
    });

    test('passes stable and unknown ids through unchanged', () {
      for (final id in ['food', 'grocery', 'entertainment', 'salary', 'miscellaneous']) {
        expect(TransactionTag.normalizeTagId(id), id);
      }
      expect(TransactionTag.normalizeTagId('some_unknown_id'), 'some_unknown_id');
    });
  });

  group('TransactionTag.getTagById', () {
    test('resolves retired ids to their live tag', () {
      expect(TransactionTag.getTagById('metro_recharge').id, 'transport');
      expect(TransactionTag.getTagById('metro_recharge').name, 'Transport');
      expect(TransactionTag.getTagById('apparel').id, 'shopping');
      expect(TransactionTag.getTagById('healthcare').id, 'health');
      expect(TransactionTag.getTagById('gym_supplements').id, 'health');
      expect(TransactionTag.getTagById('loan').id, 'finance');
      expect(TransactionTag.getTagById('football_turf').id, 'entertainment');
      expect(TransactionTag.getTagById('wifi_bill').id, 'bills');
    });

    test('keeps stable ids and their names', () {
      expect(TransactionTag.getTagById('food').name, 'Food & Drink');
      expect(TransactionTag.getTagById('grocery').name, 'Groceries');
      expect(TransactionTag.getTagById('entertainment').name, 'Entertainment');
      expect(TransactionTag.getTagById('salary').name, 'Salary');
      expect(TransactionTag.getTagById('miscellaneous').name, 'Miscellaneous');
    });

    test('falls back to Unknown for a truly unknown id', () {
      final tag = TransactionTag.getTagById('not_a_real_tag');
      expect(tag.id, 'unknown');
      expect(tag.name, 'Unknown');
    });
  });

  group('TransactionTag.tags', () {
    test('has unique ids and no retired ids present', () {
      final ids = TransactionTag.tags.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'ids must be unique');
      for (final retired in TransactionTag.aliases.keys) {
        expect(ids, isNot(contains(retired)),
            reason: '$retired should have been retired from the live list');
      }
    });
  });

  group('tag id migration mapping (schema v2)', () {
    // The DB migration applies TransactionTag.aliases in a single UPDATE pass.
    // These guarantees make that one pass sufficient and idempotent.
    test('a single normalize pass fully resolves every retired id', () {
      for (final oldId in TransactionTag.aliases.keys) {
        final once = TransactionTag.normalizeTagId(oldId);
        // The result is a live id, and normalizing again is a no-op (no chains).
        expect(TransactionTag.aliases.containsKey(once), isFalse,
            reason: '$oldId -> $once must not itself be an alias key');
        expect(TransactionTag.normalizeTagId(once), once);
      }
    });

    test('normalizing an already-current id is a no-op (idempotent)', () {
      for (final tag in TransactionTag.tags) {
        expect(TransactionTag.normalizeTagId(tag.id), tag.id);
      }
    });
  });
}
