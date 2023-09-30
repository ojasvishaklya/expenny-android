import 'package:flutter/material.dart';
import 'package:journal/models/Filter.dart';
import 'package:journal/service/DateService.dart';

import '../models/TransactionTag.dart';

class FilterSelectorWidget extends StatefulWidget {
  Function(Filter filter) getSelectedPeriodTransactions;

  FilterSelectorWidget({Key? key, required this.getSelectedPeriodTransactions})
      : super(key: key);

  @override
  State<FilterSelectorWidget> createState() => _FilterSelectorWidgetState();
}

class _FilterSelectorWidgetState extends State<FilterSelectorWidget> {
  final Filter _filter = Filter.defaults();
  int selectedTimeFrame = 1;

  void updateSelectedTimeFrame(index) {
    setState(() {
      selectedTimeFrame = index;
      _filter.endDate = DateTime.now();
      if (selectedTimeFrame == 0) {
        _filter.startDate = _filter.endDate.subtract(Duration(days: 7));
      } else if (selectedTimeFrame == 1) {
        _filter.startDate = _filter.endDate.subtract(Duration(days: 30));
      } else if (selectedTimeFrame == 2) {
        _filter.startDate = _filter.endDate.subtract(Duration(days: 90));
      }
    });
  }

  updateStartDate(DateTime date) => setState(() {
        _filter.startDate = date;
      });

  updateEndDate(DateTime date) => setState(() {
        _filter.endDate = date;
      });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            buildDateRangeDropDown(),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'from ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                buildDateText(_filter.startDate, updateStartDate),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'till ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                buildDateText(_filter.endDate, updateEndDate),
              ],
            ),
            SizedBox(height: 20),
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

  Widget buildDateText(DateTime date, Function(DateTime date) updateStartDate) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            updateStartDate(pickedDate);
          }
        },
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).hoverColor, // Background color
            borderRadius: BorderRadius.circular(10), // Border radius
          ),
          child: Center(
            child: Text(
              DateService.humanReadableDate(date),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateRangeDropDown() {
    List<String> datePresets = ['Past 1 week', 'Past 1 month', 'Past 3 months'];
    String selectedOption = datePresets[selectedTimeFrame];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: selectedOption,
        onChanged: (newValue) {
          updateSelectedTimeFrame(datePresets.indexOf(newValue!));
        },
        items: datePresets.map<DropdownMenuItem<String>>(
          (String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          },
        ).toList(),
        isExpanded: true,
        underline: Container(), // Remove the underline
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
