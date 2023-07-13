import 'package:calendar_app_flutter/domain/repository/event_repositort.dart';
import 'package:calendar_app_flutter/pages/complex_example.dart';

import 'package:flutter/material.dart';

class CalendarMainScreen extends StatelessWidget {
  final IRepo repo;
  const CalendarMainScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return Center(
              child: TableComplexBlocLandscapeTest(
            repo: repo,
          ));
        } else {
          return TableComplexBlocLandscapeTest(
            repo: repo,
          );
        }
      },
    );
  }
}
