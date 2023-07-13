import 'package:calendar_app_flutter/domain/api_client/event_api_client.dart';
import 'package:calendar_app_flutter/domain/blocs/events_bloc.dart';
import 'package:calendar_app_flutter/domain/repository/event_repositort.dart';
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
  final apiClient = EventApiClient();
  late final repo = EventsRepository(characterProvider: apiClient);

  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
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
        create: (context) => EventListViewBloc(eventsRepository: repo),
        child: CalendarMainScreen(
          repo: repo,
        ),
      ),
    );
  }
}
