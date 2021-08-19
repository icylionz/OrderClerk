import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/data_sources/items_source.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/distributors/edit_distributor.dart';
import 'package:OrderClerk/src/queries.dart';

class DetailDistributor extends StatefulWidget {
  final int distributorID;
  final Function() callback;
  DetailDistributor(
      {Key? key, required this.distributorID, required this.callback})
      : super(key: key);

  @override
  _DetailDistributorState createState() => _DetailDistributorState(
      distributorID: this.distributorID, callback: this.callback);
}

class _DetailDistributorState extends State<DetailDistributor> {
  int distributorID;
  Function() callback;
  late Distributor distributor;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  bool distributorDetailsOverlayVisible = false;
  bool confirmDeleteVisible = false;
  bool editOverlayVisible = false;
  FToast fToast = FToast();

  EdgeInsets _itemDetailPadding = const EdgeInsets.all(8);

  _DetailDistributorState(
      {required this.distributorID, required this.callback}) {
    this.distributor = DistributorsSource.extract(id: distributorID);
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
        showBlurness: distributorDetailsOverlayVisible,
        child: distributorDetailsOverlayVisible
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
                            color: AppTheme.darken(
                                AppTheme.myTheme.scaffoldBackgroundColor),
                            width: constraints.maxWidth - 200,
                            height: constraints.maxHeight - 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Are you sure you want to delete Distributor #$distributorID?",
                                  softWrap: true,
                                ),
                                Text(
                                  "N.B This is not the same as cancelling the item!",
                                  style: TextStyle(color: Colors.red),
                                  softWrap: true,
                                ),
                                Center(
                                  child: ButtonBar(
                                    children: [
                                      //yes button
                                      GFButton(
                                        onPressed: () {
                                          if (!isDistributorUsed(
                                              distributor: distributor)) {
                                            deleteDistributor(distributorID);
                                            setState(callback);
                                          } else
                                            _showToast(
                                                child: Text(
                                                    "You cannot delete this distributor because it is being used by item records. Editing the distributor's information is a better solution."),
                                                backgroundColor: Colors.red,
                                                duration: 5);
                                          resetOverlay();
                                        },
                                        child: Text("Yes"),
                                      ),
                                      //no button
                                      GFButton(
                                        onPressed: () {
                                          resetOverlay();
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
                      : editOverlayVisible
                          ? Center(
                              child: Container(
                                  width: constraints.maxWidth - 200,
                                  height: constraints.maxHeight - 200,
                                  color: AppTheme.darken(
                                      AppTheme.myTheme.scaffoldBackgroundColor),
                                  child: EditDistributor(
                                    distributor: distributor,
                                    callback: resetOverlay,
                                  )),
                            )
                          : Container(),
                ]),
              )
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
                      "Distributor Details",
                    ),
                    //delete Distributor
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Edit Distributor",
                          onPressed: () {
                            setState(() {
                              distributorDetailsOverlayVisible = true;
                              editOverlayVisible = true;
                            });
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          tooltip: "Delete Distributor",
                          onPressed: () {
                            setState(() {
                              distributorDetailsOverlayVisible = true;
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

                //Distributor Details
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
                            text: "Distributor ID: ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: "${distributor.id}",
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
                              text: "Distributor Name: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${distributor.name}",
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
                              text: "Address: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${distributor.address}",
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
                              text: "Email Address: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${distributor.email}",
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
                              text: "Telephone Number: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${distributor.telephone}",
                            ),
                          ]),
                    )),
                Divider(
                  endIndent: 5,
                  indent: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Items carried by ${distributor.name} : ",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyText1!.color),
                  ),
                ),
                Container(
                  color: AppTheme.darken(
                      AppTheme.myTheme.scaffoldBackgroundColor, 0.2),
                  width: constraints.maxWidth - (_itemDetailPadding.left * 2),
                  height: 600,
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                            leading: Text("#${distributor.items[index]!.id}"),
                            title: Text("${distributor.items[index]!.name}"),
                            trailing: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                                  text: "Pkg Size:  ",
                                  children: [
                                    TextSpan(
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      text:
                                          "${distributor.items[index]!.packageSize}",
                                    ),
                                  ]),
                            ));
                      },
                      separatorBuilder: (context, index) => Divider(
                            indent: 10,
                            endIndent: 10,
                          ),
                      itemCount: distributor.items.length),
                ),
              ],
            ),
          )),
        ),
      );
    });
  }

  deleteDistributor(int distributorID) {
    DatabaseHelper.instance.delete(
        tableName: "distributors", where: "id = ?", whereArgs: [distributorID]);
  }

  bool isDistributorUsed({required Distributor distributor}) {
    if (ItemsSource.data.length > 0)
      return ItemsSource.data.firstWhere((element) =>
                  element!.distributor == distributor ? true : false) !=
              null
          ? true
          : false;
    return false;
  }

  void resetOverlay() {
    setState(() {
      distributorDetailsOverlayVisible = false;
      editOverlayVisible = false;
      confirmDeleteVisible = false;
    });
  }
}
