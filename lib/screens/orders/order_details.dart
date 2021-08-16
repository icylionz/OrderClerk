import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:OrderClerk/src/queries.dart';

class DetailsOrder extends StatefulWidget {
  final int orderID;
  final Function() closeCallback;
  final Function() refreshCallback;
  DetailsOrder(
      {Key? key,
      required this.orderID,
      required void Function() this.closeCallback,
      required void Function() this.refreshCallback})
      : super(key: key);

  @override
  _DetailsOrderState createState() => _DetailsOrderState(
      orderID: orderID,
      closeCallback: closeCallback,
      refreshCallback: refreshCallback);
}

class _DetailsOrderState extends State<DetailsOrder> {
  int orderID;
  OrderCluster? orderCluster;
  late Order orderChosen;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  Function() closeCallback;
  Function() refreshCallback;
  bool confirmDeleteVisible = false;
  bool orderDetailsOverlayVisible = false;
  bool orderOptionsVisible = false;
  bool notesOverlayVisible = false;
  late int selectedNotesIndex;
  final GlobalKey<FormBuilderState> _orderChosenFormKey =
      GlobalKey<FormBuilderState>();
  late int orderChosenIndex;

  _DetailsOrderState(
      {required this.orderID,
      required this.closeCallback,
      required this.refreshCallback}) {
    orderCluster = OrdersSource.cluster
        .where((element) => element.id == orderID ? true : false)
        .first;
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
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    orderCluster!.orders.forEach((element) {
      print("Order ${element.item!.name} Cancel: ${element.isCancelled}");
    });
    return LayoutBuilder(builder: (context, constraints) {
      return GFFloatingWidget(
        showBlurness: orderDetailsOverlayVisible,
        child: orderDetailsOverlayVisible
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
                            color: AppTheme.myTheme.scaffoldBackgroundColor,
                            width: constraints.maxWidth - 200,
                            height: constraints.maxHeight - 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Are you sure you want to delete Order #$orderID?",
                                  softWrap: true,
                                ),
                                Text(
                                  "N.B This is not the same as cancelling the order!",
                                  style: TextStyle(color: Colors.red),
                                  softWrap: true,
                                ),
                                Center(
                                  child: ButtonBar(
                                    children: [
                                      //yes button
                                      GFButton(
                                        onPressed: () {
                                          deleteOrder(orderID);
                                          setState(() {
                                            widget.refreshCallback();
                                            widget.closeCallback();
                                          });
                                        },
                                        child: Text("Yes"),
                                      ),
                                      //no button
                                      GFButton(
                                        onPressed: () {
                                          setState(() {
                                            confirmDeleteVisible = false;
                                          });
                                        },
                                        child: Text("No"),
                                        color: Colors.red,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : orderOptionsVisible
                          ? Center(
                              child: Container(
                                color: AppTheme.myTheme.scaffoldBackgroundColor
                                    .withOpacity(1),
                                width: constraints.maxWidth - 200,
                                height: constraints.maxHeight - 200,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      //navigation bar
                                      ButtonBar(
                                        alignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          //close btn
                                          IconButton(
                                              tooltip: "Close",
                                              onPressed: resetOverlay,
                                              icon: Icon(Icons.close)),
                                          Text(
                                            "Order #${orderChosen.id}",
                                          ),
                                          Icon(
                                            Icons.close,
                                            color: Colors.transparent,
                                          ),
                                        ],
                                      ),

                                      ButtonBar(
                                        alignment: MainAxisAlignment.center,
                                        children: [
                                          FormBuilder(
                                              key: _orderChosenFormKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  //Expiration date
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Container(
                                                      height: 60,
                                                      width:
                                                          constraints.maxWidth -
                                                              20,
                                                      child: FormBuilderDateTimePicker(
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      style: BorderStyle
                                                                          .solid)),
                                                              labelText:
                                                                  "Expires On",
                                                              labelStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          14)),
                                                          fieldHintText:
                                                              "Expires on",
                                                          helpText:
                                                              "Expiration Date",
                                                          fieldLabelText:
                                                              "Expires on",
                                                          name: "dateExpired"),
                                                    ),
                                                  ),
                                                  //Batch Number
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Container(
                                                      height: 60,
                                                      width:
                                                          constraints.maxWidth -
                                                              20,
                                                      child:
                                                          FormBuilderTextField(
                                                        decoration:
                                                            InputDecoration(
                                                          border: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  style: BorderStyle
                                                                      .solid)),
                                                          labelText: 'Batch #',
                                                          labelStyle: TextStyle(
                                                              fontSize: 15),
                                                        ),
                                                        name: "batchNumber",
                                                      ),
                                                    ),
                                                  ),
                                                  //Notes
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Container(
                                                      height: 60,
                                                      width:
                                                          constraints.maxWidth -
                                                              20,
                                                      child:
                                                          FormBuilderTextField(
                                                        decoration:
                                                            InputDecoration(
                                                          border: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  style: BorderStyle
                                                                      .solid)),
                                                          labelText: 'Notes',
                                                          labelStyle: TextStyle(
                                                              fontSize: 15),
                                                        ),
                                                        name: "notes",
                                                      ),
                                                    ),
                                                  ),

                                                  //Buttons
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      //Received Button
                                                      orderCluster!
                                                                  .orders[
                                                                      orderChosenIndex]
                                                                  .isReceived ??
                                                              false
                                                          ? IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  unreceiveOrder(
                                                                      orderChosen);
                                                                });
                                                              },
                                                              icon: Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              tooltip:
                                                                  "Unreceive",
                                                            )
                                                          : IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  receiveOrder(
                                                                      orderChosen);
                                                                });
                                                              },
                                                              icon: const Icon(Icons
                                                                  .check_circle),
                                                              tooltip:
                                                                  "Received",
                                                            ),
                                                      //Cancelled Button
                                                      orderCluster!
                                                                  .orders[
                                                                      orderChosenIndex]
                                                                  .isCancelled ??
                                                              false
                                                          ? IconButton(
                                                              onPressed: () {
                                                                uncancelOrder(
                                                                    orderChosen);
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .cancel_rounded,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              tooltip:
                                                                  "Uncancel",
                                                            )
                                                          : IconButton(
                                                              onPressed: () {
                                                                cancelOrder(
                                                                    orderChosen);
                                                              },
                                                              icon: const Icon(Icons
                                                                  .cancel_rounded),
                                                              tooltip:
                                                                  "Cancelled",
                                                            ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : notesOverlayVisible
                              ? Center(
                                  child: EditOrderNotes(
                                    closeCallback: resetOverlay,
                                    refreshCallback: refresh,
                                    constraints: BoxConstraints(
                                        maxHeight: constraints.maxHeight / 1.5,
                                        maxWidth: constraints.maxWidth / 1.5),
                                    order: orderCluster!
                                        .orders[selectedNotesIndex],
                                  ),
                                )
                              : Container()
                ]))
            : Container(),
        body: Container(
          padding: EdgeInsets.all(12),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _verticalController,
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //top navigation
                    Container(
                      width: constraints.maxWidth - 20,
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //close btn
                          IconButton(
                              tooltip: "Close",
                              onPressed: closeCallback,
                              icon: Icon(Icons.close)),
                          Text(
                            "Order Details",
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //Export Order
                              IconButton(
                                  tooltip: "Export Order",
                                  onPressed: () {
                                    if (orderCluster != null)
                                      exportPDF(orderCluster!);
                                  },
                                  icon: Icon(
                                    ModernPictograms.export_icon,
                                  )),
                              //delete Order
                              IconButton(
                                tooltip: "Delete Order",
                                onPressed: () {
                                  setState(() {
                                    orderDetailsOverlayVisible = true;
                                    confirmDeleteVisible = true;
                                  });
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    //Order Details
                    Text(
                      "Order #${orderCluster!.orders.first.id}",
                      style: AppTheme.myTheme.textTheme.headline6,
                    ),
                    Text(
                        "Date Ordered: ${DateFormat('yyyy-MM-dd hh:mm:ss').format(orderCluster!.orders.first.dateOrdered!)}"),
                    Text(
                        "Distributor Name: ${orderCluster!.orders.first.item!.distributor?.name}"),
                    //List of items in the order
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
                      child: Center(
                        child: Text(
                          "Items Ordered",
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Container(
                      color: AppTheme.darken(
                          AppTheme.myTheme.scaffoldBackgroundColor, 0.1),
                      width: constraints.maxWidth,
                      height: constraints.maxHeight - 100,
                      child: ListView.separated(
                          separatorBuilder: (context, index) => Center(
                                  child: Divider(
                                endIndent: 15,
                                indent: 15,
                              )),
                          itemCount: orderCluster!.orders.length,
                          itemBuilder: (context, index) {
                            TextEditingController _orderNotesController =
                                TextEditingController();
                            _orderNotesController.text =
                                orderCluster!.orders[index].notes ?? "";
                            return Container(
                                color: Colors.transparent,
                                margin: EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //Quantity
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                        children: [
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                            text: "QTY\n",
                                          ),
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 30,
                                            ),
                                            text:
                                                "${orderCluster!.orders[index].quantity} ",
                                          ),
                                        ],
                                      ),
                                    ])),
                                    //Item Name
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 30,
                                              ),
                                              text:
                                                  "${orderCluster!.orders[index].item!.name}")),
                                    ),
                                    //Order Details
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(text: "Item   #"),
                                        TextSpan(
                                            text:
                                                "${orderCluster!.orders[index].item?.id}\n",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        if (orderCluster!
                                                .orders[index].isReceived ==
                                            true)
                                          TextSpan(text: "Date Received:   "),
                                        if (orderCluster!
                                                .orders[index].isReceived ==
                                            true)
                                          TextSpan(
                                              text:
                                                  "${DateFormat('yyyy-MM-dd hh:mm:ss').format(orderCluster!.orders[index].dateReceived!)}\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        if (orderCluster!
                                                .orders[index].isCancelled ==
                                            true)
                                          TextSpan(text: "Date Cancelled:   "),
                                        if (orderCluster!
                                                .orders[index].isCancelled ==
                                            true)
                                          TextSpan(
                                              text:
                                                  "${DateFormat('yyyy-MM-dd hh:mm:ss').format(orderCluster!.orders[index].dateCancelled!)}\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        if (orderCluster!
                                                .orders[index].dateExpired !=
                                            null)
                                          TextSpan(text: "Expiration date:   "),
                                        if (orderCluster!
                                                .orders[index].dateExpired !=
                                            null)
                                          TextSpan(
                                              text:
                                                  "${DateFormat('yyyy-MM-dd hh:mm:ss').format(orderCluster!.orders[index].dateExpired!)}\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        if (orderCluster!
                                                .orders[index].batchNumber !=
                                            null)
                                          TextSpan(text: "Batch #: "),
                                        if (orderCluster!
                                                .orders[index].batchNumber !=
                                            null)
                                          TextSpan(
                                              text:
                                                  "${orderCluster!.orders[index].batchNumber}\n",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                      ]),
                                    ),
                                    //buttons for order reception and cancellation and notes field
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: 150,
                                          maxWidth: 300,
                                          minHeight: 100,
                                          minWidth: 300),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ButtonBar(
                                            alignment: MainAxisAlignment.center,
                                            children: [
                                              //Notes Field
                                              Container(
                                                height: 40,
                                                width: 150,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppTheme.myTheme
                                                            .backgroundColor,
                                                        width: 1)),
                                                child: InkWell(
                                                  onTap: () {
                                                    _notesOverlay(index);
                                                  },
                                                  child: TextFormField(
                                                    maxLines: 1,
                                                    readOnly: true,
                                                    controller:
                                                        _orderNotesController,
                                                    enabled: false,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.all(3),
                                                      labelText: 'Notes',
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              //options button
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    orderChosen = orderCluster!
                                                        .orders[index];
                                                    orderChosenIndex = index;
                                                    orderDetailsOverlayVisible =
                                                        true;
                                                    orderOptionsVisible = true;
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                ),
                                                tooltip: "Received",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ));
                          }),
                    )
                  ],
                ),
              )),
        ),
      );
    });
  }

  void cancelOrder(Order order) {
    //updates the order record
    DatabaseHelper.instance.update(
        {"cancelled": 1, "dateCancelled": DateTime.now().toIso8601String()},
        "orders",
        "id = ? AND itemID = ?",
        [order.id, order.item!.id]);
    //updates the item record
    DatabaseHelper.instance.update(
        {
          "toBeOrdered": 1,
        },
        "items",
        "id = ?",
        [order.item!.id]);

    refresh();
  }

  void uncancelOrder(Order order) async {
    //updates the order record
    await DatabaseHelper.instance.update(
        {"cancelled": 0, "dateCancelled": null},
        "orders",
        "id = ? AND itemID = ?",
        [order.id, order.item!.id]);
    //updates the item record
    DatabaseHelper.instance.update(
        {
          "toBeOrdered": 1,
        },
        "items",
        "id = ?",
        [order.item!.id]);

    refresh();
  }

  void receiveOrder(Order order) {
    _orderChosenFormKey.currentState!.validate();
    _orderChosenFormKey.currentState!.save();
    //updates the order record
    DatabaseHelper.instance.update(
        {
          "batchNumber": _orderChosenFormKey.currentState!.value["batchNumber"],
          "dateExpired":
              _orderChosenFormKey.currentState!.value["dateExpired"].toString(),
          "dateReceived": DateTime.now().toIso8601String(),
          "received": 1,
          if (_orderChosenFormKey.currentState!.value["notes"] != null &&
              _orderChosenFormKey.currentState!.value["notes"] != "")
            "notes": _orderChosenFormKey.currentState!.value["notes"],
        },
        "orders",
        "id = ? AND itemID = ?",
        [
          order.id,
          order.item!.id,
        ]);
    refresh();
  }

  void unreceiveOrder(Order order) async {
    //updates the order record
    DatabaseHelper.instance.update(
        {
          "batchNumber": null,
          "dateExpired": null,
          "dateReceived": null,
          "received": 0,
        },
        "orders",
        "id = ? AND itemID = ?",
        [
          order.id,
          order.item!.id,
        ]);
    //updates the item record
    DatabaseHelper.instance.update(
        {
          "toBeOrdered": 1,
        },
        "items",
        "id = ?",
        [order.item!.id]);

    refresh();
  }

  void refresh() {
    setState(() {
      refreshCallback();
      orderCluster = OrdersSource.cluster
          .where((element) => element.id == orderID ? true : false)
          .first;
    });
  }

  deleteOrder(int orderID) {
    DatabaseHelper.instance
        .delete(tableName: "orders", where: "id = ?", whereArgs: [orderID]);
  }

  void resetOverlay() {
    setState(() {
      refreshCallback();
      orderCluster = OrdersSource.cluster
          .where((element) => element.id == orderID ? true : false)
          .first;
      orderDetailsOverlayVisible = false;
      orderOptionsVisible = false;
      confirmDeleteVisible = false;
    });
  }

  void _notesOverlay(int index) {
    setState(() {
      selectedNotesIndex = index;
      orderDetailsOverlayVisible = true;
      notesOverlayVisible = true;
    });
  }

  void exportPDF(OrderCluster order) {
    _savePDFs(_createPDF(orderCluster!));
  }

  Map<Distributor, pdf.Document> _createPDF(OrderCluster order) {
    pdf.Document orderPdf = pdf.Document();
    // builds the pdf
    orderPdf.addPage(
      pdf.MultiPage(
        margin: pdf.EdgeInsets.all(32),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return <pdf.Widget>[
            //Header with Distributor Info
            pdf.Header(
                level: 0,
                child: pdf.Text("${order.orders.first.item!.distributor!.name}",
                    style: pdf.TextStyle(
                        font: pdf.Font.helveticaBold(),
                        fontSize: 30,
                        fontWeight: pdf.FontWeight.bold))),
            pdf.Header(
                level: 2,
                child: pdf.Text(
                  "Telephone: ${order.orders.first.item?.distributor?.telephone ?? "Not Provided"} | Email: ${order.orders.first.item?.distributor?.email ?? "Not Provided"} | Address: ${order.orders.first.item?.distributor?.address ?? "Not Provided"}",
                  style: pdf.TextStyle(font: pdf.Font.helveticaBold()),
                )),
            pdf.Divider(),
            pdf.Row(
                mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                children: [
                  pdf.Expanded(
                      flex: 2,
                      child: pdf.Text(
                        "Item Name",
                        style: pdf.TextStyle(font: pdf.Font.helveticaBold()),
                      )),
                  pdf.Expanded(flex: 7, child: pdf.Container()),
                  pdf.Expanded(
                      flex: 1,
                      child: pdf.Text(
                        "Quantity",
                        style: pdf.TextStyle(font: pdf.Font.helveticaBold()),
                      )),
                ]),
            pdf.Divider(),
            pdf.LayoutBuilder(builder: (context, constraints) {
              return pdf.ListView.separated(
                  itemBuilder: (context, index) {
                    return pdf.Row(
                        mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                        children: [
                          pdf.Expanded(
                              flex: 2,
                              child: pdf.Text(
                                "${orderCluster!.orders[index].item!.name}",
                                style: pdf.TextStyle(
                                    font: pdf.Font.helveticaBold()),
                              )),
                          pdf.Expanded(flex: 7, child: pdf.Container()),
                          pdf.Expanded(
                              flex: 1,
                              child: pdf.Text(
                                "${orderCluster!.orders[index].quantity}",
                                style: pdf.TextStyle(
                                    font: pdf.Font.helveticaBold()),
                              )),
                        ]);
                  },
                  separatorBuilder: (context, index) {
                    return pdf.Divider();
                  },
                  itemCount: orderCluster!.orders.length);
            }),
          ];
        },
      ),
    );

    return {orderCluster!.orders.first.item!.distributor!: orderPdf};
  }

  _savePDFs(Map<Distributor, pdf.Document> doc) async {
    SaveFilePicker? filePath;
    File? file;

    //gets file from user
    filePath = SaveFilePicker()
      ..defaultExtension = "pdf"
      ..filterSpecification = {"pdf": "*.pdf"}
      ..fileName =
          "${doc.keys.first.name}_${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}";
    file = filePath.getFile();

    //saves file
    if (file != null) {
      file.writeAsBytes(await doc.values.first.save());
    }
  }
}

class EditOrderNotes extends StatefulWidget {
  final BoxConstraints constraints;
  final Order order;

  EditOrderNotes(
      {Key? key,
      required this.closeCallback,
      required this.refreshCallback,
      required this.constraints,
      required this.order})
      : super(key: key);

  final Function() closeCallback;
  final Function() refreshCallback;

  @override
  _EditOrderNotesState createState() => _EditOrderNotesState();
}

class _EditOrderNotesState extends State<EditOrderNotes> {
  TextEditingController notesTextFieldController = new TextEditingController();
  @override
  void initState() {
    notesTextFieldController.text = widget.order.notes ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.myTheme.scaffoldBackgroundColor,
      width: widget.constraints.maxWidth,
      height: widget.constraints.maxHeight,
      child: FormBuilder(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Navigation Bar
          Center(
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                //close btn
                IconButton(
                    tooltip: "Close",
                    onPressed: widget.closeCallback,
                    icon: Icon(Icons.close)),
                //filler
                Text(
                  "",
                ),
                //filler
                Icon(
                  Icons.delete,
                  color: Colors.transparent,
                ),
              ],
            ),
          ),
          //notes field
          Text("Notes"),
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey, style: BorderStyle.solid)),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              child: SingleChildScrollView(
                child: TextField(
                  controller: notesTextFieldController,
                  maxLines: null,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                  ),
                ),
              ),
            ),
          ),
          //Button Bar Functions
          Expanded(
              flex: 1,
              child: ButtonBar(
                children: [
                  GFButton(
                    child: Text("Save"),
                    onPressed: () {
                      DatabaseHelper.instance.update(
                          {"notes": notesTextFieldController.text},
                          "orders",
                          "id = ? AND itemID = ? ",
                          [widget.order.id, widget.order.itemID]);
                      widget.order.notes = notesTextFieldController.text;
                      widget.refreshCallback();
                    },
                  ),
                  GFButton(
                      child: Text("Undo"),
                      onPressed: () {
                        notesTextFieldController.text =
                            widget.order.notes ?? "";
                      }),
                ],
              ))
        ],
      )),
    );
  }
}
