import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class ConfirmationWidget extends StatefulWidget {
  void Function() confirmFunction;
  void Function() cancelFunction;
  Widget textDialog;
  Color? backgroundColor;
  ConfirmationWidget(
      {Key? key,
      required this.confirmFunction,
      required this.cancelFunction,
      this.textDialog: const Text("Are you want to carry out this action?"),
      this.backgroundColor})
      : super(key: key);

  @override
  _ConfirmationWidgetState createState() => _ConfirmationWidgetState();
}

class _ConfirmationWidgetState extends State<ConfirmationWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.textDialog,
          Center(
            child: ButtonBar(
              children: [
                //yes button
                GFButton(
                  onPressed: widget.confirmFunction,
                  child: Text("Yes"),
                ),
                //no button
                GFButton(
                  onPressed: widget.cancelFunction,
                  child: Text("No"),
                  color: Colors.red,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
