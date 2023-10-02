import '../service/DateService.dart';
import 'TransactionTag.dart';

class Filter {
  Set<TransactionTag> tagSet;
  String? searchString;
  int month;
  int year;

  Filter({
    required this.month,
    required this.year,
    required this.tagSet,
    this.searchString,
  });

  Filter.defaults()
      : month = DateTime.now().month,
        year = DateTime.now().year,
        tagSet = {},
        searchString = '';

  String getMonthName() {
    return DateService.monthNames[month]!;
  }

  Filter copyWith({
    Set<TransactionTag>? tagSet,
    String? searchString,
    int? month,
    int? year,
  }) {
    return Filter(
      month: month ?? this.month,
      year: year ?? this.year,
      tagSet: tagSet ?? this.tagSet,
      searchString: searchString ?? this.searchString,
    );
  }

  @override
  String toString() {
    return 'Filter: {'
        'year: $year, '
        'month: $getMonthName(), '
        'tagSet: $tagSet, '
        'searchString: $searchString'
        '}';
  }
}