import 'package:flutter/material.dart';
import 'package:journal/models/Transaction.dart';
import 'package:journal/models/TransactionTag.dart';

class TagSelectorWidget extends StatefulWidget {
  final void Function(String) updateTransactionTag;
  final Transaction transaction;

  TagSelectorWidget(
      {Key? key, required this.updateTransactionTag, required this.transaction})
      : super(key: key);

  @override
  State<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends State<TagSelectorWidget> {
  late String selectedTagId;

  late TransactionTag selectedTag;

  @override
  Widget build(BuildContext context) {
    selectedTagId = widget.transaction.tag;
    selectedTag = TransactionTag.getTagById(selectedTagId);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                'Transaction Tag: ',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Container(
                decoration: BoxDecoration(
                  color: selectedTag.color,
                  borderRadius:
                      BorderRadius.circular(20.0), // Set the BorderRadius
                ),
                padding: EdgeInsets.all(8),
                child: Text(
                   selectedTag.name,
                  style: TextStyle(
                    color: Colors.white,

                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10.0, // Spacing between icons
          children: TransactionTag.tags.map((tag) {
            final id = tag.id;
            final icon = tag.icon;

            final isSelected = id == selectedTagId;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (!isSelected) {
                    selectedTagId = id;
                    selectedTag = tag;
                  }
                  widget.updateTransactionTag(selectedTagId);
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: EdgeInsets.all( 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent, // Border color
                    width: 2, // Border width
                  ),
                  // Set the background color here
                  borderRadius: BorderRadius.circular(
                      100.0), // Optional: Add border radius
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
