import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AddCategory extends StatefulWidget {
  final void Function() closeCallBack;
  final void Function() refreshCallBack;

  const AddCategory(
      {Key? key, required this.closeCallBack, required this.refreshCallBack})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _AddCategory();
  }
}

class _AddCategory extends State<AddCategory> {
  GlobalKey<FormBuilderState> _addCategoryForm =
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
                  "Add Category",
                  style: AppTheme.myTheme.textTheme.headline6,
                ),
                Icon(
                  Icons.close,
                  color: Colors.transparent,
                ),
              ],
            ),

            FormBuilder(
              key: _addCategoryForm,
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
                            labelText: 'Category Name',
                          ),

                          // valueTransformer: (text) => num.tryParse(text),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.maxLength(context, 100),
                          ]),
                          keyboardType: TextInputType.text,
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
                        _addCategoryForm.currentState!.save();
                        if (_addCategoryForm.currentState!.validate()) {
                          try {
                            insertCategory(
                                _addCategoryForm.currentState!.value);
                            _addCategoryForm.currentState!.reset();
                            widget.refreshCallBack();
                            widget.closeCallBack();
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
                        _addCategoryForm.currentState!.reset();
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
    CategoriesSource.data = await CategoriesSource.pullData();
  }

  insertCategory(Map<String, dynamic> row) async {
    try {
      await DatabaseHelper.instance.insert(row, "categories");
    } catch (e) {
      throw e;
    }
  }
}
