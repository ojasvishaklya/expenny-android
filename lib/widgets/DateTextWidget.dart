import 'package:flutter/material.dart';

import '../service/DateService.dart';


Widget buildDateText(BuildContext context,DateTime date, Function(DateTime date) updateStartDate) {
  return GestureDetector(
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
  );
}