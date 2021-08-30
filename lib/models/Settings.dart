import 'dart:convert';
import 'dart:io';

import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/Filter.dart';
import 'package:OrderClerk/src/file_handling.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

class Settings {
  static bool darkModeVal = false;
  static String companyLogoPath = "";
  static Color accentColor = Color.fromRGBO(0, 0, 0, 1);

  static set darkMode(bool value) {
    print("going dark");
    darkModeVal = value;
    AppTheme.myTheme = darkModeVal ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  static void saveSettings() {
    var content = {
      "columns": ItemFilter.columns,
      "darkMode": darkModeVal,
      "accentColor": {
        "red": accentColor.red,
        "green": accentColor.green,
        "blue": accentColor.blue
      },
      "companyLogoPath": companyLogoPath
    };
    if (!FileHandler.configFile.existsSync()) {
      FileHandler.configFile.createSync();
      FileHandler.configFile.writeAsStringSync(json.encode(content));
    } else {
      FileHandler.configFile.writeAsStringSync(json.encode(content));
    }
    print("saved");
  }
}
