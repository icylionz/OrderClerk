import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/bloc/bloc.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/orders/filter_order.dart';
import 'package:OrderClerk/screens/orders/order_details.dart';

class ViewOrders extends StatefulWidget {
  @override
  _ViewOrders createState() => _ViewOrders();
}

class _ViewOrders extends State<ViewOrders> {
  bool orderOverlayVisible = false;
  bool orderDetailsOverlayVisible = false;
  bool filterOrderOverlayVisible = false;
  int viewOrderID = -1;
  String? where;
  List<dynamic>? whereArgs;
  String orderSearchDropDownValue = "id";
  late Map<String, dynamic> orderSearchMap;
  GlobalKey<ScaffoldState> _distributorsView = new GlobalKey<ScaffoldState>();
  GlobalKey<FormBuilderState> _orderSearchKey =
      new GlobalKey<FormBuilderState>();
  FToast fToast = FToast();
  final Map<String, String> nameMap = {
    "id": "Order ID",
  };

  @override
  void initState() {
    super.initState();

    BlocProvider.of<ViewOrdersBloc>(context)..add(LoadOrderData());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GFFloatingWidget(
          showBlurness: orderOverlayVisible,
          child: orderOverlayVisible
              ? Container(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            orderDetailsOverlayVisible = false;
                            orderOverlayVisible = false;
                            filterOrderOverlayVisible = false;
                            refresh();
                          });
                        },
                      ),
                      Container(
                        height: constraints.maxHeight / 1.4,
                        width: constraints.maxWidth / 1.4,
                        color: Color.fromRGBO(50, 50, 50, 1),
                        child: orderDetailsOverlayVisible
                            ? DetailsOrder(
                                orderID: viewOrderID,
                                closeCallback: () {
                                  _resetOverlay();
                                },
                                refreshCallback: refresh,
                              )
                            : filterOrderOverlayVisible
                                ? FilterOrder(
                                    constraints: BoxConstraints(
                                        maxHeight: constraints.maxHeight / 1.5,
                                        maxWidth: constraints.maxWidth / 1.5),
                                    callback: refresh,
                                    closeCallback: _resetOverlay)
                                : Container(),
                      )
                    ],
                  ),
                )
              : Container(),
          body: Scaffold(
            key: _distributorsView,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  orderOverlayVisible = true;
                  orderDetailsOverlayVisible = true;
                });
              },
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 15.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(1, 10, 1, 10),
                            child: SizedBox(
                              child: _buildSearchBar(),
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        width: constraints.maxWidth / 2,
                        height: constraints.maxHeight - 40,
                        child: _buildTable(constraints)),
                  ],
                ),
              ),
            ),
          ));
    });
  }

  void _resetOverlay() {
    setState(() {
      orderDetailsOverlayVisible = false;
      orderOverlayVisible = false;
      filterOrderOverlayVisible = false;
    });
  }

  refresh() {
    BlocProvider.of<ViewOrdersBloc>(context)..add(LoadOrderData());
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        FormBuilder(
          key: _orderSearchKey,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Search Field
              Flexible(
                flex: 8,
                fit: FlexFit.loose,
                child: SizedBox(
                  width: 500,
                  child: FormBuilderTextField(
                    name: "orderSearchText",
                    onSubmitted: (text) {
                      _submitForm();
                    },
                    decoration: InputDecoration(
                        focusColor: Color.fromRGBO(0, 234, 255, 1),
                        suffixIcon: IconButton(
                            focusColor: Color.fromRGBO(0, 182, 212, 1),
                            splashRadius: 1,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _submitForm();
                            },
                            icon: Icon(
                              Icons.search,
                              size: 22,
                            )),
                        contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        hintText: "Search",
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 5,
                                style: BorderStyle.solid,
                                color: Color.fromRGBO(75, 118, 125, 1.0)))),
                    keyboardType: orderSearchDropDownValue == "name"
                        ? TextInputType.text
                        : TextInputType.number,
                    validator: orderSearchDropDownValue == "name"
                        ? FormBuilderValidators.compose([
                            FormBuilderValidators.maxLength(context, 200),
                          ])
                        : FormBuilderValidators.compose([
                            FormBuilderValidators.numeric(context),
                          ]),
                  ),
                ),
              ),
              //paddinhg
              SizedBox(
                width: 20,
              ),
              //Select Search By Criteria
              Flexible(
                child: SizedBox(
                  width: 130,
                  child: FormBuilderDropdown(
                      name: "orderSearchOption",
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          hintText: "Search By:",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 5,
                                  style: BorderStyle.solid,
                                  color: Color.fromRGBO(75, 118, 125, 1.0)))),
                      initialValue: "id",
                      onChanged: (String? newValue) {
                        setState(() {
                          orderSearchDropDownValue = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Order ID"),
                          value: "id",
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
        //filter
        IconButton(
            onPressed: () {
              //open filter overlay
              setState(() {
                orderOverlayVisible = true;
                filterOrderOverlayVisible = true;
              });
            },
            icon: Icon(Icons.filter_list)),
        //clear search field and results
        IconButton(
            onPressed: () {
              _orderSearchKey.currentState!.reset();
              OrderFilter.delete(
                  entry: OrderFilter.find(
                      name: nameMap["$orderSearchDropDownValue"]));
              refresh();
            },
            icon: Icon(Icons.clear)),
        //export
        IconButton(onPressed: () {}, icon: Icon(ModernPictograms.export_icon)),
        //refresh
        IconButton(
            onPressed: () {
              refresh();
            },
            tooltip: "Refresh",
            icon: Icon(Icons.refresh)),
      ],
    );
  }

  Widget _buildTable(BoxConstraints constraints) {
    return BlocBuilder<ViewOrdersBloc, ViewOrdersState>(
        builder: (BuildContext context, ViewOrdersState state) {
      if (state is ViewOrdersLoaded) {
        return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ExpansionTile(
                title: RichText(
                    text: TextSpan(children: [
                  TextSpan(text: "Order ${state.orders[index]!.id}   "),
                  TextSpan(
                      text:
                          "${state.orders[index]!.orders.first.item!.distributor!.name}",
                      style:
                          TextStyle(color: Color.fromRGBO(255, 255, 255, .5))),
                ])),
                trailing: IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: () {
                    viewOrderDetails(id: state.orders[index]!.id);
                  },
                ),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemExtent: 120,
                    itemBuilder: (context, itemIndex) {
                      return Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Quantity
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: Wrap(
                                spacing: 25,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                      children: [
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                          text: "QTY\n",
                                        ),
                                        TextSpan(
                                          style: TextStyle(
                                            fontSize: 30,
                                          ),
                                          text:
                                              "${state.orders[index]!.orders[itemIndex].quantity} ",
                                        ),
                                      ],
                                    ),
                                  ])),

                                  //Item details
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                        overflow: TextOverflow.visible,
                                        text: TextSpan(
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    90, 90, 90, 1),
                                                fontWeight: FontWeight.w600),
                                            children: [
                                              TextSpan(
                                                text:
                                                    "${state.orders[index]!.orders[itemIndex].item!.name}\n",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    color: Colors.white),
                                              ),
                                              TextSpan(
                                                  text:
                                                      "Item ID: ${state.orders[index]!.orders[itemIndex].itemID}\n"),
                                            ])),
                                  ),
                                ],
                              ),
                            ),
                            //Statuses
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, right: 40),
                              child: Container(
                                height: 150,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //Received Status
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Received:"),
                                        state.orders[index]?.orders[itemIndex]
                                                    .isReceived ??
                                                false
                                            ? Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              )
                                            : Icon(
                                                Icons.cancel,
                                              ),
                                      ],
                                    ),
                                    //Cancelled Status
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Cancelled:"),
                                        state.orders[index]?.orders[itemIndex]
                                                    .isCancelled ??
                                                false
                                            ? Icon(
                                                Icons.check_circle,
                                                color: Colors.red,
                                              )
                                            : Icon(Icons.cancel),
                                      ],
                                    ),
                                    //Expired Status
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Expired:"),
                                        Icon(
                                          state.orders[index]?.orders[itemIndex]
                                                      .isExpired ??
                                                  false
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: state
                                                      .orders[index]
                                                      ?.orders[itemIndex]
                                                      .dateExpired !=
                                                  null
                                              ? state
                                                      .orders[index]!
                                                      .orders[itemIndex]
                                                      .dateExpired!
                                                      .isAfter(DateTime.now()
                                                          .add(const Duration(
                                                              days: 30)))
                                                  ? Colors.green
                                                  : state
                                                          .orders[index]!
                                                          .orders[itemIndex]
                                                          .dateExpired!
                                                          .isBefore(
                                                              DateTime.now())
                                                      ? Colors.red
                                                      : Colors.yellow
                                              : Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: state.orders[index]!.orders.length,
                  ),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: state.orders.length);
      }

      if (state is ViewOrdersLoading) return CircularProgressIndicator();
      if (state is ViewOrdersError) return Text(state.error);
      return Text(state.toString());
    });
  }

  //Submit Button Action for search bar
  void _submitForm() {
    _orderSearchKey.currentState!.save();
    if (_orderSearchKey.currentState!.validate()) {
      OrderFilter.add(
          name: nameMap["$orderSearchDropDownValue"],
          contains: true,
          where: orderSearchDropDownValue,
          whereArgs: _orderSearchKey.currentState!.value[
              "orderSearchText"]); // if nothing was entered in the search field

    } else {}
    refresh();
  }

  //opens overlay for order details
  void viewOrderDetails({required int id}) {
    setState(() {
      orderOverlayVisible = true;
      viewOrderID = id;
      orderDetailsOverlayVisible = true;
    });
  }
}
