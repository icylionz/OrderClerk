import 'package:OrderClerk/models/Settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static var lightTheme = ThemeData(
    // Define the default brightness and colors.
    brightness: Brightness.light,
    accentColor: Settings.accentColor,

    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide(
                width: 5, style: BorderStyle.solid, color: Colors.white))),
    // Define the default font family.
    fontFamily: 'Ubuntu',

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 62.0, fontWeight: FontWeight.bold),
      headline2: TextStyle(fontSize: 52.0, fontWeight: FontWeight.bold),
      headline3: TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
      bodyText1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
      bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
    ),
  );
  static var darkTheme = ThemeData(
    // Define the default brightness and colors.
    brightness: Brightness.dark,
    accentColor: Settings.accentColor,

    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide(
                width: 5, style: BorderStyle.solid, color: Colors.white))),
    // Define the default font family.
    fontFamily: 'Ubuntu',

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 62.0, fontWeight: FontWeight.bold),
      headline2: TextStyle(fontSize: 52.0, fontWeight: FontWeight.bold),
      headline3: TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold),
      headline6: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
      bodyText1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
      bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
    ),
  );

  static var myTheme = Settings.darkModeVal ? darkTheme : lightTheme;

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
