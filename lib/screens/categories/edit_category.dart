import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EditCategory extends StatefulWidget {
  final Category category;
  final Function() refreshCallback;
  EditCategory({required this.category, required this.refreshCallback});
  @override
  State<StatefulWidget> createState() {
    return _EditCategory();
  }
}

class _EditCategory extends State<EditCategory> {
  GlobalKey<FormBuilderState> _editCategoryForm =
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
            FormBuilder(
              key: _editCategoryForm,
              child: Column(children: [
                //top navigation bar
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //close btn
                    IconButton(
                        tooltip: "Close",
                        onPressed: () {
                          widget.refreshCallback();
                          ScaffoldMessenger.of(context)..clearSnackBars();
                        },
                        icon: Icon(Icons.close)),
                    Text(
                      "Edit Category",
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
                          initialValue: "${widget.category.name}",
                          decoration: InputDecoration(
                            border: AppTheme.myTheme.inputDecorationTheme.border,
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
                    _editCategoryForm.currentState!.save();
                    if (_editCategoryForm.currentState!.validate()) {
                      try {
                        updateCategory(_editCategoryForm.currentState!.value);
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
    CategoriesSource.data = await CategoriesSource.pullData();
    CategoriesSource.data = await CategoriesSource.pullData();
    FormulaeSource.data = await FormulaeSource.pullData();
  }

  updateCategory(Map<String, dynamic> row) async {
    try {
      await DatabaseHelper.instance.update(
          row, "categories", "id = ?", [widget.category.id]).then((value) {
        _showToast(
          child:
              Text("Category ${widget.category.id} Updated to ${row["name"]}"),
          backgroundColor: Colors.green,
          position: ToastGravity.TOP,
        );
        widget.refreshCallback();
      });
    } catch (e) {
      throw e;
    }
  }
}
