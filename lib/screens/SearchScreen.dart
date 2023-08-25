import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';

  void onSearchSubmitted(String query) {
    // Here you can implement your search logic based on the query
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Transactions',
            style: textTheme.headlineLarge,
          ),
          SizedBox(height: 30.0),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: const [
                BoxShadow(
                    // color: Colors.grey.withOpacity(0.3),
                    // spreadRadius: 2,
                    // blurRadius: 5,
                    // offset: Offset(0, 3),
                    ),
              ],
            ),
            child: TextField(
              onSubmitted: onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none, // Hide the default border
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: 1, // Replace with actual item count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(searchQuery),
                  // Add more content or actions for each search result
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
