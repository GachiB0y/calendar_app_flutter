import 'package:calendar_app_flutter/pages/basics_example.dart';
import 'package:calendar_app_flutter/pages/complex_example.dart';
import 'package:calendar_app_flutter/pages/multi_example.dart';
import 'package:calendar_app_flutter/pages/range_example.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../pages/events_example.dart';

class CalendarMainScreen extends StatelessWidget {
  const CalendarMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TableComplexExample();
  }
}
