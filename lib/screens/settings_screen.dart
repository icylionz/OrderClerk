import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:getwidget/components/toggle/gf_toggle.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback refreshCallback;
  SettingsScreen({Key? key, required this.refreshCallback}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          floatingActionButton: Container(
            width: 90,
            height: 50,
            child: FloatingActionButton(
              splashColor: AppTheme.darken(Theme.of(context).accentColor, 0.2),
              hoverColor: AppTheme.darken(Theme.of(context).accentColor, 0.1),
              backgroundColor: Settings.accentColor,
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 5),
                minVerticalPadding: 0,
                horizontalTitleGap: 0,
                leading: Icon(Icons.save,
                    color: Settings.accentColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white),
                title: Text(
                  "Save",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Settings.accentColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white),
                ),
              ),
              shape: const RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              onPressed: Settings.saveSettings,
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Scrollbar(
                    isAlwaysShown: false,
                    child: SingleChildScrollView(
                      child: Scrollbar(
                        isAlwaysShown: false,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: constraints.maxWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Text(
                                    "Settings",
                                    style: AppTheme.myTheme.textTheme.headline1,
                                  ),
                                ),
                                Divider(
                                  endIndent: 6,
                                  indent: 6,
                                  color: Theme.of(context).accentColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Select Company Logo:"),
                                        Text("Toggle Dark Mode"),
                                        GFToggle(
                                            enabledTrackColor:
                                                AppTheme.myTheme.accentColor,
                                            onChanged: (val) {
                                              setState(() {
                                                Settings.darkMode =
                                                    val ?? false;
                                              });
                                              refresh();
                                            },
                                            value: Settings.darkModeVal),
                                        Text("Select Accent Color:"),
                                        CircleColorPicker(
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.color),
                                          controller:
                                              CircleColorPickerController(
                                                  initialColor:
                                                      Settings.accentColor),
                                          onEnded: (color) =>
                                              changeAccent(color),
                                          size: const Size(240, 240),
                                          strokeWidth: 4,
                                          thumbSize: 36,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ));
            },
          ));
    });
  }

  changeAccent(Color color) {
    Settings.accentColor = color;
    AppTheme.myTheme = AppTheme.myTheme.copyWith(accentColor: color);
    AppTheme.darkTheme = AppTheme.darkTheme.copyWith(accentColor: color);
    AppTheme.lightTheme = AppTheme.lightTheme.copyWith(accentColor: color);

    refresh();
  }

  refresh() {
    setState(() {
      widget.refreshCallback();
    });
  }
}
