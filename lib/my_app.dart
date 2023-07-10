import 'package:calendar_app_flutter/domain/blocs/events_bloc.dart';
import 'package:calendar_app_flutter/ui/screens/calendar_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<EventListViewBloc>(
        create: (context) => EventListViewBloc(),
        child: const CalendarMainScreen(),
      ),
    );
  }
}
