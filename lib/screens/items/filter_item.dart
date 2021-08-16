import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:OrderClerk/screens/items/columnsChoiceChip.dart';

class FilterItem extends StatefulWidget {
  final BoxConstraints constraints;
  final VoidCallback callback;
  final VoidCallback closeCallback;
  FilterItem(
      {required this.constraints,
      required this.callback,
      required this.closeCallback});
  @override
  State<StatefulWidget> createState() {
    return _FilterItem();
  }
}

class _FilterItem extends State<FilterItem> {
  FToast fToast = FToast();
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  GlobalKey<FormBuilderState> _itemFilterForm =
      new GlobalKey<FormBuilderState>();
  GlobalKey<FormBuilderState> _filterNameKey =
      new GlobalKey<FormBuilderState>();
  final Map<String, String> nameMap = {
    "i.name": "Item Name",
    "i.id": "Item ID",
    "i.toBeOrdered": "To Be Ordered",
    "i.distributorID": "Distributor ID",
    "d.name": "Distributor Name",
    "i.packageSize": "Package Size",
    "i.categoryID": "Category ID",
    "c.name": "Category Name",
    "i.costPrice": "Cost Price",
    "i.sellingPrice": "Selling Price",
    "i.formulaID": "Formula ID",
    "f.expString": "Formula Expression",
    "i.lastOrderMadeID": "Last Order Made ID",
    "o1.dateOrdered": "Last Order Made Date Ordered",
    "o1.dateReceived": "Last Order Made Date Received",
    "o1.dateCancelled": "Last Order Made Date Cancelled",
    "i.lastOrderReceivedID": "Last Order Received ID",
    "o2.dateOrdered": "Last Order Received Date Ordered",
    "o2.dateReceived": "Last Order Received Date Received",
    "o2.dateCancelled": "Last Order Received Date Cancelled",
    "o2.expired": "Last Order Received Expired",
    "i.lastOrderCancelledID": "Last Order Cancelled ID",
    "o3.dateOrdered": "Last Order Cancelled Date Ordered",
    "o3.dateReceived": "Last Order Cancelled Date Received",
    "o3.dateCancelled": "Last Order Cancelled Date Cancelled",
  };
  bool dateSelected = false;
  bool boolSelected = false;
  final EdgeInsetsGeometry defaultDropDownPadding =
      EdgeInsets.fromLTRB(8, 2, 8, 2);
  GlobalKey<FormBuilderState> _filterColumnsForm =
      new GlobalKey<FormBuilderState>();

  _FilterItem();

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
            //top navigation
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
                    "Item Filter",
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
                key: _itemFilterForm,
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
                                          .contains("date"))
                                        dateSelected = true;
                                      else if (nameMap.entries
                                                  .elementAt(index)
                                                  .key ==
                                              "i.toBeOrdered" ||
                                          nameMap.entries
                                                  .elementAt(index)
                                                  .key ==
                                              "o2.expired") {
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
                            _itemFilterForm.currentState!.save();
                            if (_itemFilterForm.currentState!.validate()) {
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
                          title: Text((ItemFilter.filter[index]
                                      .name ?? // The field being searched
                                  "null") +
                              " " +
                              (ItemFilter.filter[index].isDate // Date Format
                                  ? "between ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(ItemFilter.filter[index].firstDate!))} and ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(ItemFilter.filter[index].lastDate!))}"
                                  : ItemFilter.filter[index].isBool
                                      ? "Is ${int.parse(ItemFilter.filter[index].whereArgs ?? "0") == 1 ? true : false}"
                                      : ((ItemFilter.filter[index]
                                                  .begins // how the string should be matched with databade records
                                              ? "beginning with"
                                              : ItemFilter
                                                      .filter[index].contains
                                                  ? "containing"
                                                  : ItemFilter
                                                          .filter[index].ends
                                                      ? "ending with"
                                                      : ItemFilter.filter[index]
                                                              .exact
                                                          ? "is"
                                                          : "null") +
                                          "  " +
                                          (ItemFilter.filter[index].whereArgs ??
                                              "null")))), //the string being searched for
                          trailing: IconButton(
                            icon: Icon(Icons
                                .delete), // icon to delete the filter entry
                            onPressed: () {
                              setState(() {
                                ItemFilter.delete(
                                    entry: ItemFilter.filter[index]);
                                refresh();
                              });
                            },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                      itemCount: ItemFilter.filter.length)),
            ),
            //Select Table Columns
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Select Table Columns"),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              width: 250,
              height: widget.constraints.maxHeight / 2.5,
              child: FormBuilder(
                  key: _filterColumnsForm,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      ColumnsChoiceChip(
                          name: "id", display: "ID", callback: refresh),
                      ColumnsChoiceChip(
                          name: "name", display: "Name", callback: refresh),
                      ColumnsChoiceChip(
                          name: "distributorID",
                          display: "Distributor ID",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "distributorName",
                          display: "Distributor Name",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "costPrice",
                          display: "Cost Price",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "sellingPrice",
                          display: "Selling Price",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "categoryID",
                          display: "Category ID",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "categoryName",
                          display: "Category Name",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "formulaID",
                          display: "Formula ID",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "formulaVari",
                          display: "Formula Variable",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "formulaExpression",
                          display: "Formula Expression",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderMadeID",
                          display: "Last Order Made ID",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderMadeDateOrdered",
                          display: "Last Order Made Date Ordered",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderMadeDateReceived",
                          display: "Last Order Made Date Received",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderMadeDateCancelled",
                          display: "Last Order Made Date Cancelled",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderReceivedID",
                          display: "Last Order Received ID",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderReceivedDateOrdered",
                          display: "Last Order Received Date Ordered",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderReceivedDateReceived",
                          display: "Last Order Received Date Received",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderReceivedExpirationDate",
                          display: "Last Order Received Expiration Date",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "lastOrderReceivedDateCancelled",
                          display: "Last Order Received Date Cancelled",
                          callback: refresh),
                      ColumnsChoiceChip(
                          name: "toBeOrdered",
                          display: "To Be Ordered",
                          callback: refresh),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  void submitFilter() {
    setState(() {
      //creates a date filter entry
      if (dateSelected)
        ItemFilter.add(
            name: nameMap["${_itemFilterForm.currentState!.value["where"]}"],
            where: _itemFilterForm.currentState!.value["where"],
            isDate: true,
            firstDate: _itemFilterForm.currentState!.value["firstDate"],
            lastDate: _itemFilterForm.currentState!.value["lastDate"]);
      else if (boolSelected)
        ItemFilter.add(
          name: nameMap["${_itemFilterForm.currentState!.value["where"]}"],
          where: _itemFilterForm.currentState!.value["where"] +
              (_itemFilterForm.currentState!.value["criteria"] == "is"
                  ? " ="
                  : " !="),
          whereArgs:
              _itemFilterForm.currentState!.value["whereArgs"].toString(),
          isBool: true,
        );
      else
        ItemFilter.add(
            name: nameMap["${_itemFilterForm.currentState!.value["where"]}"],
            exact: _itemFilterForm.currentState!.value["criteria"] == "exact"
                ? true
                : false,
            contains:
                _itemFilterForm.currentState!.value["criteria"] == "contains"
                    ? true
                    : false,
            begins: _itemFilterForm.currentState!.value["criteria"] == "begins"
                ? true
                : false,
            ends: _itemFilterForm.currentState!.value["criteria"] == "ends"
                ? true
                : false,
            where: _itemFilterForm.currentState!.value["where"],
            whereArgs: _itemFilterForm.currentState!.value[
                "whereArgs"]); // if nothing was entered in the search field
      refresh();
    });
  }

  refresh() {
    widget.callback();
  }
}
