import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/data_sources/items_source.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/categories/edit_category.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:collection/collection.dart';

class DetailCategory extends StatefulWidget {
  final int categoryID;
  late Category category;
  final Function() closeCallback;
  final Function() refreshCallback;
  DetailCategory(
      {Key? key,
      required this.categoryID,
      required this.refreshCallback,
      required this.closeCallback})
      : super(key: key) {
    this.category = CategoriesSource.extract(id: categoryID);
  }

  @override
  _DetailCategoryState createState() => _DetailCategoryState();
}

class _DetailCategoryState extends State<DetailCategory> {
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  bool categoryDetailsOverlayVisible = false;
  bool confirmDeleteVisible = false;
  bool editOverlayVisible = false;
  FToast fToast = FToast();

  EdgeInsets _itemDetailPadding = const EdgeInsets.all(8);

  _DetailCategoryState() {}
  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
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
    return LayoutBuilder(builder: (context, constraints) {
      return GFFloatingWidget(
        showBlurness: categoryDetailsOverlayVisible,
        child: categoryDetailsOverlayVisible
            ? Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Stack(alignment: Alignment.center, children: [
                  GestureDetector(
                    onTap: () {
                      resetOverlay();
                    },
                  ),
                  confirmDeleteVisible
                      ? Center(
                          child: Container(
                            color: AppTheme.darken(
                                AppTheme.myTheme.scaffoldBackgroundColor),
                            width: constraints.maxWidth - 200,
                            height: constraints.maxHeight - 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Are you sure you want to delete Category #${widget.categoryID}?",
                                  softWrap: true,
                                ),
                                Text(
                                  "N.B This is not the same as cancelling the item!",
                                  style: TextStyle(color: Colors.red),
                                  softWrap: true,
                                ),
                                Center(
                                  child: ButtonBar(
                                    children: [
                                      //yes button
                                      GFButton(
                                        onPressed: () {
                                          if (!isCategoryUsed(
                                              category: widget.category)) {
                                            deleteCategory(widget.categoryID);
                                            setState(() {
                                              widget.refreshCallback();
                                              widget.closeCallback();
                                            });
                                          } else
                                            _showToast(
                                                child: Text(
                                                    "You cannot delete this category because it is being used by item records. Editing the category's information is a better solution."),
                                                backgroundColor: Colors.red,
                                                duration: 5);
                                        },
                                        child: Text("Yes"),
                                      ),
                                      //no button
                                      GFButton(
                                        onPressed: () {
                                          resetOverlay();
                                        },
                                        child: Text("No"),
                                        color: Colors.red,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container()
                ]))
            : Container(),
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
          color: AppTheme.myTheme.scaffoldBackgroundColor,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: SingleChildScrollView(
              child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //top navigation
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //close btn
                    IconButton(
                        tooltip: "Close",
                        onPressed: widget.closeCallback,
                        icon: Icon(Icons.close)),
                    Text(
                      "Category Details",
                    ),
                    //delete Category
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Edit Category",
                          onPressed: () {
                            final snackBar = SnackBar(
                                elevation: 5,
                                behavior: SnackBarBehavior.fixed,
                                backgroundColor:
                                    AppTheme.myTheme.scaffoldBackgroundColor,
                                padding: EdgeInsets.all(00),
                                duration: Duration(days: 365),
                                content: EditCategory(
                                  category: widget.category,
                                  refreshCallback: widget.refreshCallback,
                                ));
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(snackBar);
                            widget.closeCallback();
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          tooltip: "Delete Category",
                          onPressed: () {
                            setState(() {
                              categoryDetailsOverlayVisible = true;
                              confirmDeleteVisible = true;
                            });
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                //Category Details
                Padding(
                  padding: _itemDetailPadding,
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color),
                        children: [
                          TextSpan(
                            text: "Category ID: ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600,color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          ),
                          TextSpan(
                            text: "${widget.category.id}",
                          ),
                        ]),
                  ),
                ),
                Padding(
                    padding: _itemDetailPadding,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          children: [
                            TextSpan(
                              text: "Category Name: ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600,color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                            ),
                            TextSpan(
                              text: "${widget.category.name}",
                            ),
                          ]),
                    )),

                Divider(
                  endIndent: 5,
                  indent: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Items in ${widget.category.name} category: ",
                    style: TextStyle(fontWeight: FontWeight.w600,color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                  ),
                ),
                Container(
                  color: AppTheme.darken(
                      AppTheme.myTheme.scaffoldBackgroundColor, 0.2),
                  width: constraints.maxWidth - (_itemDetailPadding.left * 2),
                  height: 600,
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                            leading:
                                Text("#${widget.category.items[index]!.id}"),
                            title:
                                Text("${widget.category.items[index]!.name}"),
                            trailing: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color:
                                  Theme.of(context).textTheme.bodyText1!.color,
                                      fontWeight: FontWeight.normal),
                                  text: "Pkg Size:  ",
                                  children: [
                                    TextSpan(
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      text:
                                          "${widget.category.items[index]!.packageSize}",
                                    ),
                                  ]),
                            ));
                      },
                      separatorBuilder: (context, index) => Divider(
                            indent: 10,
                            endIndent: 10,
                          ),
                      itemCount: widget.category.items.length),
                ),
              ],
            ),
          )),
        ),
      );
    });
  }

  deleteCategory(int categoryID) {
    DatabaseHelper.instance.delete(
        tableName: "categories", where: "id = ?", whereArgs: [categoryID]);
  }

  bool isCategoryUsed({required Category category}) {
    return ItemsSource.data.firstWhereOrNull(
                (element) => element!.category == category ? true : false) !=
            null
        ? true
        : false;
  }

  void resetOverlay() {
    setState(() {
      categoryDetailsOverlayVisible = false;
      editOverlayVisible = false;
      confirmDeleteVisible = false;
    });
  }
}
