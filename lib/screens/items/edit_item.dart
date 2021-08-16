import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EditItem extends StatefulWidget {
  final Item item;
  final Function() callback;
  EditItem({required this.item, required this.callback});
  @override
  State<StatefulWidget> createState() {
    return _EditItem(item: item, callback: callback);
  }
}

class _EditItem extends State<EditItem> {
  GlobalKey<FormBuilderState> _editItemForm = new GlobalKey<FormBuilderState>();
  FToast fToast = FToast();
  Item item;
  Function() callback;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;

  _EditItem({required this.item, required this.callback});
  @override
  void initState() {
    loadData();
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
      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  //close btn
                  IconButton(
                      tooltip: "Close",
                      onPressed: callback,
                      icon: Icon(Icons.close)),
                  Text(
                    "Edit Item",
                    style: AppTheme.myTheme.textTheme.headline6,
                  ),
                  Icon(
                    Icons.close,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: FormBuilder(
                key: _editItemForm,
                child: Column(children: [
                  //Name Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderTextField(
                        name: 'name',
                        initialValue: item.name,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Item Name',
                        ),
                        // valueTransformer: (text) => num.tryParse(text),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                          FormBuilderValidators.maxLength(context, 100),
                        ]),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  //Cost Price Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderTextField(
                        name: 'costPrice',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Cost Price',
                        ),
                        initialValue: item.costPrice!.toStringAsFixed(2),
                        valueTransformer: (String? text) =>
                            double.tryParse(text ?? "0.00"),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                          FormBuilderValidators.maxLength(context, 10),
                          FormBuilderValidators.numeric(context),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  //Selling Price Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderTextField(
                        name: 'sellingPrice',
                        initialValue: item.sellingPrice!.toStringAsFixed(2),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Selling Price',
                        ),
                        valueTransformer: (String? text) =>
                            double.tryParse(text ?? "0.00"),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.maxLength(context, 10),
                          FormBuilderValidators.numeric(context),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  //Distributor Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderDropdown(
                        name: 'distributorID',
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Distributor',
                        ),
                        initialValue: item.distributorID,
                        allowClear: false,
                        hint: Text('Select Distributor'),
                        validator: FormBuilderValidators.compose(
                            [FormBuilderValidators.required(context)]),
                        items: DistributorsSource.data
                            .map((distributor) => DropdownMenuItem(
                                  value: distributor!.id,
                                  child: Text('${distributor.name}'),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderTextField(
                        name: 'packageSize',
                        initialValue: item.packageSize,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Package Size',
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.maxLength(context, 100),
                        ]),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  //Category Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderDropdown(
                        name: 'categoryID',
                        initialValue: item.category,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Category',
                        ),
                        // initialValue: 'Male',
                        allowClear: true,
                        hint: Text('Select Category'),
                        items: CategoriesSource.data
                            .map((category) => DropdownMenuItem(
                                  value: category!.id,
                                  child: Text('${category.name}'),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  //Formula Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderDropdown(
                        name: 'formulaID',
                        initialValue: item.formula,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Formula',
                        ),
                        // initialValue: 'Male',
                        allowClear: true,
                        hint: Text('Select Formula'),
                        items: FormulaeSource.data
                            .map((formula) => DropdownMenuItem(
                                  value: formula!.id,
                                  child: Text('${formula.expression}'),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            //Buttons

            Center(
              //Submit Button
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  color: Theme.of(context).accentColor,
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _editItemForm.currentState!.save();
                    if (_editItemForm.currentState!.validate()) {
                      try {
                        updateItem(_editItemForm.currentState!.value);
                      } catch (e) {
                        _showToast(
                            child: Text(
                                "Insertion Failed. Error that occurred: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            position: ToastGravity.BOTTOM,
                            duration: 5);

                        /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Failed to insert: ${e.toString()}"),
                                backgroundColor: Color.fromRGBO(100, 5, 5, 0.5),
                              )); */
                      }
                    } else {
                      /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(""),
                              backgroundColor: Color.fromRGBO(100, 5, 5, 0.5),
                            )); */
                      _showToast(
                        child: Text("Invalid Input"),
                        backgroundColor: Colors.red,
                        position: ToastGravity.BOTTOM,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  loadData() async {
    DistributorsSource.data = await DistributorsSource.pullData();
    CategoriesSource.data = await CategoriesSource.pullData();
    FormulaeSource.data = await FormulaeSource.pullData();
  }

  updateItem(Map<String, dynamic> row) async {
    try {
      await DatabaseHelper.instance
          .update(row, "items", "id = ?", [widget.item.id]).then((value) {
        _showToast(
          child: Text("Item Updated: $value"),
          backgroundColor: Colors.green,
          position: ToastGravity.TOP,
        );
      });
    } catch (e) {
      throw e;
    }
  }
}
