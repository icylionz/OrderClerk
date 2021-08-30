import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/bloc/distributor_table_bloc/distributors_table_bloc.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:OrderClerk/screens/distributors/add_distributor.dart';
import 'package:OrderClerk/screens/distributors/detail_distributor.dart';
import 'package:OrderClerk/screens/distributors/filter_distributor.dart';

class DistributorsScreen extends StatefulWidget {
  @override
  _DistributorsScreen createState() => _DistributorsScreen();
}

class _DistributorsScreen extends State<DistributorsScreen> {
  bool distributorOverlayVisible = false;
  bool addDistributorOverlayVisible = false;
  bool filterDistributorOverlayVisible = false;
  bool viewDistributorDetailsVisible = false;
  final Map<String, String> nameMap = {
    "name": "Distributor Name",
    "id": "Distributor ID",
    "address": "Address",
    "email": "Email",
    "telephone": "telephone",
  };

  String? where;
  List<dynamic>? whereArgs;
  String distributorSearchDropDownValue = "name";
  late Map<String, dynamic> distributorSearchMap;
  GlobalKey<ScaffoldState> _distributorsView = new GlobalKey<ScaffoldState>();
  GlobalKey<FormBuilderState> _distributorSearchKey =
      new GlobalKey<FormBuilderState>();
  FToast fToast = FToast();
  late int viewDistributorID;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<DistributorsTableBloc>(context)..add(LoadDistributorData());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GFFloatingWidget(
          showBlurness: distributorOverlayVisible,
          child: distributorOverlayVisible
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
                      if (addDistributorOverlayVisible)
                        Container(
                            color: AppTheme.myTheme.scaffoldBackgroundColor,
                            height: constraints.maxHeight / 1.5,
                            width: constraints.maxWidth / 1.5,
                            child: AddDistributor(
                              closeCallback: _resetOverlay,
                            )),
                      if (viewDistributorDetailsVisible)
                        Container(
                            color: AppTheme.myTheme.scaffoldBackgroundColor,
                            height: constraints.maxHeight / 1.5,
                            width: constraints.maxWidth / 1.5,
                            child: DetailDistributor(
                              distributorID: viewDistributorID,
                              callback: () {
                                _resetOverlay();
                              },
                            )),
                      if (filterDistributorOverlayVisible)
                        Container(
                            color: AppTheme.myTheme.scaffoldBackgroundColor,
                            height: constraints.maxHeight / 1.5,
                            width: constraints.maxWidth / 1.5,
                            child: FilterDistributor(
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
            key: _distributorsView,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).accentColor,
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  distributorOverlayVisible = true;
                  addDistributorOverlayVisible = true;
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
  }

  refresh() {
    BlocProvider.of<DistributorsTableBloc>(context)..add(LoadDistributorData());
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        FormBuilder(
          key: _distributorSearchKey,
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
                        border: AppTheme.myTheme.inputDecorationTheme.border),
                    keyboardType: distributorSearchDropDownValue == "name"
                        ? TextInputType.text
                        : TextInputType.number,
                    validator: distributorSearchDropDownValue == "name"
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
                          border: AppTheme.myTheme.inputDecorationTheme.border),
                      initialValue: "name",
                      onChanged: (String? newValue) {
                        setState(() {
                          distributorSearchDropDownValue = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text("Distributor Name"),
                          value: "name",
                        ),
                        DropdownMenuItem(
                          child: Text("Distributor ID"),
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
                distributorOverlayVisible = true;
                filterDistributorOverlayVisible = true;
              });
            },
            icon: Icon(Icons.filter_list)),
        //clear search field and results
        IconButton(
            onPressed: () {
              _distributorSearchKey.currentState!.reset();
              DistributorFilter.delete(
                  entry: DistributorFilter.find(
                      name: nameMap["$distributorSearchDropDownValue"]));
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
    return BlocBuilder<DistributorsTableBloc, DistributorsTableState>(
        builder: (BuildContext context, DistributorsTableState state) {
      if (state is DistributorsTableLoaded)
        return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 100,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(8),
                  childrenPadding: const EdgeInsets.all(12),
                  backgroundColor: AppTheme.darken(
                      AppTheme.myTheme.scaffoldBackgroundColor, 0.1),
                  collapsedBackgroundColor: AppTheme.darken(
                      AppTheme.myTheme.scaffoldBackgroundColor, 0.1),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  expandedAlignment: Alignment.centerLeft,
                  title: Text(state.distributors[index]!.name ?? "null"),
                  trailing: IconButton(
                    icon: Icon(Icons.visibility),
                    onPressed: () {
                      viewDistributorDetails(
                          id: state.distributors[index]!.id!);
                    },
                  ),
                  children: [
                    Text("Address: ${state.distributors[index]!.address}"),
                    Text("Email Address: ${state.distributors[index]!.email}"),
                    Text("Telephone: ${state.distributors[index]!.telephone}"),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemCount: state.distributors.length);

      if (state is DistributorsTableLoading) return CircularProgressIndicator();
      if (state is DistributorsTableError) return Text(state.error);
      return Text(state.toString());
    });
  }

  void _submitForm() {
    _distributorSearchKey.currentState!.save();
    if (_distributorSearchKey.currentState!.validate()) {
      DistributorFilter.add(
          name: nameMap["$distributorSearchDropDownValue"],
          contains: true,
          where: distributorSearchDropDownValue,
          whereArgs: _distributorSearchKey.currentState!.value[
              "whereArgs"]); // if nothing was entered in the search field

    } else {}
    refresh();
  }

  //opens overlay for order details
  void viewDistributorDetails({required int id}) {
    setState(() {
      viewDistributorID = id;
      viewDistributorDetailsVisible = true;
      distributorOverlayVisible = true;
    });
  }

  void _resetOverlay() {
    setState(() {
      distributorOverlayVisible = false;
      addDistributorOverlayVisible = false;
      filterDistributorOverlayVisible = false;
      viewDistributorDetailsVisible = false;
      refresh();
    });
  }
}
