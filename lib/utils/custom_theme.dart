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

  static final timePickerTheme = TimePickerThemeData(
    backgroundColor: Colors.blueGrey,
    hourMinuteShape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Colors.orange, width: 4),
    ),
    dayPeriodBorderSide: const BorderSide(color: Colors.orange, width: 4),
    dayPeriodColor: Colors.blueGrey.shade600,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Colors.orange, width: 4),
    ),
    dayPeriodTextColor: Colors.white,
    dayPeriodShape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Colors.orange, width: 4),
    ),
    hourMinuteColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? Colors.orange
            : Colors.blueGrey.shade800),
    hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected) ? Colors.white : Colors.orange),
    dialHandColor: Colors.blueGrey.shade700,
    dialBackgroundColor: Colors.blueGrey.shade800,
    hourMinuteTextStyle:
        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    dayPeriodTextStyle:
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    helpTextStyle: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      contentPadding: EdgeInsets.all(0),
    ),
    dialTextColor: MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.selected) ? Colors.orange : Colors.white),
    entryModeIconColor: Colors.orange,
  );
}
