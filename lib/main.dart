import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/models/models.dart';
import 'assets/styles/styles.dart';
import 'package:OrderClerk/bloc/category_table_bloc/categories_table_bloc.dart';
import 'package:OrderClerk/bloc/order_table_bloc/view_orders_bloc.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/bloc/bloc.dart';
import 'package:OrderClerk/screens/home.dart';
import 'package:OrderClerk/src/file_handling.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'bloc/order_table_bloc/make_orders_bloc.dart';
import 'package:desktop_window/desktop_window.dart';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

Future main() async {
  Mappable.factories = {
    Distributor: () => Distributor(),
    //Distributor: (id,name,address,email,telephone) => Distributor(id: id,name: name,address: address,email: email,telephone: telephone),
    /* Item: (id,name,distributorID,costPrice,sellingPrice,categoryID,formulaID,lastOrderMadeID,lastOrderReceivedID,toBeOrdered) 
    => Item(id: id,name: name,distributorID: distributorID,costPrice: costPrice,sellingPrice: sellingPrice,categoryID: categoryID,formulaID: formulaID,lastOrderMadeID: lastOrderMadeID,lastOrderReceivedID: lastOrderReceivedID), */
    Item: () => Item(),
    Order: () => Order.empty(),
    Formula: (expString, id, vari) =>
        Formula(expString: expString, id: id, vari: vari),
    Category: () => Category(),
  };
  final defaultConfig = {
    "columns": [
      {
        "id": true,
        "name": true,
        "distributorID": false,
        "distributorName": true,
        "packageSize": true,
        "costPrice": true,
        "sellingPrice": true,
        "categoryID": false,
        "categoryName": true,
        "formulaID": false,
        "formulaVari": false,
        "formulaExpression": false,
        "lastOrderMadeID": false,
        "lastOrderMadeDateOrdered": false,
        "lastOrderMadeDateReceived": false,
        "lastOrderMadeDateCancelled": false,
        "lastOrderReceivedID": false,
        "lastOrderReceivedDateOrdered": false,
        "lastOrderReceivedDateReceived": false,
        "lastOrderReceivedExpirationDate": false,
        "lastOrderReceivedDateCancelled": false,
        "toBeOrdered": true,
      }
    ],
    "darkMode": false,
    "accentColor": {"red": 0, "green": 0, "blue": 0},
    "companyLogoPath": ""
  };
  //create necessary files in directory
  FileHandler.createFile(fileName: "config.json", content: defaultConfig);

  ItemFilter.columns =
      json.decode(await FileHandler.configFile.readAsString())["columns"];
  var tempAccent =
      json.decode(await FileHandler.configFile.readAsString())["accentColor"];
  Settings.accentColor = Color.fromRGBO(
      tempAccent["red"], tempAccent["green"], tempAccent["blue"], 1);
  Settings.companyLogoPath = json
      .decode(await FileHandler.configFile.readAsString())["companyLogoPath"];
  Settings.darkMode =
      json.decode(await FileHandler.configFile.readAsString())["darkMode"];
  runApp(MyApp());
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
    //sets minimum size

    await DesktopWindow.setMinWindowSize(Size(832, 450));
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  //Global Keys for Bloc Providers
  GlobalKey<ScaffoldState> _navbarBloc = new GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> _itemTableBloc = new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _distributorTableBloc =
      new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _viewOrdersBloc = new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _makeOrdersBloc = new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _categoryTableBloc = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OrderClerk",
      theme: AppTheme.myTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            key: _navbarBloc,
            create: (context) => NavbarBloc(ViewItemState()),
          ),
          BlocProvider(
            key: _itemTableBloc,
            create: (context) => ItemsTableBloc(source: ItemsSource()),
          ),
          BlocProvider(
            key: _distributorTableBloc,
            create: (context) =>
                DistributorsTableBloc(source: DistributorsSource()),
          ),
          BlocProvider(
            key: _viewOrdersBloc,
            create: (context) => ViewOrdersBloc(source: OrdersSource()),
          ),
          BlocProvider(
            key: _makeOrdersBloc,
            create: (context) => MakeOrdersBloc(),
          ),
          BlocProvider(
              key: _categoryTableBloc,
              create: (context) =>
                  CategoriesTableBloc(source: CategoriesSource())),
        ],
        child: HomePage(
          refreshCallback: () {
            print("redrawing everything");
            setState(() {});
          },
        ),
      ),
    );
  }
}
