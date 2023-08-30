import 'package:journal/models/TransactionTag.dart';

class Filter {
  DateTime startDate;
  DateTime endDate;
  Set<TransactionTag> tagSet;
  String? searchString;

  Filter({
    required this.startDate, // older date
    required this.endDate, // newer date
    required this.tagSet,
    this.searchString,
  });

  Filter.defaults()
      : endDate = DateTime.now(),
        startDate = DateTime.now().subtract(Duration(days: 30)),
        tagSet = {},
        searchString = '';

  @override
  String toString() {
    return 'Filter: {'
        'startDate: $startDate, '
        'endDate: $endDate, '
        'tagSet: $tagSet, '
        'searchString: $searchString'
        '}';
  }
}
