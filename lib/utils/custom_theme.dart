import 'package:calendar_app_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomTheme with ChangeNotifier {
  static bool _isDarkTheme = false;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkTheme {
    return _isDarkTheme;
  }

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: kPrimeyColorGreen,
      scaffoldBackgroundColor: Colors.white,
      textTheme: ThemeData.light().textTheme,
      iconTheme: const IconThemeData(color: Colors.black),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimeyColorGreen),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: kPrimeyColorGreen,
      scaffoldBackgroundColor: const Color.fromARGB(206, 54, 54, 54),
      textTheme: ThemeData.dark().textTheme,
      iconTheme: const IconThemeData(color: Colors.white),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimeyColorGreen),
    );
  }
}
