import 'package:expenny/models/Transaction.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:expenny/models/TransactionTag.dart';

class TransactionRepository {
  late sqflite.Database _database;
  final String tableName = 'transactions';

  /// Bumped to 3 for the soft-delete `status` column.
  ///
  /// There is deliberately **no** v2 → v3 migration: the app is pre-release,
  /// so the column is declared in [open]'s `onCreate` only and an existing v2
  /// database must be cleared rather than upgraded. A v2 database opened at
  /// this version will fail every read with `no such column: status`.
  static const int _databaseVersion = 3;

  /// Opens the database, creating it on first run.
  ///
  /// [path] overrides the on-device location and exists so tests can open a
  /// real SQLite file through an FFI factory; production passes nothing and
  /// resolves the platform databases directory as before.
  Future<void> open({String? path}) async {
    _database = await sqflite.openDatabase(
      path ?? join(await sqflite.getDatabasesPath(), tableName + '.db'),
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
            rawSms TEXT,
            status TEXT NOT NULL DEFAULT '${Transaction.statusActive}'
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
    final List<Map<String, dynamic>> maps = await _database.query(
      tableName,
      where: 'status = ?',
      whereArgs: [Transaction.statusActive],
    );
    var transactionList = List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
    transactionList.sort((a, b) => b.date.compareTo(a.date));
    return transactionList;
  }

  /// Runs a caller-supplied read query against the **active** rows only.
  ///
  /// The `tableName` token resolves to an inline view restricted to
  /// `status = 'active'`, so soft-deleted rows are filtered for every caller
  /// without any of them having to know about [Transaction.status]. Filtering
  /// here rather than appending to the caller's SQL keeps the gate correct for
  /// queries that carry their own trailing clauses (`ORDER BY`, `LIMIT`).
  Future<List<Transaction>> getTransactionsRawQuery(String sql,
      [List<Object?>? arguments]) async {
    sql = sql.replaceAll(
      'tableName',
      "(SELECT * FROM $tableName WHERE status = '${Transaction.statusActive}')",
    );
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

  /// Marks one transaction deleted, leaving the row (and its `smsId`) in place.
  ///
  /// Deliberately not a `DELETE`: removing the row would drop its `smsId`, and
  /// the next startup sync would re-import the same message because
  /// [getExistingSmsIds] would no longer report it.
  Future<void> softDelete(int id) async {
    await _database.update(
      tableName,
      {'status': Transaction.statusDeleted},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marks every transaction deleted. See [softDelete] for why the rows stay.
  Future<void> softDeleteAll() async {
    await _database.update(
      tableName,
      {'status': Transaction.statusDeleted},
    );
  }

  /// Every `smsId` ever imported, **including soft-deleted rows**.
  ///
  /// The missing status filter is load-bearing, not an oversight: this set is
  /// the SMS import dedup key, and a tombstone must keep suppressing its
  /// message. Adding `status = 'active'` here would reintroduce the bug where
  /// a deleted SMS transaction reappears on the next app start.
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
