import 'package:journal/models/Transaction.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class TransactionRepository {
  late sqflite.Database _database;
  final String tableName = 'transactions';

  Future<void> open() async {
    _database = await sqflite.openDatabase(
      join(await sqflite.getDatabasesPath(), tableName + '.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            amount REAL,
            isExpense INTEGER,
            isStarred INTEGER,
            description TEXT,
            tag TEXT,
            paymentMethod TEXT
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertTransaction(Transaction transaction) async {
    await _database.insert(
      tableName,
      transaction.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final List<Map<String, dynamic>> maps =
        await _database.query(tableName);
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
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

  Future<void> close() async {
    await _database.close();
  }
}
