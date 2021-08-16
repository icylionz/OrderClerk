import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:OrderClerk/bloc/bloc.dart';
import 'package:OrderClerk/screens/categories/categories_screen.dart';
import 'package:OrderClerk/screens/screens.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'nav_bar.dart';

class HomePage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: NavBar(),
      ),
      body: ResponsiveBuilder(builder: (context, sizingInformation) {
        return Row(
          children: [
            if (sizingInformation.screenSize.width > 800)
              Expanded(child: NavBar()),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BlocBuilder<NavbarBloc, NavbarState>(
                    builder: (BuildContext context, NavbarState state) {
                  if (state is BlankState) {
                    return Container(
                      child: Text("Empty"),
                    );
                  } else if (state is DefaultState)
                    return DefaultView();
                  else if (state is ViewItemState)
                    return ItemsScreen();
                  else if (state is ViewDistributorState)
                    return DistributorsScreen();
                  else if (state is ViewOrderState)
                    return ViewOrders();
                  else if (state is MakeOrderState)
                    return OrdersScreen();
                  else if (state is ViewCategoryState)
                    return CategoriesScreen();
                  else
                    return Container(
                      child: Text("Empty"),
                    );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}
