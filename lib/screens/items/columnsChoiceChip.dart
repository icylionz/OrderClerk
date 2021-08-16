import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/models.dart';

class ColumnsChoiceChip extends StatefulWidget {
  final String name;
  final String display;
  final VoidCallback callback;
  const ColumnsChoiceChip(
      {Key? key,
      required this.name,
      required this.display,
      required this.callback})
      : super(key: key);

  @override
  _ColumnsChoiceChipState createState() => _ColumnsChoiceChipState();
}

class _ColumnsChoiceChipState extends State<ColumnsChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return GFButton(
      text: widget.display,
      color: ItemFilter.columns.first[widget.name]
          ? AppTheme.myTheme.accentColor
          : AppTheme.myTheme.primaryColor,
      onPressed: () {
        setState(() {
          ItemFilter.columns.first[widget.name] =
              !ItemFilter.columns.first[widget.name];
          widget.callback();
        });
      },
      elevation: 0,
    );
  }
}
