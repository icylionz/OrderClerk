import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:OrderClerk/bloc/bloc.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DefaultView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DefaultView();
  }
}

class _DefaultView extends State<DefaultView>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  bool dialVisible = true;
  GlobalKey<ScaffoldState> _default = new GlobalKey<ScaffoldState>();

  String? where;
  List<dynamic>? whereArgs;
  String itemSearchDropDownValue = "name";
  Map<String, dynamic> itemSearchMap = new Map();
  FToast fToast = FToast();
  bool itemOverlayVisible = false;
  bool addItemOverlayVisible = false;
  bool filterItemOverlayVisible = false;
  bool detailItemOverlayVisible = false;
  bool editItemOverlayVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _default,
      backgroundColor: Colors.transparent,
      body: Container(child: _buildTable()),
      endDrawer: Drawer(
        child: Container(
          decoration:
              new BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1.0)),
          child: TextButton(
              child: Text(
                "balls",
              ),
              onPressed: () => _default.currentState!.openEndDrawer()),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return BlocBuilder<ItemsTableBloc, ItemsTableState>(
        builder: (BuildContext context, ItemsTableState state) {
      if (state is ItemsTableLoaded) {
        return Center(
          child: SfDataGrid(
            columnWidthMode: ColumnWidthMode.fill,
            source: BruhDataSource(items: ["1", "2", "3", "4"]),
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
      GridColumn(
          visible: (true),
          columnName: "id",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (true),
          columnName: "name",
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'Name',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (true),
          columnName: "distributorID",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Distributor ID',
                textAlign: TextAlign.center,
              ))),
      GridColumn(
          visible: (true),
          columnName: "distributorName",
          label: Container(
              alignment: Alignment.center,
              child: Text(
                'Distributor Name',
                textAlign: TextAlign.center,
              )))
    ];
  }
}

class BruhDataSource extends DataGridSource {
  List<DataGridRow> _items = [];
  BruhDataSource({required List<String?> items}) {
    _items = items
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'id', value: e),
              DataGridCell<String>(columnName: 'name', value: e),
              DataGridCell<String>(columnName: 'distributorID', value: e),
              DataGridCell<String>(columnName: 'distributorName', value: e),
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
            : Text(dataGridCell.value.toString()),
      );
    }).toList());
  }
}
