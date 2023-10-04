import 'package:flutter/material.dart';

Container buildFetchMoreButton({required BuildContext context, required String text, required Function() onTap}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: 8),
    child: TextButton(
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context)
                .colorScheme
                .onBackground), // Set background color
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(2.0), // Set border radius
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.surface),
      ),
    ),
  );
}
