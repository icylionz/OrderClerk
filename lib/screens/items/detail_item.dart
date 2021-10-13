import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/screens/confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:OrderClerk/data_sources/items_source.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/items/edit_item.dart';
import 'package:OrderClerk/src/queries.dart';

class DetailItem extends StatefulWidget {
  final int itemID;
  final Function() callback;
  DetailItem({Key? key, required this.itemID, required this.callback})
      : super(key: key);

  @override
  _DetailItemState createState() =>
      _DetailItemState(itemID: this.itemID, callback: this.callback);
}

class _DetailItemState extends State<DetailItem> {
  int itemID;
  Function() callback;
  late Item item;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  bool itemDetailsOverlayVisible = false;
  bool confirmDeleteVisible = false;
  bool editOverlayVisible = false;
  FToast fToast = FToast();

  EdgeInsets _itemDetailPadding = const EdgeInsets.all(8.0);

  _DetailItemState({required this.itemID, required this.callback}) {
    this.item = ItemsSource.extract(id: itemID);
  }
  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
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
    return LayoutBuilder(builder: (context, constraints) {
      return GFFloatingWidget(
        showBlurness: itemDetailsOverlayVisible,
        child: itemDetailsOverlayVisible
            ? Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Stack(alignment: Alignment.center, children: [
                  GestureDetector(
                    onTap: () {
                      resetOverlay();
                    },
                  ),
                  confirmDeleteVisible
                      ? Center(
                          child: Container(
                          height: constraints.maxHeight / 1.5,
                          width: constraints.maxWidth / 1.5,
                          child: ConfirmationWidget(
                            cancelFunction: resetOverlay,
                            confirmFunction: () {
                              if (!isItemUsed(item: item)) {
                                deleteItem(itemID);
                                setState(callback);
                              } else
                                _showToast(
                                    child: Text(
                                        "You cannot delete this item because it has been used to create orders. Editing the item's information is a better solution."),
                                    backgroundColor: Colors.red,
                                    duration: 5);
                              resetOverlay();
                            },
                            backgroundColor:
                                AppTheme.myTheme.scaffoldBackgroundColor,
                            textDialog: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text:
                                      "Are you sure you want to delete Item #$itemID?\n"),
                              TextSpan(
                                text:
                                    "N.B This cannot be undone!",
                                style: TextStyle(color: Colors.red),
                              )
                            ])),
                          ),
                        ))
                      : editOverlayVisible
                          ? SizedBox(
                              height: constraints.maxHeight - 200,
                              width: constraints.maxWidth - 200,
                              child: Container(
                                  color: AppTheme.darken(
                                      AppTheme.myTheme.scaffoldBackgroundColor),
                                  child: Center(
                                    child: EditItem(
                                        item: item,
                                        callback: () {
                                          resetOverlay();
                                        }),
                                  )))
                          : Container()
                ]))
            : Container(),
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
          color: AppTheme.myTheme.scaffoldBackgroundColor,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
              child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //top navigation
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //close btn
                    IconButton(
                        tooltip: "Close",
                        onPressed: callback,
                        icon: Icon(Icons.close)),
                    Text(
                      "Item Details",
                    ),
                    //delete Item
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Set and Unset To be Ordered Button
                        item.toBeOrdered!
                            ? IconButton(
                                hoverColor: Colors.red,
                                color: Colors.green,
                                tooltip: "UnSet To Be Ordered",
                                onPressed: () {
                                  setState(() {
                                    setToBeOrdered(item);
                                  });
                                },
                                icon: Icon(
                                  FontAwesome5.clipboard_check,
                                ),
                              )
                            : IconButton(
                                hoverColor: Colors.green,
                                color: Colors.red,
                                tooltip: "Set To Be Ordered",
                                onPressed: () {
                                  setState(() {
                                    setToBeOrdered(item);
                                  });
                                },
                                icon: Icon(
                                  FontAwesome5.clipboard,
                                ),
                              ),

                        //Edit Item Button
                        IconButton(
                          tooltip: "Edit Item",
                          onPressed: () {
                            setState(() {
                              itemDetailsOverlayVisible = true;
                              editOverlayVisible = true;
                            });
                          },
                          icon: Icon(
                            Icons.edit,
                          ),
                        ),
                        IconButton(
                          tooltip: "Delete Item",
                          onPressed: () {
                            setState(() {
                              itemDetailsOverlayVisible = true;
                              confirmDeleteVisible = true;
                            });
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                //Item Details
                Padding(
                  padding: _itemDetailPadding,
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color),
                        children: [
                          TextSpan(
                            text: "Item ID: ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: "${item.id}",
                          ),
                        ]),
                  ),
                ),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Item Name: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${item.name}",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Distributor: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${item.distributor!.name}",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Category: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${item.category?.name}",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Package Size: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${item.packageSize}",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Cost Price: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "\$${item.costPrice?.toStringAsFixed(2)}",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Selling Price: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text:
                                  "\$${item.sellingPrice?.toStringAsFixed(2)}",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Last Order Made Date: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: item.lastOrderMade?.dateOrdered != null
                                  ? "${DateFormat('yyyy-MM-dd hh:mm:ss').format(item.lastOrderMade!.dateOrdered!)}"
                                  : "null",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Last Order Received Date: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: item.lastOrderReceived?.dateReceived != null
                                  ? "${DateFormat('yyyy-MM-dd hh:mm:ss').format(item.lastOrderReceived!.dateReceived!)}"
                                  : "null",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Expiration Date On Last Order Received: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: item.lastOrderReceived?.dateExpired != null
                                  ? "${DateFormat('yyyy-MM-dd hh:mm:ss').format(item.lastOrderReceived!.dateExpired!)}"
                                  : "null",
                            ),
                          ]),
                    )),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Formula For Selling Price: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${item.formula?.expression.toString()}",
                            ),
                          ]),
                    )),
              ],
            ),
          )),
        ),
      );
    });
  }

  deleteItem(int itemID) {
    DatabaseHelper.instance
        .delete(tableName: "items", where: "id = ?", whereArgs: [itemID]);
  }

  bool isItemUsed({required Item item}) {
    return item.lastOrderMade != null ? true : false;
  }

  void setToBeOrdered(Item item) async {
    item.toBeOrdered = !(item.toBeOrdered!);
    print("set to be orderd: ${item.toBeOrdered!}");

    await DatabaseHelper.instance.update(
        {"toBeOrdered": item.toBeOrdered! ? 1 : 0},
        "items",
        "id = ?",
        [item.id]);
  }

  void resetOverlay() {
    setState(() {
      itemDetailsOverlayVisible = false;
      editOverlayVisible = false;
      confirmDeleteVisible = false;
    });
  }
}
