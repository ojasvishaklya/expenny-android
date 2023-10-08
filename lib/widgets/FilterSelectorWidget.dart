import 'package:flutter/material.dart';
import 'package:expenny/models/Filter.dart';

import '../models/TransactionTag.dart';
import 'DateTextWidget.dart';

class FilterSelectorWidget extends StatefulWidget {
  Function(Filter filter) getSelectedPeriodTransactions;
  Filter filter;

  FilterSelectorWidget(
      {Key? key,
      required this.getSelectedPeriodTransactions,
      required this.filter})
      : super(key: key);

  @override
  State<FilterSelectorWidget> createState() => _FilterSelectorWidgetState();
}

class _FilterSelectorWidgetState extends State<FilterSelectorWidget> {
  late Filter _filter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _filter = widget.filter;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Select timeframe',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _filter.year--; // Decrement year when left arrow is tapped
                    });
                  },
                  child: Icon(Icons.arrow_left), // Left arrow icon
                ),
                Container(
                  width: 200,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(_filter.year.toString())),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _filter.year++; // Increment year when right arrow is tapped
                    });
                  },
                  child: Icon(Icons.arrow_right), // Right arrow icon
                ),
              ],
            ),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if(_filter.month==1){
                        _filter.month=12;
                      }else {
                        _filter.month--; // Decrement year when left arrow is tapped
                      }
                    });
                  },
                  child: Icon(Icons.arrow_left), // Left arrow icon
                ),
                Container(
                  width: 200,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor, // Background color
                    borderRadius:
                    BorderRadius.circular(10), // Border radius
                  ),
                  child: Center(child: Text(_filter.getMonthName())),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if(_filter.month==12){
                        _filter.month=1;
                      }else {
                        _filter.month++;
                      }
                    });
                  },
                  child: Icon(Icons.arrow_right), // Right arrow icon
                ),
              ],
            ),


            SizedBox(height: 40),
            Text(
              'Select tags',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(
              height: 10,
            ),
            buildTagSelectorWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.getSelectedPeriodTransactions(_filter);
                    Navigator.pop(context);
                  },
                  child: Text('Submit'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildTagSelectorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Wrap(
          spacing: 5.0, // Spacing between icons
          children: TransactionTag.tags.map((tag) {
            final icon = tag.icon;

            final isSelected = _filter.tagSet.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (!isSelected) {
                    _filter.tagSet.add(tag);
                  } else {
                    _filter.tagSet.remove(tag);
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent, // Border color
                    width: 2, // Border width
                  ),
                  // Set the background color here
                  borderRadius: BorderRadius.circular(
                      100.0), // Optional: Add border radius
                ),
                child: Icon(
                  icon,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
