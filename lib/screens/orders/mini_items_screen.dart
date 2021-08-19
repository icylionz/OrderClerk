import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/floating_widget/gf_floating_widget.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/bloc/item_table_bloc/items_table_bloc.dart';
import 'package:OrderClerk/bloc/order_table_bloc/make_orders_bloc.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/items/add_item.dart';
import 'package:OrderClerk/screens/items/detail_item.dart';
import 'package:OrderClerk/screens/items/filter_item.dart';
import 'package:OrderClerk/src/queries.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MiniItemsScreen extends StatefulWidget {
  final VoidCallback callback;
  MiniItemsScreen(this.callback);
  @override
  State<StatefulWidget> createState() {
    return _MiniItemsScreen(this.callback);
  }
}

class _MiniItemsScreen extends State<MiniItemsScreen>
    with SingleTickerProviderStateMixin {
  final VoidCallback callback;
  late ScrollController scrollController;
  bool dialVisible = true;
  String? where;
  List<dynamic>? whereArgs;
  String itemSearchDropDownValue = "i.name";
  Map<String, dynamic> itemSearchMap = new Map();
  GlobalKey<FormBuilderState> _itemSearchKey =
      new GlobalKey<FormBuilderState>();
  FToast fToast = FToast();
  bool itemOverlayVisible = false;
  bool addItemOverlayVisible = false;
  bool filterItemOverlayVisible = false;
  bool detailItemOverlayVisible = false;
  bool editItemOverlayVisible = false;
  String? searchFieldFilterName = "Item Name";
  late int itemDetailsID;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  EdgeInsetsGeometry defaultDropDownPadding = EdgeInsets.fromLTRB(8, 2, 8, 2);
  // A map for linking filter names to the display name
  final Map<String, String> nameMap = {
    "i.name": "Item Name",
    "i.id": "Item ID",
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
    "i.lastOrderCancelledID": "Last Order Cancelled ID",
    "o3.dateOrdered": "Last Order Cancelled Date Ordered",
    "o3.dateReceived": "Last Order Cancelled Date Received",
    "o3.dateCancelled": "Last Order Cancelled Date Cancelled",
    "i.toBeOrdered": "To Be Ordered",
  };
  bool dateSelected = false;

  _MiniItemsScreen(this.callback);
  @override
  void initState() {
    super.initState();

    BlocProvider.of<ItemsTableBloc>(context)..add(LoadData());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GFFloatingWidget(
        showBlurness: itemOverlayVisible,
        child: itemOverlayVisible
            ? Container(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _resetOverlays();
                      },
                    ),
                    SizedBox(
                      height: constraints.maxHeight / 1.5,
                      width: constraints.maxWidth / 1.5,
                      child: Container(
                        color: AppTheme.myTheme.scaffoldBackgroundColor,
                        child: addItemOverlayVisible
                            ? AddItem(
                                closeCallBack: _resetOverlays,
                                refreshCallBack: refresh,
                              )
                            : filterItemOverlayVisible
                                ? FilterItem(
                                    constraints: BoxConstraints(
                                        maxHeight: constraints.maxHeight / 1.5,
                                        maxWidth: constraints.maxWidth / 1.5),
                                    callback: refresh,
                                    closeCallback: _resetOverlays,
                                  )
                                : detailItemOverlayVisible
                                    ? DetailItem(
                                        itemID: itemDetailsID,
                                        callback: () {
                                          _resetOverlays();
                                        },
                                      )
                                    : Container(),
                      ),
                    )
                  ],
                ),
              )
            : Container(),
        body: Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              child: Icon(Octicons.package),
              onPressed: () {
                setState(() {
                  itemOverlayVisible = true;
                  addItemOverlayVisible = true;
                });
              },
            ),
            backgroundColor: Colors.transparent,
            body: Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Scrollbar(
                    isAlwaysShown: false,
                    child: SingleChildScrollView(
                      child: Scrollbar(
                        isAlwaysShown: false,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0.0, 0, 0, 15.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          1, 10, 1, 10),
                                      child: SizedBox(
                                        child: _buildSearchBar(),
                                        height: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: 500,
                                  width: 800,
                                  child: _buildTable()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )),
      );
    });
  }

  refresh() {
    BlocProvider.of<ItemsTableBloc>(context)..add(LoadData());
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        FormBuilder(
          key: _itemSearchKey,
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
                    name: "itemSearchText",
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
                        border: AppTheme.myTheme.inputDecorationTheme.border),
                    keyboardType: itemSearchDropDownValue == "i.name"
                        ? TextInputType.text
                        : TextInputType.number,
                    validator: itemSearchDropDownValue == "i.name"
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
                      name: "itemSearchOption",
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                          hintText: "Search By:",
                          border: AppTheme.myTheme.inputDecorationTheme.border),
                      initialValue: "i.name",
                      onChanged: (String? newValue) {
                        setState(() {
                          itemSearchDropDownValue = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Item Name"),
                          value: "i.name",
                        ),
                        DropdownMenuItem(
                          child: Text("Item ID"),
                          value: "i.id",
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
        //filter
        IconButton(
            tooltip: "Filter",
            onPressed: () {
              setState(() {
                filterItemOverlayVisible = true;
                itemOverlayVisible = true;
              });
            },
            icon: Icon(Icons.filter_list)),
        //clear search field and results
        IconButton(
            tooltip: "Clear Search Field",
            onPressed: () {
              _itemSearchKey.currentState!.reset();
              ItemFilter.delete(
                  entry: ItemFilter.find(
                      name:
                          searchFieldFilterName)); // delete the existing search filter

              refresh();
            },
            icon: Icon(Icons.clear)),
        //export
        IconButton(
            tooltip: "Export",
            onPressed: () {},
            icon: Icon(ModernPictograms.export_icon)),
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
    return BlocBuilder<ItemsTableBloc, ItemsTableState>(
        builder: (BuildContext context, ItemsTableState state) {
      if (state is ItemsTableLoaded) {
        return Center(
          child: SfDataGrid(
            selectionMode: SelectionMode.singleDeselect,
            onCellTap: (cellDetails) {
              if (cellDetails.column.columnName == "toBeOrdered") {
                setToBeOrdered(
                    state.items[cellDetails.rowColumnIndex.rowIndex - 1]!);
                refresh();
              } else if (cellDetails.column.columnName == "add") {
                _addSelectedItem(
                    state.items[cellDetails.rowColumnIndex.rowIndex - 1]!);
              } else if (state
                      .items[cellDetails.rowColumnIndex.rowIndex - 1]!.id! >
                  -1)
                setState(() {
                  itemDetailsID =
                      state.items[cellDetails.rowColumnIndex.rowIndex - 1]!.id!;
                  itemOverlayVisible = true;
                  detailItemOverlayVisible = true;
                });
            },
            onSelectionChanged: (rowBefore, rowAfter) {},
            columnWidthMode: ColumnWidthMode.fill,
            source: ItemsDataSource(items: state.items),
            columns: _getColumns(state.itemColumns),
          ),
        );
      }
      if (state is ItemsTableLoading) {
        return CircularProgressIndicator();
      }
      if (state is ItemsTableError) {
        return Text(state.error);
      }
      return Text(state.toString());
    });
  }

  List<GridColumn> _getColumns(List<dynamic> itemColumns) {
    return <GridColumn>[
      GridColumn(visible: true, columnName: "add", label: Container()),
      GridColumn(
          visible: (itemColumns[0]["id"])!,
          columnName: "id",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["name"])!,
          columnName: "name",
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'Name',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["distributorID"])!,
          columnName: "distributorID",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Distributor ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["distributorName"])!,
          columnName: "distributorName",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Distributor Name',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["packageSize"])!,
          columnName: "packageSize",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Package Size',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["costPrice"])!,
          columnName: "costPrice",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Cost Price',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["sellingPrice"])!,
          columnName: "sellingPrice",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Selling Price',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["categoryID"])!,
          columnName: "categoryID",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Category ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["categoryName"])!,
          columnName: "categoryName",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Category Name',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["formulaID"])!,
          columnName: "formulaID",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Formula ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["formulaVari"])!,
          columnName: "formulaVari",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Formula Variable',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["formulaExpression"])!,
          columnName: "formulaExpression",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Formula Expression',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderMadeID"])!,
          columnName: "lastOrderMadeID",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Made ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderMadeDateOrdered"])!,
          columnName: "lastOrderMadeDateOrdered",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Made Date',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderMadeDateReceived"])!,
          columnName: "lastOrderMadeDateReceived",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Made Date Received',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderMadeDateCancelled"])!,
          columnName: "lastOrderMadeDateCancelled",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Made Date Cancelled',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderReceivedID"])!,
          columnName: "lastOrderReceivedID",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Received ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderReceivedDateOrdered"])!,
          columnName: "lastOrderReceivedDateOrdered",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Received Date Ordered',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderReceivedDateReceived"])!,
          columnName: "lastOrderReceivedDateReceived",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Received Date Received',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderReceivedDateCancelled"])!,
          columnName: "lastOrderReceivedDateCancelled",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Last Order Received Date Cancelled',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["lastOrderReceivedExpirationDate"])!,
          columnName: "lastOrderReceivedExpirationDate",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                "Last Order Received Expiration Date",
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (itemColumns[0]["toBeOrdered"])!,
          columnName: "toBeOrdered",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                "To Be Ordered",
                textAlign: TextAlign.center,
              ))),
    ];
  }

  //Submit Button Action for search bar
  void _submitForm() {
    _itemSearchKey.currentState!.save();
    if (_itemSearchKey.currentState!.validate()) {
      ItemFilter.add(
          name: nameMap["$itemSearchDropDownValue"],
          contains: true,
          where: itemSearchDropDownValue,
          whereArgs: _itemSearchKey.currentState!.value[
              "itemSearchText"]); // if nothing was entered in the search field

    } else {}
    refresh();
  }

  void _resetOverlays() {
    setState(() {
      itemOverlayVisible = false;
      addItemOverlayVisible = false;
      filterItemOverlayVisible = false;
      detailItemOverlayVisible = false;
      editItemOverlayVisible = false;
      dateSelected = false;
      refresh();
    });
  }

  void setToBeOrdered(Item item) async {
    await DatabaseHelper.instance.update(
        {"toBeOrdered": item.toBeOrdered! ? 0 : 1},
        "items",
        "id = ?",
        [item.id]);
  }

  void _addSelectedItem(Item item) {
    BlocProvider.of<MakeOrdersBloc>(context)..add(AddSelected(items: [item]));
    callback();
  }
}

//compiles the list of item objects into data rows for the grid table
class ItemsDataSource extends DataGridSource {
  List<DataGridRow> _items = [];
  ItemsDataSource({required List<Item?> items}) {
    _items = items
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<bool>(columnName: 'add', value: true),
              DataGridCell<String>(columnName: 'id', value: e!.id.toString()),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(
                  columnName: 'distributorID',
                  value: e.distributor!.id.toString()),
              DataGridCell<String>(
                  columnName: 'distributorName', value: e.distributor!.name),
              DataGridCell<String>(
                  columnName: 'packageSize', value: e.packageSize),
              DataGridCell<double>(columnName: 'costPrice', value: e.costPrice),
              DataGridCell<double>(
                  columnName: 'sellingPrice', value: e.sellingPrice),
              DataGridCell<int>(
                  columnName: 'categoryID', value: e.category?.id),
              DataGridCell<String>(
                  columnName: 'categoryName', value: e.category?.name),
              DataGridCell<int>(columnName: 'formulaID', value: e.formula?.id),
              DataGridCell<String>(
                  columnName: 'formulaVari', value: e.formula?.vari),
              DataGridCell<String>(
                  columnName: 'formulaExpression', value: e.formula?.expString),
              DataGridCell<int>(
                  columnName: 'lastOrderMadeID', value: e.lastOrderMade?.id),
              DataGridCell<String>(
                  columnName: 'lastOrderMadeDateOrdered',
                  value: e.lastOrderMade?.dateOrdered.toString()),
              DataGridCell<String>(
                  columnName: 'lastOrderMadeDateReceived',
                  value: e.lastOrderMade?.dateReceived.toString()),
              DataGridCell<String>(
                  columnName: 'lastOrderMadeDateCancelled',
                  value: e.lastOrderMade?.dateCancelled.toString()),
              DataGridCell<int>(
                  columnName: 'lastOrderReceivedID',
                  value: e.lastOrderReceived?.id),
              DataGridCell<String>(
                  columnName: 'lastOrderReceivedDateOrdered',
                  value: e.lastOrderReceived?.dateOrdered.toString()),
              DataGridCell<String>(
                  columnName: 'lastOrderReceivedDateReceived',
                  value: e.lastOrderReceived?.dateReceived.toString()),
              DataGridCell<String>(
                  columnName: 'lastOrderReceivedExpirationDate',
                  value: e.lastOrderReceived?.dateExpired.toString()),
              DataGridCell<String>(
                  columnName: 'lastOrderReceivedDateCancelled',
                  value: e.lastOrderReceived?.dateCancelled.toString()),
              DataGridCell<bool>(
                  columnName: 'toBeOrdered', value: e.toBeOrdered),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _items;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: (dataGridCell.columnName ==
                "toBeOrdered") //places an appropiate icon depending on if the item is marked to be ordered.
            ? (dataGridCell.value == true)
                ? Icon(Icons.check_circle)
                : Icon(Icons.highlight_off)
            : (dataGridCell.columnName == "add")
                ? Icon(Icons.add)
                : Text(
                    dataGridCell.value.toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
      );
    }).toList());
  }
}
