import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/models.dart';

class ColumnsChoiceChip extends StatefulWidget {
  final String name;
  final String display;
  final VoidCallback refreshCallback;
  const ColumnsChoiceChip(
      {Key? key,
      required this.name,
      required this.display,
      required this.refreshCallback})
      : super(key: key);

  @override
  _ColumnsChoiceChipState createState() => _ColumnsChoiceChipState();
}

class _ColumnsChoiceChipState extends State<ColumnsChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return GFButton(
      text: widget.display,
      textStyle: TextStyle(
          color: Theme.of(context).accentColor.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white,
          fontWeight: FontWeight.w600),
      color: ItemFilter.columns.first[widget.name]
          ? AppTheme.myTheme.accentColor
          : Theme.of(context).brightness == Brightness.dark
              ? AppTheme.lighten(AppTheme.myTheme.scaffoldBackgroundColor, 0.3)
              : AppTheme.darken(AppTheme.myTheme.scaffoldBackgroundColor, 0.5),
      onPressed: () {
        setState(() {
          ItemFilter.columns.first[widget.name] =
              !ItemFilter.columns.first[widget.name];
          Settings.saveSettings();
          widget.refreshCallback();
        });
      },
      elevation: 0,
    );
  }
}
