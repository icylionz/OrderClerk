import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AddDistributor extends StatefulWidget {
  void Function() closeCallback;
  AddDistributor({required this.closeCallback});
  @override
  State<StatefulWidget> createState() {
    return _AddDistributor();
  }
}

class _AddDistributor extends State<AddDistributor> {
  GlobalKey<FormBuilderState> _addDistributorForm =
      new GlobalKey<FormBuilderState>();
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
                    onPressed: widget.closeCallback,
                    icon: Icon(Icons.close)),
                Text("Add Distributor",
                    style: AppTheme.myTheme.textTheme.headline6),
                //delete Order
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete,
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),

            FormBuilder(
              key: _addDistributorForm,
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
                            labelText: 'Distributor Name',
                          ),

                          // valueTransformer: (text) => num.tryParse(text),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.maxLength(context, 100),
                          ]),
                          keyboardType: TextInputType.text,
                        ))),
                //Address Field
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 40,
                        child: FormBuilderTextField(
                          name: 'address',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey,
                                    style: BorderStyle.solid)),
                            labelText: 'Address',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.maxLength(context, 200),
                          ]),
                          keyboardType: TextInputType.text,
                        ))),
                //Email Field
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 40,
                        child: FormBuilderTextField(
                          name: 'email',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey,
                                    style: BorderStyle.solid)),
                            labelText: 'Email Address',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.maxLength(context, 50),
                          ]),
                          keyboardType: TextInputType.emailAddress,
                        ))),
                //Telephone Field
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 40,
                        child: FormBuilderTextField(
                          name: 'telephone',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey,
                                    style: BorderStyle.solid)),
                            labelText: 'Telephone Number',
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.maxLength(context, 50),
                          ]),
                          keyboardType: TextInputType.phone,
                        ))),
              ]),
            ),
            //Buttons
            Row(
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
                        _addDistributorForm.currentState!.save();
                        if (_addDistributorForm.currentState!.validate()) {
                          try {
                            insertDistributor(
                                _addDistributorForm.currentState!.value);
                            _addDistributorForm.currentState!.reset();
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
                        _addDistributorForm.currentState!.reset();
                      },
                    ),
                  ),
                ),
              ],
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

  insertDistributor(Map<String, dynamic> row) async {
    try {
      await DatabaseHelper.instance.insert(row, "distributors").then((value) {
        _showToast(
          child: Text("Distributor Inserted: $value"),
          backgroundColor: Colors.green,
          position: ToastGravity.TOP,
        );
      });
    } catch (e) {
      throw e;
    }
  }
}
