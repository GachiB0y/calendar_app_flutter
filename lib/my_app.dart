import 'package:calendar_app_flutter/domain/blocs/events_bloc.dart';
import 'package:calendar_app_flutter/ui/screens/calendar_main_screen.dart';
import 'package:calendar_app_flutter/utils/config.dart';
import 'package:calendar_app_flutter/utils/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      //2
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: currentTheme.currentTheme,
      home: BlocProvider<EventListViewBloc>(
        create: (context) => EventListViewBloc(),
        child: const CalendarMainScreen(),
      ),
    );
  }
}
