import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EditDistributor extends StatefulWidget {
  final Distributor distributor;
  final Function() callback;
  EditDistributor({required this.distributor, required this.callback});
  @override
  State<StatefulWidget> createState() {
    return _EditDistributor(distributor: distributor, callback: callback);
  }
}

class _EditDistributor extends State<EditDistributor> {
  GlobalKey<FormBuilderState> _editDistributorForm =
      new GlobalKey<FormBuilderState>();
  FToast fToast = FToast();
  Distributor distributor;
  Function() callback;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;

  _EditDistributor({required this.distributor, required this.callback});
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
          children: [
            FormBuilder(
              key: _editDistributorForm,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                //top navigation bar
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //close btn
                    IconButton(
                        tooltip: "Close",
                        onPressed: callback,
                        icon: Icon(Icons.close)),
                    Text(
                      "Edit Distributor",
                      style: AppTheme.myTheme.textTheme.headline6,
                    ),
                    Icon(
                      Icons.close,
                      color: Colors.transparent,
                    ),
                  ],
                ),
                //Name Field
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 40,
                        child: FormBuilderTextField(
                          name: 'name',
                          initialValue: "${distributor.name}",
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
                          initialValue: "${distributor.address}",
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
                          initialValue: "${distributor.address}",
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
                          initialValue: "${distributor.telephone}",
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
                    _editDistributorForm.currentState!.save();
                    if (_editDistributorForm.currentState!.validate()) {
                      try {
                        updateDistributor(
                            _editDistributorForm.currentState!.value);
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

  updateDistributor(Map<String, dynamic> row) async {
    try {
      await DatabaseHelper.instance.update(
          row, "distributors", "id = ?", [widget.distributor.id]).then((value) {
        _showToast(
          child: Text("Distributor Updated: $value"),
          backgroundColor: Colors.green,
          position: ToastGravity.TOP,
        );
      });
    } catch (e) {
      throw e;
    }
  }
}
