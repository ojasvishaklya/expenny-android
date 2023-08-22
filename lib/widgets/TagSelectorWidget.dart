import 'package:flutter/material.dart';
import 'package:journal/models/TransactionTag.dart';

class TagSelectorWidget extends StatefulWidget {
  final void Function(Set<String>) updateTransactionTags;

  TagSelectorWidget({Key? key, required this.updateTransactionTags}) : super(key: key);

  @override
  State<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends State<TagSelectorWidget> {

  Set<String> selectedTagIds = <String>{};
  String longPressedTag='';

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Visibility(
          visible: longPressedTag.isNotEmpty,
          child: Center(child: Text(longPressedTag)),
        ),
        Wrap(
          spacing: 8.0, // Spacing between icons
          children: TransactionTag.tags.map((tag) {
            final id = tag.id;
            final icon = tag.icon;

            final isSelected = selectedTagIds.contains(id);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedTagIds.remove(id);
                  } else {
                    selectedTagIds.add(id);
                  }
                  widget.updateTransactionTags(selectedTagIds);
                });
              },
              onLongPress: (){
                setState(() {
                  longPressedTag=tag.name;
                });


                // hide the name after 2sec
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    longPressedTag = '';
                  });
                });

              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.all( 6),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Theme.of(context).cardColor : Colors.transparent,
                  // Set the background color here
                  borderRadius:
                      BorderRadius.circular(5.0), // Optional: Add border radius
                ),
                child: Icon(
                  icon,
                  size: 26,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
