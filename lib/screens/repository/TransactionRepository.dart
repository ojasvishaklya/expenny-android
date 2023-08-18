import 'package:logger/logger.dart';

class TransactionRepository {
  static final TransactionRepository transactionRepository = TransactionRepository._init();
  final logger = Logger();

  var tableName = 'transactions';

  TransactionRepository._init();

  int balance = 0;

   insertAlarm()  {
    logger.i('saving in sqlite: ');
  }
}
