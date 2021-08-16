import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/bloc/category_table_bloc/categories_table_bloc.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/categories/add_category.dart';
import 'package:OrderClerk/screens/categories/detail_category.dart';
import 'package:OrderClerk/screens/categories/filter_category.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreen createState() => _CategoriesScreen();
}

class _CategoriesScreen extends State<CategoriesScreen> {
  bool categoryOverlayVisible = false;
  bool filterCategoryOverlayVisible = false;
  bool viewCategoryDetailsVisible = false;
  final Map<String, String> nameMap = {
    "name": "Category Name",
    "id": "Category ID",
  };

  String? where;
  List<dynamic>? whereArgs;
  String categorySearchDropDownValue = "name";
  late Map<String, dynamic> categorySearchMap;
  GlobalKey<ScaffoldState> _categoriesView = new GlobalKey<ScaffoldState>();
  GlobalKey<FormBuilderState> _categorySearchKey =
      new GlobalKey<FormBuilderState>();
  FToast fToast = FToast();
  late int viewCategoryID;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<CategoriesTableBloc>(context)..add(LoadCategoryData());
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(child: Builder(builder: (context) {
      return LayoutBuilder(builder: (context, constraints) {
        return GFFloatingWidget(
            showBlurness: categoryOverlayVisible,
            child: categoryOverlayVisible
                ? Container(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _resetOverlay();
                            });
                          },
                        ),
                        if (viewCategoryDetailsVisible)
                          Container(
                              color: Colors.grey[850],
                              height: constraints.maxHeight / 1.5,
                              width: constraints.maxWidth / 1.5,
                              child: DetailCategory(
                                categoryID: viewCategoryID,
                                closeCallback: () {
                                  _resetOverlay();
                                },
                                refreshCallback: refresh,
                              )),
                        if (filterCategoryOverlayVisible)
                          Container(
                              color: Colors.grey[850],
                              height: constraints.maxHeight / 1.5,
                              width: constraints.maxWidth / 1.5,
                              child: FilterCategory(
                                constraints: BoxConstraints(
                                    maxHeight: constraints.maxHeight / 1.5,
                                    maxWidth: constraints.maxWidth / 1.5),
                                closeCallback: _resetOverlay,
                                callback: refresh,
                              )),
                      ],
                    ),
                  )
                : Container(),
            body: Scaffold(
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    //Show Snackbar with Add Category Form
                    final snackBar = SnackBar(
                      elevation: 5,
                      behavior: SnackBarBehavior.fixed,
                      backgroundColor: Colors.grey[850],
                      padding: EdgeInsets.all(00),
                      duration: Duration(days: 365),
                      content: AddCategory(
                        closeCallBack: () {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar();
                        },
                        refreshCallBack: refresh,
                      ),
                    );
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(snackBar);
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
                      Container(width: 400, child: _buildTable()),
                    ],
                  ),
                ),
              ),
            ));
      });
    }));
  }

  refresh() {
    BlocProvider.of<CategoriesTableBloc>(context)..add(LoadCategoryData());
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        FormBuilder(
          key: _categorySearchKey,
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
                    name: "whereArgs",
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
                    keyboardType: categorySearchDropDownValue == "name"
                        ? TextInputType.text
                        : TextInputType.number,
                    validator: categorySearchDropDownValue == "name"
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
                      name: "where",
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          hintText: "Search By:",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 5,
                                  style: BorderStyle.solid,
                                  color: Color.fromRGBO(75, 118, 125, 1.0)))),
                      initialValue: "name",
                      onChanged: (String? newValue) {
                        setState(() {
                          categorySearchDropDownValue = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Category Name"),
                          value: "name",
                        ),
                        DropdownMenuItem(
                          child: Text("Category ID"),
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
              setState(() {
                categoryOverlayVisible = true;
                filterCategoryOverlayVisible = true;
              });
            },
            icon: Icon(Icons.filter_list)),
        //clear search field and results
        IconButton(
            onPressed: () {
              _categorySearchKey.currentState!.reset();
              CategoryFilter.delete(
                  entry: CategoryFilter.find(
                      name: nameMap["$categorySearchDropDownValue"]));
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

  Widget _buildTable() {
    return BlocBuilder<CategoriesTableBloc, CategoriesTableState>(
        builder: (BuildContext context, CategoriesTableState state) {
      if (state is CategoriesTableLoaded)
        return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.white,
                          width: 0.5)),
                  tileColor: Colors.grey[850],
                  title: Text(
                    state.categories[index]!.name ?? "null",
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    style: AppTheme.myTheme.textTheme.headline3,
                  ),
                  onTap: () {
                    viewCategoryDetails(id: state.categories[index]!.id!);
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: state.categories.length);

      if (state is CategoriesTableLoading) return CircularProgressIndicator();
      if (state is CategoriesTableError) return Text(state.error);
      return Text(state.toString());
    });
  }

  void _submitForm() {
    _categorySearchKey.currentState!.save();
    if (_categorySearchKey.currentState!.validate()) {
      CategoryFilter.add(
          name: nameMap["$categorySearchDropDownValue"],
          contains: true,
          where: categorySearchDropDownValue,
          whereArgs: _categorySearchKey.currentState!.value[
              "whereArgs"]); // if nothing was entered in the search field

    } else {}
    refresh();
  }

  //opens overlay for order details
  void viewCategoryDetails({required int id}) {
    setState(() {
      viewCategoryID = id;
      viewCategoryDetailsVisible = true;
      categoryOverlayVisible = true;
    });
  }

  void _resetOverlay() {
    setState(() {
      categoryOverlayVisible = false;
      filterCategoryOverlayVisible = false;
      viewCategoryDetailsVisible = false;
      refresh();
    });
  }
}
