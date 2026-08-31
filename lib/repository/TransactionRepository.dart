import 'package:expenny/models/Transaction.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:expenny/models/TransactionTag.dart';

class TransactionRepository {
  late sqflite.Database _database;
  final String tableName = 'transactions';

  /// Bumped to 2 for the tag-taxonomy refresh: [_migrateTagIds] rewrites
  /// retired tag ids to their current equivalents so historical rows group and
  /// display under the new categories.
  static const int _databaseVersion = 2;

  Future<void> open() async {
    _database = await sqflite.openDatabase(
      join(await sqflite.getDatabasesPath(), tableName + '.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            amount REAL,
            isExpense INTEGER,
            isStarred INTEGER,
            description TEXT,
            tag TEXT,
            paymentMethod TEXT,
            smsId TEXT,
            source TEXT DEFAULT 'manual',
            bank TEXT,
            rawSms TEXT
          )
          ''',
        );
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_sms_id ON $tableName(smsId)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateTagIds(db);
        }
      },
      version: _databaseVersion,
    );
  }

  /// Normalizes stored tag ids to the refreshed taxonomy.
  ///
  /// Uses the single source of truth, [TransactionTag.aliases], so this stays
  /// in step with the display-time resolution in [TransactionTag.getTagById].
  /// Idempotent: rows already carrying a current id match no alias key and are
  /// left untouched, so re-running is a no-op.
  Future<void> _migrateTagIds(sqflite.Database db) async {
    final batch = db.batch();
    TransactionTag.aliases.forEach((oldId, newId) {
      batch.update(
        tableName,
        {'tag': newId},
        where: 'tag = ?',
        whereArgs: [oldId],
      );
    });
    await batch.commit(noResult: true);
  }

  Future<int> insertTransaction(Transaction transaction) async {
    return await _database.insert(
      tableName,
      transaction.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final List<Map<String, dynamic>> maps = await _database.query(tableName);
    var transactionList = List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
    transactionList.sort((a, b) => b.date.compareTo(a.date));
    return transactionList;
  }

  Future<List<Transaction>> getTransactionsRawQuery(String sql,
      [List<Object?>? arguments]) async {
    sql = sql.replaceAll('tableName', tableName);
    final transactions = await _database.rawQuery(sql, arguments);
    var transactionList =
        transactions.map((map) => Transaction.fromMap(map)).toList();
    transactionList.sort((a, b) => b.date.compareTo(a.date));
    return transactionList;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _database.update(
      tableName,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    await _database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTransactions() async {
    await _database.delete(tableName);
  }

  Future<Set<String>> getExistingSmsIds() async {
    final results = await _database.query(
      tableName,
      columns: ['smsId'],
      where: 'smsId IS NOT NULL',
    );
    return results.map((row) => row['smsId'] as String).toSet();
  }

  Future<void> batchInsertTransactions(List<Transaction> transactions) async {
    final batch = _database.batch();
    for (final txn in transactions) {
      batch.insert(
        tableName,
        txn.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _database.close();
  }
}
