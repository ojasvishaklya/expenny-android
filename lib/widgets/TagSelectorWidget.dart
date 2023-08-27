import 'package:flutter/material.dart';
import 'package:journal/models/TransactionTag.dart';

class TagSelectorWidget extends StatefulWidget {
  final void Function(String) updateTransactionTag;

  TagSelectorWidget({Key? key, required this.updateTransactionTag})
      : super(key: key);

  @override
  State<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends State<TagSelectorWidget> {
  String selectedTagId = 'miscellaneous';
  String longPressedTag = 'Miscellaneous';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
          child: Text(
            longPressedTag,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Wrap(
          spacing: 8.0, // Spacing between icons
          children: TransactionTag.tags.map((tag) {
            final id = tag.id;
            final icon = tag.icon;

            final isSelected = id == selectedTagId;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (!isSelected) {
                    selectedTagId = id;
                    longPressedTag = tag.name;
                  }
                  widget.updateTransactionTag(selectedTagId);
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColorLight
                        : Colors.transparent, // Border color
                    width: 2, // Border width
                  ),
                  // Set the background color here
                  borderRadius:
                      BorderRadius.circular(30.0), // Optional: Add border radius
                ),
                child: Icon(
                  icon,
                  // size: 26,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
