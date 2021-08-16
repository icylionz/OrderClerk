import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/Filter.dart';

class FilterCategory extends StatefulWidget {
  final BoxConstraints constraints;
  final VoidCallback callback;
  final VoidCallback closeCallback;
  FilterCategory(
      {Key? key,
      required this.constraints,
      required this.callback,
      required this.closeCallback})
      : super(key: key);

  @override
  _FilterCategoryState createState() => _FilterCategoryState();
}

class _FilterCategoryState extends State<FilterCategory> {
  FToast fToast = FToast();
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  GlobalKey<FormBuilderState> _categoryFilterForm =
      new GlobalKey<FormBuilderState>();
  GlobalKey<FormBuilderState> _filterNameKey =
      new GlobalKey<FormBuilderState>();
  final Map<String, String> nameMap = {
    "name": "Category Name",
    "id": "Category ID",
  };
  bool dateSelected = false;
  final EdgeInsetsGeometry defaultDropDownPadding =
      EdgeInsets.fromLTRB(8, 2, 8, 2);

  _FilterCategoryState();

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
                    "Category Filter",
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
                key: _categoryFilterForm,
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
                              2,
                              (index) => DropdownMenuItem(
                                  onTap: () {
                                    setState(() {
                                      nameMap.entries
                                              .elementAt(index)
                                              .key
                                              .contains("date")
                                          ? dateSelected = true
                                          : dateSelected = false;
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
                                        value: "ends", child: Text("Ends In")),
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
                                  FormBuilderValidators.maxLength(context, 100),
                                ]),
                                keyboardType: TextInputType.text,
                              ),
                      ),
                    ),
                    //Add Button creating filter entry
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _categoryFilterForm.currentState!.save();
                            if (_categoryFilterForm.currentState!.validate()) {
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
                          title: Text((CategoryFilter.filter[index]
                                      .name ?? // The field being searched
                                  "null") +
                              " " +
                              (CategoryFilter
                                      .filter[index].isDate // Date Format
                                  ? "between ${CategoryFilter.filter[index].firstDate} and ${CategoryFilter.filter[index].lastDate}"
                                  : ((CategoryFilter.filter[index]
                                              .begins // how the string should be matched with databade records
                                          ? "beginning with"
                                          : CategoryFilter
                                                  .filter[index].contains
                                              ? "containing"
                                              : CategoryFilter
                                                      .filter[index].ends
                                                  ? "ending with"
                                                  : CategoryFilter
                                                          .filter[index].exact
                                                      ? "is"
                                                      : "null") +
                                      "  " +
                                      (CategoryFilter.filter[index].whereArgs ??
                                          "null")))), //the string being searched for
                          trailing: IconButton(
                            icon: Icon(Icons
                                .delete), // icon to delete the filter entry
                            onPressed: () {
                              setState(() {
                                CategoryFilter.delete(
                                    entry: CategoryFilter.filter[index]);
                                refresh();
                              });
                            },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                      itemCount: CategoryFilter.filter.length)),
            ),
          ],
        ),
      ),
    );
  }

  void submitFilter() {
    //creates a date filter entry
    if (dateSelected)
      CategoryFilter.add(
        name: nameMap["${_categoryFilterForm.currentState!.value["where"]}"],
        where: _categoryFilterForm.currentState!.value["where"],
      );
    else
      CategoryFilter.add(
          name: nameMap["${_categoryFilterForm.currentState!.value["where"]}"],
          exact: _categoryFilterForm.currentState!.value["criteria"] == "exact"
              ? true
              : false,
          contains:
              _categoryFilterForm.currentState!.value["criteria"] == "contains"
                  ? true
                  : false,
          begins:
              _categoryFilterForm.currentState!.value["criteria"] == "begins"
                  ? true
                  : false,
          ends: _categoryFilterForm.currentState!.value["criteria"] == "ends"
              ? true
              : false,
          where: _categoryFilterForm.currentState!.value["where"],
          whereArgs: _categoryFilterForm.currentState!.value[
              "whereArgs"]); // if nothing was entered in the search field
    refresh();
  }

  refresh() {
    widget.callback();
  }
}
