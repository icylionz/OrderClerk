/* import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_mapper/object_mapper.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/default.dart';
import 'package:OrderClerk/screens/items/items_screen.dart';
import 'package:OrderClerk/screens/distributors/distributors_screen.dart';
import 'package:OrderClerk/screens/nav_bar.dart';
import 'package:OrderClerk/bloc/bloc.dart';
import 'package:OrderClerk/screens/orders/orders_screen.dart';
import 'package:OrderClerk/screens/window_buttons.dart';
import 'package:OrderClerk/src/file_handling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'bloc/distributor_table_bloc copy/distributors_table_bloc.dart';
import 'bloc/order_table_bloc/orders_table_bloc.dart';
import 'models/models.dart';

Future main() async {
  Mappable.factories = {
    Distributor: () => Distributor(),
    //Distributor: (id,name,address,email,telephone) => Distributor(id: id,name: name,address: address,email: email,telephone: telephone),
    /* Item: (id,name,distributorID,costPrice,sellingPrice,categoryID,formulaID,lastOrderMadeID,lastOrderReceivedID,toBeOrdered) 
    => Item(id: id,name: name,distributorID: distributorID,costPrice: costPrice,sellingPrice: sellingPrice,categoryID: categoryID,formulaID: formulaID,lastOrderMadeID: lastOrderMadeID,lastOrderReceivedID: lastOrderReceivedID), */
    Item: () => Item(),
    Order: (id, itemID) => Order(id: id, itemID: itemID),
    Formula: (expString, id, vari) =>
        Formula(expString: expString, id: id, vari: vari),
    Category: () => Category(),
  };
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
  //sets minimum size for

  final defaultItemFilter = {
    "columns": [
      {
        "id": true,
        "name": true,
        "distributorID": false,
        "distributorName": true,
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
        "lastOrderReceivedDateCancelled": false,
        "toBeOrdered": true,
      }
    ]
  };
  //create necessary files in directory
  createFile(
      dir: await getApplicationDocumentsDirectory(),
      fileName: "item_filter.json",
      content: defaultItemFilter);
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
  GlobalKey<ScaffoldState> _itemViewBloc = new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _itemTableBloc = new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _distributorTableBloc =
      new GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _orderTableBloc = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.myTheme,
      initialRoute: "/",
      builder: (context, widget) => ResponsiveWrapper.builder(
          MultiBlocProvider(
            providers: [
              BlocProvider(
                key: _navbarBloc,
                create: (context) => NavbarBloc(BlankState()),
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
                key: _orderTableBloc,
                create: (context) => OrdersTableBloc(source: OrdersSource()),
              ),
            ],
            child: HomePage(),
          ),
          maxWidth: 1200,
          minWidth: 480,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(480, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ],
          background: Container(color: Color(0xFFF5F5F5))),
    );
  }
}

class HomePage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                //Navigation Menu
                Expanded(
                  child: FractionallySizedBox(
                      widthFactor: 1, heightFactor: 0.96, child: NavBar()),
                ),
                //App body
                Flexible(
                  flex: 11,
                  child: FractionallySizedBox(
                      heightFactor: 0.96,
                      widthFactor: 1.0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(30.0, 10.0, 20, 10.0),
                        child: //Displays the selected screen
                            BlocBuilder<NavbarBloc, NavbarState>(
                          builder: (BuildContext context, NavbarState state) {
                            if (state is BlankState) {
                              return Container(
                                child: Text("Empty"),
                              );
                            } else if (state is DefaultState)
                              return DefaultView();
                            else if (state is ViewItemState)
                              return ItemsScreen();
                            else if (state is ViewDistributorState)
                              //TODO: replace with View distributor screen
                              return DistributorsScreen();
                            else if (state is ViewOrderState)
                              //TODO: replace with View order screen
                              return OrdersScreen();
                            else if (state is ViewCategoryState)
                              //TODO: replace with View category screen
                              return DefaultView();
                            else if (state is ViewFormulaState)
                              //TODO: replace with View formula screen
                              return DefaultView();
                            else
                              return Container(
                                child: Text("Empty"),
                              );
                          },
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

/* class _BHomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder);
  }
} */
















import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/bloc/bloc.dart';

class NavBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavBar();
  }
}

class _NavBar extends State<NavBar> {
  final _tileShape = CircleBorder(side: BorderSide(style: BorderStyle.solid));

  final _tileMargin = EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0);
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
          border: Border(
              right: BorderSide(
                  color: Color.fromRGBO(100, 100, 100, 0.5), width: 0.7)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 139) {
              return ListView(
                children: [
                  //TODO: Add appropiate icons to navbar icons
                  _buildBigNavMenuItem(
                      path: "/", tooltip: "Default", icon: Icons.accessibility),
                  _buildBigNavMenuItem(
                      path: "/items", tooltip: "Items", icon: Octicons.package),
                  _buildBigNavMenuItem(
                      path: "/distributors",
                      tooltip: "Distributors",
                      icon: Linecons.truck),
                  _buildBigNavMenuItem(
                      path: "/orders",
                      tooltip: "Orders",
                      icon: ModernPictograms.basket_alt),
                  _buildBigNavMenuItem(
                      path: "/categories",
                      tooltip: "Categories",
                      icon: Linecons.tag),
                  _buildBigNavMenuItem(
                      path: "/formulae",
                      tooltip: "Formulae",
                      icon: Icons.accessibility),
                ],
              );
            }
            if (constraints.maxWidth <= 139) {
              ListView(
                children: [
                  //TODO: Add appropiate icons to navbar icons
                  _buildNavMenuItem(
                      path: "/", tooltip: "Default", icon: Icons.accessibility),
                  _buildNavMenuItem(
                      path: "/items", tooltip: "Items", icon: Octicons.package),
                  _buildNavMenuItem(
                      path: "/distributors",
                      tooltip: "Distributors",
                      icon: Linecons.truck),
                  _buildNavMenuItem(
                      path: "/orders",
                      tooltip: "Orders",
                      icon: ModernPictograms.basket_alt),
                  _buildNavMenuItem(
                      path: "/categories",
                      tooltip: "Categories",
                      icon: Linecons.tag),
                  _buildNavMenuItem(
                      path: "/formulae",
                      tooltip: "Formulae",
                      icon: Icons.accessibility),
                ],
              );
            }
            return ListView(
              children: [
                //TODO: Add appropiate icons to navbar icons
                _buildNavMenuItem(
                    path: "/", tooltip: "Default", icon: Icons.accessibility),
                _buildNavMenuItem(
                    path: "/items", tooltip: "Items", icon: Octicons.package),
                _buildNavMenuItem(
                    path: "/distributors",
                    tooltip: "Distributors",
                    icon: Linecons.truck),
                _buildNavMenuItem(
                    path: "/orders",
                    tooltip: "Orders",
                    icon: ModernPictograms.basket_alt),
                _buildNavMenuItem(
                    path: "/categories",
                    tooltip: "Categories",
                    icon: Linecons.tag),
                _buildNavMenuItem(
                    path: "/formulae",
                    tooltip: "Formulae",
                    icon: Icons.accessibility),
              ],
            );
          },
        ));
  }

  Widget _buildNavMenuItem(
      {required String path, required String tooltip, required IconData icon}) {
    return Padding(
      padding: _tileMargin,
      child: IconButton(
          icon: Icon(icon),
          tooltip: tooltip,
          onPressed: () => Navigator.of(context).pushNamed(path)),
    );
  }

  Widget _buildBigNavMenuItem(
      {required String path, required String tooltip, required IconData icon}) {
    return Padding(
      padding: _tileMargin,
      child: GFButton(
          textStyle: AppTheme.myTheme.textTheme.headline6,
          icon: Icon(icon),
          text: tooltip,
          onPressed: () {
            Navigator.of(context).popAndPushNamed(path);
          },
          type: GFButtonType.transparent),
    );
  }
}

 */