import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddOrder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddOrder();
  }
}

class _AddOrder extends State<AddOrder> {
  GlobalKey<ScaffoldState> _addOrderScaffold = new GlobalKey<ScaffoldState>();
  FToast fToast = FToast();

  @override
  void initState() {
    loadData();
    super.initState();
    fToast.init(context);
  }

  _showToast(
      {Widget? child,
      Color? backgroundColor: Colors.green,
      ToastGravity? position: ToastGravity.TOP,
      int? duration: 2}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: child ?? Container(),
    );

    fToast.showToast(
      child: toast,
      gravity: position,
      toastDuration: Duration(seconds: duration!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _addOrderScaffold,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: new BoxDecoration(color: Colors.transparent),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  loadData() async {
    OrdersSource.data = await OrdersSource.pullData();
    CategoriesSource.data = await CategoriesSource.pullData();
    FormulaeSource.data = await FormulaeSource.pullData();
  }

  insertOrder(Map<String, dynamic> row) async {
    try {
      await DatabaseHelper.instance.insert(row, "items").then((value) {
        _showToast(
          child: Text("Order Inserted: $value"),
          backgroundColor: Colors.green,
          position: ToastGravity.TOP,
        );
      });
    } catch (e) {
      throw e;
    }
  }
}
