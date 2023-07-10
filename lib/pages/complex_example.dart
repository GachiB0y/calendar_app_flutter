// import 'dart:collection';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';

// import '../utils.dart';

// class TableComplexExample extends StatefulWidget {
//   @override
//   _TableComplexExampleState createState() => _TableComplexExampleState();
// }

// class _TableComplexExampleState extends State<TableComplexExample> {
//   late final ValueNotifier<List<Event>> _selectedEvents;
//   final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
//   final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
//     equals: isSameDay,
//     hashCode: getHashCode,
//   );

//   late PageController _pageController;
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDays.add(_focusedDay.value);
//     _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
//   }

//   @override
//   void dispose() {
//     _focusedDay.dispose();
//     _selectedEvents.dispose();
//     super.dispose();
//   }

//   bool get canClearSelection =>
//       _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

//   List<Event> _getEventsForDay(DateTime day) {
//     return kEvents[day] ?? [];
//   }

//   List<Event> _getEventsForDays(Iterable<DateTime> days) {
//     return [
//       for (final d in days) ..._getEventsForDay(d),
//     ];
//   }

//   List<Event> _getEventsForRange(DateTime start, DateTime end) {
//     final days = daysInRange(start, end);
//     return _getEventsForDays(days);
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     setState(() {
//       if (_selectedDays.contains(selectedDay)) {
//         _selectedDays.remove(selectedDay);
//       } else {
//         _selectedDays.add(selectedDay);
//       }

//       _focusedDay.value = focusedDay;
//       _rangeStart = null;
//       _rangeEnd = null;
//       _rangeSelectionMode = RangeSelectionMode.toggledOff;
//     });

//     _selectedEvents.value = _getEventsForDays(_selectedDays);

//     print('selectedDay:${selectedDay}');
//   }

//   void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//     setState(() {
//       _focusedDay.value = focusedDay;
//       _rangeStart = start;
//       _rangeEnd = end;
//       _selectedDays.clear();
//       _rangeSelectionMode = RangeSelectionMode.toggledOn;
//     });

//     if (start != null && end != null) {
//       _selectedEvents.value = _getEventsForRange(start, end);
//     } else if (start != null) {
//       _selectedEvents.value = _getEventsForDay(start);
//     } else if (end != null) {
//       _selectedEvents.value = _getEventsForDay(end);
//     }
//   }

//   void _addEventsForDay({
//     required Event event,
//     required DateTime day,
//   }) {
//     setState(() {
//       if (kEvents[day] == null) {
//         final eventsList = <Event>[];
//         eventsList.add(event);
//         final Map<DateTime, List<Event>> kEventSource = {
//           day: eventsList,
//         };
//         kEvents.addAll(kEventSource);
//         print(kEvents[day]);
//       } else {
//         kEvents[day]!.add(event);
//       }
//       _selectedEvents.value = _getEventsForDays(_selectedDays);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.only(top: 50.0),
//         child: Column(
//           children: [
//             ValueListenableBuilder<DateTime>(
//               valueListenable: _focusedDay,
//               builder: (context, value, _) {
//                 return _CalendarHeader(
//                   focusedDay: value,
//                   clearButtonVisible: canClearSelection,
//                   onTodayButtonTap: () {
//                     setState(() => _focusedDay.value = DateTime.now());
//                   },
//                   onClearButtonTap: () {
//                     setState(() {
//                       _rangeStart = null;
//                       _rangeEnd = null;
//                       _selectedDays.clear();
//                       _selectedEvents.value = [];
//                     });
//                   },
//                   onLeftArrowTap: () {
//                     _pageController.previousPage(
//                       duration: Duration(milliseconds: 300),
//                       curve: Curves.easeOut,
//                     );
//                   },
//                   onRightArrowTap: () {
//                     _pageController.nextPage(
//                       duration: Duration(milliseconds: 300),
//                       curve: Curves.easeOut,
//                     );
//                   },
//                 );
//               },
//             ),
//             TableCalendar<Event>(
//               locale: 'ru_RU',
//               firstDay: kFirstDay,
//               lastDay: kLastDay,
//               focusedDay: _focusedDay.value,
//               headerVisible: false,
//               selectedDayPredicate: (day) => _selectedDays.contains(day),
//               rangeStartDay: _rangeStart,
//               rangeEndDay: _rangeEnd,
//               calendarFormat: _calendarFormat,
//               rangeSelectionMode: _rangeSelectionMode,
//               eventLoader: _getEventsForDay,
//               holidayPredicate: (day) {
//                 if (day.weekday == DateTime.sunday ||
//                     day.weekday == DateTime.saturday) {
//                   return true;
//                 }
//                 return false;
//               },
//               onDaySelected: _onDaySelected,
//               onRangeSelected: _onRangeSelected,
//               onCalendarCreated: (controller) => _pageController = controller,
//               onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
//               onFormatChanged: (format) {
//                 if (_calendarFormat != format) {
//                   setState(() => _calendarFormat = format);
//                 }
//               },
//               // calendarBuilders: CalendarBuilders(
//               //   dowBuilder: (context, day) {
//               //     if (day.weekday == DateTime.sunday) {
//               //       final text = DateFormat.E().format(day);
//               //       return Center(
//               //         child: Text(
//               //           text,
//               //           style: TextStyle(color: Colors.red),
//               //         ),
//               //       );
//               //     }
//               //   },
//               // ),
//             ),
//             const SizedBox(height: 8.0),
//             _selectedDays.isNotEmpty
//                 ? ValueListenableBuilder<List<Event>>(
//                     valueListenable: _selectedEvents,
//                     builder: (context, value, _) {
//                       return ElevatedButton.icon(
//                         onPressed: () => showDialog(
//                           context: context,
//                           builder: (BuildContext context) => _AlertDialogWidget(
//                             selectedEvents: value,
//                             addEvent: _addEventsForDay,
//                             focusedDay: _selectedDays.last,
//                           ),
//                         ),
//                         icon: const Icon(Icons.add),
//                         label: Text(
//                             "Добавить событие на день: ${_selectedDays.last.day}"),
//                       );
//                     },
//                   )
//                 : const SizedBox.shrink(),
//             Expanded(
//               child: ValueListenableBuilder<List<Event>>(
//                 valueListenable: _selectedEvents,
//                 builder: (context, value, _) {
//                   return ListView.builder(
//                     itemCount: value.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 12.0,
//                           vertical: 4.0,
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border.all(),
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
//                         child: ListTile(
//                           onTap: () => print('${value[index]}'),
//                           title: Text('${value[index]}'),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CalendarHeader extends StatelessWidget {
//   final DateTime focusedDay;
//   final VoidCallback onLeftArrowTap;
//   final VoidCallback onRightArrowTap;
//   final VoidCallback onTodayButtonTap;
//   final VoidCallback onClearButtonTap;
//   final bool clearButtonVisible;

//   const _CalendarHeader({
//     Key? key,
//     required this.focusedDay,
//     required this.onLeftArrowTap,
//     required this.onRightArrowTap,
//     required this.onTodayButtonTap,
//     required this.onClearButtonTap,
//     required this.clearButtonVisible,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final headerText = DateFormat.yMMM().format(focusedDay);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           const SizedBox(width: 16.0),
//           SizedBox(
//             width: 120.0,
//             child: Text(
//               headerText,
//               style: TextStyle(fontSize: 26.0),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.calendar_today, size: 20.0),
//             visualDensity: VisualDensity.compact,
//             onPressed: onTodayButtonTap,
//           ),
//           if (clearButtonVisible)
//             IconButton(
//               icon: Icon(Icons.clear, size: 20.0),
//               visualDensity: VisualDensity.compact,
//               onPressed: onClearButtonTap,
//             ),
//           const Spacer(),
//           IconButton(
//             icon: Icon(Icons.chevron_left),
//             onPressed: onLeftArrowTap,
//           ),
//           IconButton(
//             icon: Icon(Icons.chevron_right),
//             onPressed: onRightArrowTap,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AlertDialogWidget extends StatefulWidget {
//   final List<Event> selectedEvents;
//   final void Function({required DateTime day, required Event event}) addEvent;
//   final DateTime focusedDay;
//   const _AlertDialogWidget(
//       {Key? key,
//       required this.selectedEvents,
//       required this.addEvent,
//       required this.focusedDay})
//       : super(key: key);

//   @override
//   State<_AlertDialogWidget> createState() => _AlertDialogWidgetState();
// }

// class _AlertDialogWidgetState extends State<_AlertDialogWidget> {
//   @override
//   Widget build(BuildContext context) {
//     TextEditingController _controller = TextEditingController();

//     return Dialog(
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0)), //this right here
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             // height: MediaQuery.of(context).size.height * 0.54,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   TextField(
//                     decoration: const InputDecoration.collapsed(
//                         hintText: 'Введите событие'),
//                     controller: _controller,
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   ElevatedButton(
//                       onPressed: () {
//                         final event = Event(_controller.text);
//                         widget.addEvent(day: widget.focusedDay, event: event);
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text('Добавить'))
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
