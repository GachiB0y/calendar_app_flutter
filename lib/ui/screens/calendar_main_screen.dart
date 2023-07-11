import 'package:calendar_app_flutter/pages/complex_example.dart';

import 'package:flutter/material.dart';

class CalendarMainScreen extends StatelessWidget {
  const CalendarMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return const Center(child: TableComplexBlocLandscapeTest());
        } else {
          return const TableComplexBlocLandscapeTest();
        }
      },
    );
  }
}
