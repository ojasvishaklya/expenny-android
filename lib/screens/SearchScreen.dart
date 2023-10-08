import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expenny/models/Filter.dart';
import 'package:expenny/models/Transaction.dart';

import '../controllers/TransactionController.dart';
import '../widgets/FetchMoreButtonWidget.dart';
import '../widgets/FilterSelectorWidget.dart';
import '../widgets/PopupWidget.dart';
import '../widgets/ScreenHeaderWidget.dart';
import '../widgets/TransactionCard.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Transaction> _searchResults = [];
  final _controller = Get.find<TransactionController>();
  final Filter filter = Filter.defaults();

  void _performSearch(Filter filter) async {
    print(filter);
    _searchResults = await _controller.getTransactionsBetweenDates(
        startDate: DateTime(filter.year, filter.month, 1),
        endDate: DateTime(filter.year, filter.month + 1, 0),
        tagSet: filter.tagSet,
        searchString: _searchController.text);
    if (_searchResults.isEmpty) {
      showSnackBar(
          context: context,
          textContent:
              'No transactions match the search criterion for ${filter.getMonthName()} ${filter.year}',
          color: Colors.orange,
          duration: 5);
    }
    setState(() {});
  }

  void _performSearchAllTime() async {
    _searchResults = await _controller.getTransactionsBetweenDates(
        startDate: DateTime(1),
        endDate: DateTime.now(),
        tagSet: filter.tagSet,
        searchString: _searchController.text);
    if (_searchResults.isEmpty) {
      showSnackBar(
          context: context,
          textContent:
              'No transactions match the search criterion for ${filter.getMonthName()} ${filter.year}',
          color: Colors.orange,
          duration: 5);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScreenHeaderWidget(text: 'Search Transactions'),
              Spacer(),
              IconButton(
                  onPressed: () {
                    showAlertContent(
                      context: context,
                      content: FilterSelectorWidget(
                        getSelectedPeriodTransactions: _performSearch,
                        filter: filter,
                      ),
                    );
                  },
                  icon: Icon(Icons.tune)),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          buildSearchBar(context),
          _searchResults.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'leave the search string blank to get all the transactions of selected period ${filter.getMonthName()} ${filter.year}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign
                        .center, // Optional: Center the text within the Text widget
                  ),
                )
              : buildFetchMoreButton(context: context,text: 'Search All time', onTap: _performSearchAllTime),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return TransactionCard(transaction: _searchResults[index]);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget buildSearchBar(BuildContext context) {
    return TextField(
        onSubmitted: (_) {
          _performSearch(filter);
        },
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: _searchResults.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _searchResults = [];
                    });
                  },
                )
              : null,
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _performSearch(filter);
            },
          ),
          filled: true,
          fillColor: Theme.of(context).hoverColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ));
  }
}
