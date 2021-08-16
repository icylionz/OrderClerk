import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/Filter.dart';

class FilterOrder extends StatefulWidget {
  final BoxConstraints constraints;
  final VoidCallback callback;
  final VoidCallback closeCallback;
  FilterOrder(
      {Key? key,
      required this.constraints,
      required this.callback,
      required this.closeCallback})
      : super(key: key);

  @override
  _FilterOrderState createState() => _FilterOrderState();
}

class _FilterOrderState extends State<FilterOrder> {
  FToast fToast = FToast();
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  GlobalKey<FormBuilderState> _orderFilterForm =
      new GlobalKey<FormBuilderState>();
  GlobalKey<FormBuilderState> _filterNameKey =
      new GlobalKey<FormBuilderState>();
  final Map<String, String> nameMap = {
    "dateReceived": "Date Received",
    "dateOrdered": "Date Ordered",
    "dateCancelled": "Date Cancelled",
    "dateExpired": "Date Expired",
    "received": "Received",
    "cancelled": "Cancelled",
    "expired": "Expired",
    "batchNumber": "Batch Number",
    "notes": "Notes",
  };
  bool dateSelected = false;
  bool boolSelected = false;
  final EdgeInsetsGeometry defaultDropDownPadding =
      EdgeInsets.fromLTRB(8, 2, 8, 2);

  _FilterOrderState();

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //navbar
            Container(
              width: widget.constraints.maxWidth,
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  //close btn
                  IconButton(
                      tooltip: "Close",
                      onPressed: widget.closeCallback,
                      icon: Icon(Icons.close)),
                  Text(
                    "Order Filter",
                    style: AppTheme.myTheme.textTheme.headline6,
                  ),
                  //dummy
                  Icon(
                    Icons.close,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),

            // Add Filter Form
            FormBuilder(
                key: _orderFilterForm,
                child: Row(
                  children: [
                    //Field being searched
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 40,
                        width: 150,
                        child: FormBuilderDropdown(
                          key: _filterNameKey,
                          name: "where",
                          items: List.generate(
                              nameMap.length,
                              (index) => DropdownMenuItem(
                                  onTap: () {
                                    setState(() {
                                      if (nameMap.entries
                                          .elementAt(index)
                                          .key
                                          .contains("date")) {
                                        dateSelected = true;
                                        boolSelected = false;
                                      } else if (nameMap.entries
                                                  .elementAt(index)
                                                  .key ==
                                              "received" ||
                                          nameMap.entries
                                                  .elementAt(index)
                                                  .key ==
                                              "expired" ||
                                          nameMap.entries
                                                  .elementAt(index)
                                                  .key ==
                                              "cancelled") {
                                        boolSelected = true;
                                        dateSelected = false;
                                      } else {
                                        dateSelected = false;
                                        boolSelected = false;
                                      }
                                    });
                                  },
                                  value: nameMap.entries.elementAt(index).key,
                                  child: Text(
                                      "${nameMap.entries.elementAt(index).value}"))),
                          decoration: InputDecoration(
                              hintText: "Search For",
                              contentPadding: defaultDropDownPadding,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey,
                                      style: BorderStyle.solid))),
                        ),
                      ),
                    ),
                    //Matching Criteria
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 40,
                          width: 150,
                          child: dateSelected
                              ? FormBuilderDateTimePicker(
                                  decoration:
                                      InputDecoration(hintText: "From Date"),
                                  fieldLabelText: "From Date",
                                  name: 'firstDate',
                                  alwaysUse24HourFormat: true,
                                  valueTransformer: (DateTime? date) {
                                    return date != null
                                        ? date.toIso8601String()
                                        : "";
                                  },
                                )
                              : boolSelected
                                  ? FormBuilderDropdown(
                                      name: "criteria",
                                      items: [
                                        const DropdownMenuItem(
                                            value: "is", child: Text("Is")),
                                        const DropdownMenuItem(
                                            value: "isNot",
                                            child: Text("Is Not")),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "Constraints",
                                        contentPadding: defaultDropDownPadding,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey,
                                                style: BorderStyle.solid)),
                                      ),
                                    )
                                  : FormBuilderDropdown(
                                      name: "criteria",
                                      items: [
                                        const DropdownMenuItem(
                                            value: "contains",
                                            child: Text("Contains")),
                                        const DropdownMenuItem(
                                            value: "exact",
                                            child: Text("Is Exactly")),
                                        const DropdownMenuItem(
                                            value: "begins",
                                            child: Text("Begins With")),
                                        const DropdownMenuItem(
                                            value: "ends",
                                            child: Text("Ends In")),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: "Constraints",
                                        contentPadding: defaultDropDownPadding,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey,
                                                style: BorderStyle.solid)),
                                      ),
                                    ),
                        )),
                    // Dash (-) seperator for dates
                    dateSelected
                        ? Text(
                            " to ",
                            style: TextStyle(fontSize: 25),
                          )
                        : Container(),
                    //String being searched
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 40,
                        width: dateSelected ? 150 : 300,
                        child: dateSelected
                            ? FormBuilderDateTimePicker(
                                decoration:
                                    InputDecoration(hintText: "To Date"),
                                fieldLabelText: "To Date",
                                name: 'lastDate',
                                alwaysUse24HourFormat: true,
                                valueTransformer: (DateTime? date) {
                                  return date != null
                                      ? date.toIso8601String()
                                      : "";
                                },
                              )
                            : boolSelected
                                ? FormBuilderDropdown(
                                    initialValue: 1,
                                    name: 'whereArgs',
                                    items: [
                                        DropdownMenuItem(
                                          child: Text("True"),
                                          value: 1,
                                        ),
                                        DropdownMenuItem(
                                          child: Text("False"),
                                          value: 0,
                                        )
                                      ])
                                : FormBuilderTextField(
                                    name: 'whereArgs',
                                    decoration: InputDecoration(
                                      contentPadding: defaultDropDownPadding,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey,
                                              style: BorderStyle.solid)),
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(context),
                                      FormBuilderValidators.maxLength(
                                          context, 100),
                                    ]),
                                    keyboardType: TextInputType.text,
                                  ),
                      ),
                    ),
                    //Add Button creating filter entry
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _orderFilterForm.currentState!.save();
                            if (_orderFilterForm.currentState!.validate()) {
                              submitFilter();
                            }
                          });
                        },
                        child: Text("Add"))
                  ],
                )),
            //View Filters
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Filters"),
            ),
            SizedBox(
              width: widget.constraints.maxWidth,
              height: 250,
              child: Container(
                  color: Color.fromRGBO(45, 45, 45, 1),
                  margin: EdgeInsets.all(12),
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text((OrderFilter.filter[index]
                                      .name ?? // The field being searched
                                  "null") +
                              " " +
                              (OrderFilter.filter[index].isDate // Date Format
                                  ? "between ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(OrderFilter.filter[index].firstDate!))} and ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(OrderFilter.filter[index].lastDate!))}"
                                  : OrderFilter.filter[index].isBool
                                      ? "Is ${int.parse(OrderFilter.filter[index].whereArgs ?? "0") == 1 ? true : false}"
                                      : ((OrderFilter.filter[index]
                                                  .begins // how the string should be matched with databade records
                                              ? "beginning with"
                                              : OrderFilter
                                                      .filter[index].contains
                                                  ? "containing"
                                                  : OrderFilter
                                                          .filter[index].ends
                                                      ? "ending with"
                                                      : OrderFilter
                                                              .filter[index]
                                                              .exact
                                                          ? "is"
                                                          : "null") +
                                          "  " +
                                          (OrderFilter
                                                  .filter[index].whereArgs ??
                                              "null")))), //the string being searched for
                          trailing: IconButton(
                            icon: Icon(Icons
                                .delete), // icon to delete the filter entry
                            onPressed: () {
                              setState(() {
                                OrderFilter.delete(
                                    entry: OrderFilter.filter[index]);
                                refresh();
                              });
                            },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                      itemCount: OrderFilter.filter.length)),
            ),
          ],
        ),
      ),
    );
  }

  void submitFilter() {
    setState(() {
      //creates a date filter entry
      if (dateSelected)
        OrderFilter.add(
            name: nameMap["${_orderFilterForm.currentState!.value["where"]}"],
            where: _orderFilterForm.currentState!.value["where"],
            isDate: true,
            firstDate: _orderFilterForm.currentState!.value["firstDate"],
            lastDate: _orderFilterForm.currentState!.value["lastDate"]);
      else if (boolSelected)
        OrderFilter.add(
          name: nameMap["${_orderFilterForm.currentState!.value["where"]}"],
          where: _orderFilterForm.currentState!.value["where"] +
              (_orderFilterForm.currentState!.value["criteria"] == "is"
                  ? " ="
                  : " !="),
          whereArgs:
              _orderFilterForm.currentState!.value["whereArgs"].toString(),
          isBool: true,
        );
      else
        OrderFilter.add(
            name: nameMap["${_orderFilterForm.currentState!.value["where"]}"],
            exact: _orderFilterForm.currentState!.value["criteria"] == "exact"
                ? true
                : false,
            contains:
                _orderFilterForm.currentState!.value["criteria"] == "contains"
                    ? true
                    : false,
            begins: _orderFilterForm.currentState!.value["criteria"] == "begins"
                ? true
                : false,
            ends: _orderFilterForm.currentState!.value["criteria"] == "ends"
                ? true
                : false,
            where: _orderFilterForm.currentState!.value["where"],
            whereArgs: _orderFilterForm.currentState!.value[
                "whereArgs"]); // if nothing was entered in the search field
      refresh();
    });
  }

  refresh() {
    widget.callback();
  }
}
