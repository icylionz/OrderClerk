import 'package:OrderClerk/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/bloc/bloc.dart';

class NavBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavBar();
  }
}

class _NavBar extends State<NavBar> {
  final _tileMargin = EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0);

  @override
  Widget build(BuildContext context) {
    print(Settings.companyLogo);
    return Drawer(child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 170) {
          return ListView(
            children: [
              DrawerHeader(
                  child: ClipOval(
                child: Settings.companyLogo ?? Icon(FontAwesome5.user_circle),
              )),
              _buildBigNavMenuItem(
                  event: ViewItemEvent(),
                  tooltip: "Items",
                  icon: Octicons.package),
              _buildBigNavMenuItem(
                  event: ViewDistributorEvent(),
                  tooltip: "Distributors",
                  icon: Linecons.truck),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: Theme.of(context).accentColor,
                  tilePadding: _tileMargin,
                  trailing: SizedBox.shrink(),
                  title: Text("Orders",
                      style: AppTheme.myTheme.textTheme.headline6),
                  leading: Icon(
                    ModernPictograms.basket_alt,
                  ),
                  children: [
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Theme.of(context).accentColor,
                      thickness: 0.5,
                    ),
                    _buildBigNavMenuItem(
                      smallSize: true,
                      event: ViewOrderEvent(),
                      tooltip: "View Orders",
                      icon: Icons.visibility,
                    ),
                    _buildBigNavMenuItem(
                        smallSize: true,
                        event: MakeOrderEvent(),
                        tooltip: "Create Orders",
                        icon: Icons.add),
                  ],
                ),
              ),
              _buildBigNavMenuItem(
                  event: ViewCategoryEvent(),
                  tooltip: "Categories",
                  icon: Linecons.tag),
              _buildBigNavMenuItem(
                  event: ViewSettingsEvent(),
                  tooltip: "Settings",
                  icon: Icons.settings),
            ],
          );
        }
        if (constraints.maxWidth <= 170) {
          return ListView(
            children: [
              DrawerHeader(
                child: Icon(Icons.ac_unit),
              ),
              _buildNavMenuItem(
                  event: ViewItemEvent(),
                  tooltip: "Items",
                  icon: Octicons.package),
              _buildNavMenuItem(
                  event: ViewDistributorEvent(),
                  tooltip: "Distributors",
                  icon: Linecons.truck),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: _tileMargin,
                  trailing: SizedBox.shrink(),
                  title: Text("Orders",
                      style: AppTheme.myTheme.textTheme.headline6),
                  leading: Icon(
                    ModernPictograms.basket_alt,
                    color: AppTheme.myTheme.accentColor,
                  ),
                  children: [
                    Divider(
                      indent: 10,
                      endIndent: 10,
                      color: AppTheme.myTheme.accentColor,
                      thickness: 0.5,
                    ),
                    _buildNavMenuItem(
                      event: ViewOrderEvent(),
                      tooltip: "View Orders",
                      icon: Icons.visibility,
                    ),
                    _buildNavMenuItem(
                        event: MakeOrderEvent(),
                        tooltip: "Create Orders",
                        icon: Icons.add),
                  ],
                ),
              ),
              _buildNavMenuItem(
                  event: ViewCategoryEvent(),
                  tooltip: "Categories",
                  icon: Linecons.tag),
              _buildNavMenuItem(
                  event: ViewSettingsEvent(),
                  tooltip: "Settings",
                  icon: Icons.settings),
            ],
          );
        }
        return ListView(
          children: [
            DrawerHeader(
              child: Icon(Icons.ac_unit),
            ),
            _buildNavMenuItem(
                event: ViewItemEvent(),
                tooltip: "Items",
                icon: Octicons.package),
            _buildNavMenuItem(
                event: ViewDistributorEvent(),
                tooltip: "Distributors",
                icon: Linecons.truck),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: _tileMargin,
                trailing: SizedBox.shrink(),
                title: Icon(
                  ModernPictograms.basket_alt,
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    color: AppTheme.myTheme.accentColor,
                    thickness: 0.5,
                  ),
                  _buildNavMenuItem(
                      event: ViewOrderEvent(),
                      tooltip: "View Orders",
                      icon: Icons.visibility),
                  _buildNavMenuItem(
                      event: MakeOrderEvent(),
                      tooltip: "Make Orders",
                      icon: Icons.add),
                ],
              ),
            ),
            _buildNavMenuItem(
                event: ViewCategoryEvent(),
                tooltip: "Categories",
                icon: Linecons.tag),
            _buildNavMenuItem(
                event: ViewSettingsEvent(),
                tooltip: "Settings",
                icon: Icons.settings),
          ],
        );
      },
    ));
  }

  Widget _buildNavMenuItem(
      {required NavbarEvent event,
      required String tooltip,
      required IconData icon,
      bool smallSize = false}) {
    return Padding(
      padding: _tileMargin,
      child: IconButton(
          icon: Icon(
            icon,
            size: smallSize ? 20 : 24,
          ),
          tooltip: tooltip,
          onPressed: () => changeTo(event)),
    );
  }

  Widget _buildBigNavMenuItem(
      {required NavbarEvent event,
      required String tooltip,
      required IconData icon,
      bool smallSize = false}) {
    return ListTile(
      horizontalTitleGap: smallSize ? 0 : 16,
      contentPadding: _tileMargin,
      leading: Icon(
        icon,
        size: smallSize ? 20 : 24,
      ),
      title: Text(
        tooltip,
        style: smallSize
            ? AppTheme.myTheme.textTheme.bodyText2
            : AppTheme.myTheme.textTheme.headline6,
      ),
      onTap: () => changeTo(event),
    );
  }

  changeTo(NavbarEvent event) {
    final navBloc = BlocProvider.of<NavbarBloc>(context);
    navBloc.add(event);
  }
}
