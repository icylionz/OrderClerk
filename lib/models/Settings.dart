import 'dart:convert';
import 'dart:io';

import 'package:OrderClerk/assets/styles/styles.dart';
import 'package:OrderClerk/models/Filter.dart';
import 'package:OrderClerk/src/file_handling.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

class Settings {
  static bool darkModeVal = false;
  static String? companyLogoPath;
  static Color accentColor = Color.fromRGBO(0, 0, 0, 1);
  static File configFile =
      File(p.join(FileHandler.dir.path ,"config.json"));
  static Image? logo;
  static set darkMode(bool value) {
    print("going dark");
    darkModeVal = value;
    AppTheme.myTheme = darkModeVal ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  static get companyLogo {
    try {
      return Settings.logo;
    } catch (e) {
      return null;
    }
  }

  static set companyLogo(logo) {
    Settings.logo = logo;
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
    if (!Settings.configFile.existsSync()) {
      Settings.configFile.createSync();
      Settings.configFile.writeAsStringSync(json.encode(content));
    } else {
      Settings.configFile.writeAsStringSync(json.encode(content));
    }
    print("saved");
  }
}
