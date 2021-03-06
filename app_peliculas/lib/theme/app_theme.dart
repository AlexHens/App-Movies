import 'package:flutter/material.dart';


class AppTheme{

  static const Color primary = Colors.indigo;

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.indigo,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      color: primary,
      elevation: 0,
    ),
  );
}