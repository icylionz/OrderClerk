import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AddItem extends StatefulWidget {
  final void Function() closeCallBack;
  final void Function() refreshCallBack;

  const AddItem(
      {Key? key, required this.closeCallBack, required this.refreshCallBack})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _AddItem();
  }
}

class _AddItem extends State<AddItem> {
  GlobalKey<FormBuilderState> _addItemForm = new GlobalKey<FormBuilderState>();
  FToast fToast = FToast();
  late ScrollController _horizontalController;
  late ScrollController _verticalController;

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
          children: [
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                //close btn
                IconButton(
                    tooltip: "Close",
                    onPressed: widget.closeCallBack,
                    icon: Icon(Icons.close)),
                Text(
                  "Add Item",
                  style: AppTheme.myTheme.textTheme.headline6,
                ),
                Icon(
                  Icons.close,
                  color: Colors.transparent,
                ),
              ],
            ),

            Align(
              alignment: Alignment.center,
              child: FormBuilder(
                key: _addItemForm,
                child: Column(children: [
                  //Name Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderTextField(
                        name: 'name',
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
                        initialValue: "0.00",
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
                        // initialValue: 'Male',
                        allowClear: true,
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
                  //Package Size Field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      child: FormBuilderTextField(
                        name: 'packageSize',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey,
                                  style: BorderStyle.solid)),
                          labelText: 'Package Size',
                        ),
                        // valueTransformer: (text) => num.tryParse(text),
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
            Align(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
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
                          _addItemForm.currentState!.save();
                          if (_addItemForm.currentState!.validate()) {
                            try {
                              insertItem(_addItemForm.currentState!.value);
                              _addItemForm.currentState!.reset();
                            } catch (e) {
                              _showToast(
                                  child: Text(
                                      "Insertion Failed. Error that occurred: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                  position: ToastGravity.BOTTOM,
                                  duration: 5);
                            }
                          } else {
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
                  //Padding
                  SizedBox(width: 20),
                  //Reset Button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          "Reset",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _addItemForm.currentState!.reset();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
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

  insertItem(Map<String, dynamic> row) async {
    try {
      await DatabaseHelper.instance.insert(row, "items").then((value) {
        _showToast(
          child: Text("Item Inserted: $value"),
          backgroundColor: Colors.green,
          position: ToastGravity.TOP,
        );
      });
    } catch (e) {
      throw e;
    }
  }
}
