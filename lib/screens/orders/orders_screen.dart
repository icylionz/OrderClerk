import 'dart:io';

import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/bloc/order_table_bloc/make_orders_bloc.dart';
import 'package:OrderClerk/data_sources/sources.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;

import 'mini_items_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrdersScreen();
  }
}

class _OrdersScreen extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  bool dialVisible = true;
  GlobalKey<ScaffoldState> _default = new GlobalKey<ScaffoldState>();
  GlobalKey<FormBuilderState> _saveSelectedForm =
      new GlobalKey<FormBuilderState>();
  String? where;
  List<dynamic>? whereArgs;
  String itemSearchDropDownValue = "name";
  Map<String, dynamic> itemSearchMap = new Map();
  FToast fToast = FToast();
  bool itemOverlayVisible = false;
  bool exportOverlayVisible = false;
  final PdfColor _dividerColor = const PdfColor(0.350, 0.350, 0.350);
  double _viewSelectedButtonBarHeight = 50;

  double _totalCostBoxWidth = 160;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MakeOrdersBloc>(context)..add(ViewSelected());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _default,
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (context, constraints) {
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
                              setState(() {
                                itemOverlayVisible = false;
                                exportOverlayVisible = false;
                                refresh();
                              });
                            },
                          ),
                          SizedBox(
                            height: constraints.maxHeight / 1.5,
                            width: constraints.maxWidth / 1.5,
                            child: Container(
                              color: AppTheme.myTheme.scaffoldBackgroundColor,
                              child: Container(),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
              body: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      //top half of the screen holds a modified verison of the items screen
                      Expanded(
                          flex: 5,
                          child: Container(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight / 2,
                            child: MiniItemsScreen(() {
                              refresh();
                            }),
                          )),
                      //bottom half of screen holds the selected items
                      Expanded(
                        flex: 5,
                        child: Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight / 2,
                          child: BlocBuilder<MakeOrdersBloc, MakeOrdersState>(
                            bloc: BlocProvider.of<MakeOrdersBloc>(context),
                            builder: (context, state) {
                              if (state is MakeOrdersLoading)
                                return Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    //Bottom Bar with Total cost and buttons
                                    buildSelectedItemsBottombar(
                                        constraints, state),
                                  ],
                                );

                              if (state is MakeOrdersLoaded)
                                return Column(
                                  children: [
                                    //shows the items selected
                                    buildSelectedList(constraints, state),
                                    //Bottom Bar with Total cost and buttons
                                    buildSelectedItemsBottombar(
                                        constraints, state)
                                  ],
                                );
                              if (state is MakeOrdersError)
                                return Column(
                                  children: [
                                    //shows the items selected
                                    buildSelectedList(constraints, state),
                                    //Bottom Bar with Total cost and buttons
                                    buildSelectedItemsBottombar(
                                        constraints, state)
                                  ],
                                );
                              else
                                return Column(
                                  children: [
                                    //shows the items selected
                                    buildSelectedList(constraints, state),
                                    //Bottom Bar with Total cost and buttons
                                    buildSelectedItemsBottombar(
                                        constraints, state)
                                  ],
                                );
                            },
                          ),
                        ),
                      )
                    ],
                  )));
        }));
  }

  Container buildSelectedItemsBottombar(
      BoxConstraints constraints, MakeOrdersState state) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.lighten(AppTheme.myTheme.scaffoldBackgroundColor, 0.1)
              : AppTheme.darken(AppTheme.myTheme.scaffoldBackgroundColor, 0.2)),
      width: constraints.maxWidth,
      height: _viewSelectedButtonBarHeight,
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        //Submit button
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
          child: SizedBox(
            height: (_viewSelectedButtonBarHeight - 10),
            width: 60,
            child: GFButton(
              buttonBoxShadow: false,
              color: AppTheme.myTheme.accentColor,
              size: 20,
              clipBehavior: Clip.antiAlias,
              text: "Submit Order",
              onPressed: () {
                submitOrder(context, state);
              },
            ),
          ),
        ),
        // Save quantity button
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: SizedBox(
            height: (_viewSelectedButtonBarHeight - 10),
            width: 65,
            child: GFButton(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              buttonBoxShadow: false,
              color: AppTheme.myTheme.accentColor,
              size: 25,
              clipBehavior: Clip.antiAlias,
              text: "Save Quantity",
              onPressed: () {
                if (state is MakeOrdersLoaded)
                  saveSelectedItems(state.selected);
              },
            ),
          ),
        ),
        //Padding
        Expanded(child: Container()),
        //Estimated total cost
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          child: SizedBox(
            height: (_viewSelectedButtonBarHeight - 10),
            width: _totalCostBoxWidth,
            child: Row(children: [
              Container(
                  width: _totalCostBoxWidth * 0.5,
                  child: Text(
                    "Estimated Cost",
                    overflow: TextOverflow.clip,
                    softWrap: true,
                  )),
              Container(
                width: _totalCostBoxWidth * 0.5,
                height: (_viewSelectedButtonBarHeight - 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.lighten(
                            AppTheme.myTheme.scaffoldBackgroundColor, 0.2)
                        : AppTheme.darken(
                            AppTheme.myTheme.scaffoldBackgroundColor, 0.2)),
                child: Center(
                  child: state is MakeOrdersLoaded
                      ? Text("\$${state.totalCost.toStringAsFixed(2)}")
                      : Text(""),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void submitOrder(BuildContext context, MakeOrdersState state) {
    //Creates Database Record
    BlocProvider.of<MakeOrdersBloc>(context)..add(SubmitSelected());
    if (state is MakeOrdersLoaded) {
      _savePDFs(_createPDF(state.selected));
    }

    refresh();
  }

  SizedBox buildSelectedList(
      BoxConstraints constraints, MakeOrdersState state) {
    if (state is MakeOrdersLoaded)
      return SizedBox(
          height: constraints.maxHeight / 2 - _viewSelectedButtonBarHeight,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: 0.3,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white))),
            child: FormBuilder(
              key: _saveSelectedForm,
              child: ListView.builder(
                  itemCount: state.selected.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        subtitle: Text("${state.selected[index]!.item.id}"),
                        title: Text("${state.selected[index]!.item.name}"),
                        leading: SizedBox(
                          width: 50,
                          child: FormBuilderTextField(
                              name: "${state.selected[index]!.item.id}",
                              initialValue: "1",
                              decoration: new InputDecoration(
                                  hintText: "Enter quantity"),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ]),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              removeSelectedItem(
                                  state.selected, index, context);
                            },
                            icon: Icon(Icons.remove)));
                  }),
            ),
          ));
    if (state is MakeOrdersError)
      return SizedBox(
          height: constraints.maxHeight / 2 - _viewSelectedButtonBarHeight,
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(width: 0.3, color: Colors.white))),
            child: Text("An Error has occurred: ${state.error.toString()}"),
          ));
    else
      return SizedBox(
          height: constraints.maxHeight / 2 - _viewSelectedButtonBarHeight,
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(width: 0.3, color: Colors.white))),
            child: Text("You should not be seeing this"),
          ));
  }

  refresh() {
    BlocProvider.of<MakeOrdersBloc>(context)..add(ViewSelected());
  }

  void removeSelectedItem(
      List<SelectedItem?> items, int index, BuildContext context) {
    items.removeAt(index);
    BlocProvider.of<MakeOrdersBloc>(context)..add(UpdateSelected(items: items));
    refresh();
  }

  void saveSelectedItems(List<SelectedItem?> items) {
    _saveSelectedForm.currentState!.save();
    if (_saveSelectedForm.currentState!.validate()) {
      items.forEach((element) {
        element!.quantity = int.parse(
            _saveSelectedForm.currentState!.value[element.item.id.toString()]);
      });
      BlocProvider.of<MakeOrdersBloc>(context)
        ..add(UpdateSelected(items: items));
      refresh();
    } else {}
  }

  List<Map<Distributor, pdf.Document>> _createPDF(List<SelectedItem?> items) {
    List<Map<Distributor, pdf.Document>> pdfDocs = [];

    //creates a pdf for each distributor that associated with a selected item
    DistributorsSource.data.forEach((distro) {
      pdf.Document orderPdf = pdf.Document();
      List<SelectedItem> tempDistroItems = [];
      //compiles all the selected items with the same distributor
      items.forEach((selected) {
        if (selected!.item.distributor!.id == distro!.id) {
          tempDistroItems.add(selected);
        }
      });

      //if the distributor provides any of the selected items then create the pdf
      if (tempDistroItems.length > 0) {
        // builds the pdf
        orderPdf.addPage(
          pdf.MultiPage(
            margin: pdf.EdgeInsets.all(32),
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return <pdf.Widget>[
                //Header with Distributor Info
                pdf.Header(
                    level: 0,
                    child: pdf.Text("${distro!.name}",
                        style: pdf.TextStyle(
                            font: pdf.Font.helveticaBold(),
                            fontSize: 30,
                            fontWeight: pdf.FontWeight.bold))),
                pdf.Header(
                    level: 2,
                    child: pdf.Text(
                      "${distro.telephone} | ${distro.email} | ${distro.address}",
                      style: pdf.TextStyle(font: pdf.Font.helveticaBold()),
                    )),
                pdf.Divider(color: _dividerColor),
                pdf.Row(
                    mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                    children: [
                      pdf.Expanded(
                          flex: 2,
                          child: pdf.Text(
                            "Item Name",
                            style:
                                pdf.TextStyle(font: pdf.Font.helveticaBold()),
                          )),
                      pdf.Expanded(flex: 7, child: pdf.Container()),
                      pdf.Expanded(
                          flex: 1,
                          child: pdf.Text(
                            "Quantity",
                            style:
                                pdf.TextStyle(font: pdf.Font.helveticaBold()),
                          )),
                    ]),
                pdf.Divider(color: _dividerColor),
                pdf.LayoutBuilder(builder: (context, constraints) {
                  return pdf.ListView.separated(
                      itemBuilder: (context, index) {
                        return pdf.Row(
                            mainAxisAlignment:
                                pdf.MainAxisAlignment.spaceBetween,
                            children: [
                              pdf.Expanded(
                                  flex: 2,
                                  child: pdf.Text(
                                    "${tempDistroItems[index].item.name}",
                                    style: pdf.TextStyle(
                                        font: pdf.Font.helveticaBold()),
                                  )),
                              pdf.Expanded(flex: 7, child: pdf.Container()),
                              pdf.Expanded(
                                  flex: 1,
                                  child: pdf.Text(
                                    "${tempDistroItems[index].quantity}",
                                    style: pdf.TextStyle(
                                        font: pdf.Font.helveticaBold()),
                                  )),
                            ]);
                      },
                      separatorBuilder: (context, index) {
                        return pdf.Divider(color: _dividerColor);
                      },
                      itemCount: tempDistroItems.length);
                }),
              ];
            },
          ),
        );

        pdfDocs.add({distro!: orderPdf});
      }
    });

    return pdfDocs;
  }

  _savePDFs(List<Map<Distributor, pdf.Document>> pdfDocs) async {
    SaveFilePicker? filePath;
    File? file;
    pdfDocs.forEach((doc) async {
      //gets file from user
      filePath = SaveFilePicker()
        ..defaultExtension = "pdf"
        ..filterSpecification = {"pdf": "*.pdf"}
        ..fileName =
            "${doc.keys.first.name}_${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}";
      file = filePath!.getFile();

      //saves file
      if (file != null) {
        file!.writeAsBytes(await doc.values.first.save());
      }
    });
  }
}
