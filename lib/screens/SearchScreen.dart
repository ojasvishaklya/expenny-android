import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/models/Transaction.dart';

import '../controllers/TransactionController.dart';
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

  void _performSearch() async {
    String searchString = _searchController.text;
    _searchResults = await _controller.searchTransaction(searchString);
    print(_searchResults);
    print(searchString);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeaderWidget(text: 'Search Transactions'),
          buildSearchBar(context),
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
          _performSearch();
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
            onPressed: _performSearch,
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
