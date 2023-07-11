// import 'dart:collection';

// import 'package:calendar_app_flutter/domain/blocs/events_bloc.dart';
// import 'package:calendar_app_flutter/utils/config.dart';
// import 'package:calendar_app_flutter/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';

// import '../domain/entity/event.dart';

// import '../utils/utils.dart';

// class TableComplexBlocLandscape extends StatefulWidget {
//   const TableComplexBlocLandscape({super.key});

//   @override
//   _TableComplexBlocLandscapeState createState() =>
//       _TableComplexBlocLandscapeState();
// }

// class _TableComplexBlocLandscapeState extends State<TableComplexBlocLandscape> {
//   late final ValueNotifier<List<Event>> _selectedEvents;
//   final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
//   final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
//     equals: isSameDay,
//     hashCode: getHashCode,
//   );
//   final Set<DateTime> _selectedDaysActive = LinkedHashSet<DateTime>(
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
//     _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
//     _selectedDays.add(_focusedDay.value);
//     final EventListViewBloc eventBloc = context.read<EventListViewBloc>();
//     eventBloc.add(EventListEventLoad(
//       getEventsForDaysWidget: _getEventsForDays,
//       selectedDaysWidget: _selectedDays,
//       selectedEventsWidget: _selectedEvents,
//     ));
//     super.initState();
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
//     final EventListViewBloc eventBloc = context.read<EventListViewBloc>();
//     List<Event>? events;
//     if (eventBloc.state is EventListLoaded) {
//       events = eventBloc.state.kEvents[day];
//     }

//     return events ?? [];
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
//       final dateNow = DateTime(kToday.year, kToday.month, kToday.day);
//       final dateSelected =
//           DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

//       if (dateSelected.isAfter(dateNow) ||
//           dateSelected.isAtSameMomentAs(dateNow)) {
//         if (_selectedDaysActive.contains(selectedDay)) {
//           _selectedDaysActive.remove(selectedDay);
//         } else {
//           _selectedDaysActive.add(selectedDay);
//         }
//       }
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
//     required EventListViewBloc eventBloc,
//   }) {
//     eventBloc.add(EventListEventAdd(
//       event: event,
//       day: day,
//       getEventsForDaysWidget: _getEventsForDays,
//       selectedDaysWidget: _selectedDays,
//       selectedEventsWidget: _selectedEvents,
//     ));
//   }

//   void _changeTheme() {
//     setState(() {
//       currentTheme.toggleTheme();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final EventListViewBloc eventBloc = context.watch<EventListViewBloc>();
//     return BlocListener<EventListViewBloc, EventListState>(
//       listener: (context, state) => EventListViewBloc(),
//       child: BlocBuilder<EventListViewBloc, EventListState>(
//           builder: (context, state) {
//         if (state is EventInitial) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else if (state is EventListLoaded) {
//           return Scaffold(
//             floatingActionButton: _selectedDaysActive.isNotEmpty
//                 ? FittedBox(
//                     child: ValueListenableBuilder<List<Event>>(
//                         valueListenable: _selectedEvents,
//                         builder: (context, value, _) {
//                           return FloatingActionButton.extended(
//                             onPressed: () => showDialog(
//                               context: context,
//                               builder: (BuildContext context) =>
//                                   _AlertDialogAddEventWidget(
//                                 eventBloc: eventBloc,
//                                 selectedEvents: value,
//                                 addEvent: _addEventsForDay,
//                                 focusedDay: _selectedDays.last,
//                               ),
//                             ),
//                             icon: const Icon(Icons.add),
//                             label: Text(
//                               "Добавить событие на день: ${_selectedDays.last.day}",
//                               style: const TextStyle(fontSize: 24),
//                             ),
//                           );
//                         }),
//                   )
//                 : const SizedBox.shrink(),
//             appBar: AppBar(
//               backgroundColor: kPrimeyColorGreen,
//               title: const Center(
//                   child: Text(
//                 "Переговорная на 2 этаже",
//                 style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
//               )),
//             ),
//             body: Padding(
//               padding: const EdgeInsets.only(top: 20.0),
//               child: Column(
//                 children: [
//                   ValueListenableBuilder<DateTime>(
//                     valueListenable: _focusedDay,
//                     builder: (context, value, _) {
//                       return _CalendarHeader(
//                         focusedDay: value,
//                         clearButtonVisible: canClearSelection,
//                         onTodayButtonTap: () {
//                           setState(() => _focusedDay.value = DateTime.now());
//                         },
//                         onClearButtonTap: () {
//                           setState(() {
//                             _rangeStart = null;
//                             _rangeEnd = null;
//                             _selectedDays.clear();
//                             _selectedEvents.value = [];
//                           });
//                         },
//                         onLeftArrowTap: () {
//                           _pageController.previousPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeOut,
//                           );
//                         },
//                         onRightArrowTap: () {
//                           _pageController.nextPage(
//                             duration: const Duration(milliseconds: 300),
//                             curve: Curves.easeOut,
//                           );
//                         },
//                         changeTheme: _changeTheme,
//                       );
//                     },
//                   ),
//                   TableCalendar<Event>(
//                     daysOfWeekHeight: 28,
//                     calendarStyle: CalendarStyle(
//                       todayTextStyle: TextStyle(
//                           color: Colors.white, fontSize: fontSizeTextCalendar),
//                       selectedTextStyle: TextStyle(
//                           color: Colors.white, fontSize: fontSizeTextCalendar),
//                       outsideTextStyle: TextStyle(
//                           color: const Color(0xFFAEAEAE),
//                           fontSize: fontSizeTextCalendar),
//                       defaultTextStyle: TextStyle(
//                           color: currentTheme.isDarkTheme
//                               ? Colors.white
//                               : Colors.black,
//                           fontSize: fontSizeTextCalendar),
//                       markerDecoration: BoxDecoration(
//                           color: currentTheme.isDarkTheme
//                               ? Colors.white
//                               : const Color(0xFF263238),
//                           shape: BoxShape.circle),
//                       selectedDecoration: BoxDecoration(
//                           shape: BoxShape.rectangle,
//                           color: const Color(0xFF56BE64),
//                           borderRadius: BorderRadius.circular(10)),
//                       todayDecoration: BoxDecoration(
//                         color: const Color.fromARGB(141, 86, 190, 100),
//                         shape: BoxShape.rectangle,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       holidayDecoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: const Border.fromBorderSide(
//                             BorderSide(color: Color(0xFF56BE64), width: 1.4)),
//                         shape: BoxShape.rectangle,
//                       ),
//                       holidayTextStyle: TextStyle(
//                           color: Colors.red, fontSize: fontSizeTextCalendar),
//                     ),
//                     startingDayOfWeek: StartingDayOfWeek.monday,
//                     locale: 'ru_RU',
//                     firstDay: kFirstDay,
//                     lastDay: kLastDay,
//                     focusedDay: _focusedDay.value,
//                     headerVisible: false,
//                     selectedDayPredicate: (day) => _selectedDays.contains(day),
//                     rangeStartDay: _rangeStart,
//                     rangeEndDay: _rangeEnd,
//                     calendarFormat: _calendarFormat,
//                     rangeSelectionMode: _rangeSelectionMode,
//                     eventLoader: _getEventsForDay,
//                     holidayPredicate: (day) {
//                       if (day.weekday == DateTime.sunday ||
//                           day.weekday == DateTime.saturday) {
//                         return true;
//                       }
//                       return false;
//                     },
//                     onDaySelected: _onDaySelected,
//                     onRangeSelected: _onRangeSelected,
//                     onCalendarCreated: (controller) =>
//                         _pageController = controller,
//                     onPageChanged: (focusedDay) =>
//                         _focusedDay.value = focusedDay,
//                     onFormatChanged: (format) {
//                       if (_calendarFormat != format) {
//                         setState(() => _calendarFormat = format);
//                       }
//                     },
//                     calendarBuilders: CalendarBuilders(
//                       dowBuilder: (context, day) {
//                         if (day.weekday == DateTime.sunday ||
//                             day.weekday == DateTime.saturday) {
//                           final text = DateFormat.E('ru_RU').format(day);
//                           return Center(
//                             child: Text(
//                               text,
//                               style: TextStyle(
//                                   color: Colors.red,
//                                   fontSize: fontSizeTextCalendar),
//                             ),
//                           );
//                         } else {
//                           final text = DateFormat.E('ru_RU').format(day);
//                           return Center(
//                             child: Text(
//                               text,
//                               style: TextStyle(
//                                   color: currentTheme.isDarkTheme
//                                       ? Colors.white
//                                       : const Color(0xFF263238),
//                                   fontSize: fontSizeTextCalendar),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 25.0),
//                   Expanded(
//                     child: ValueListenableBuilder<List<Event>>(
//                       valueListenable: _selectedEvents,
//                       builder: (context, value, _) {
//                         return ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: value.length,
//                           itemBuilder: (context, index) {
//                             return Container(
//                               width: 350,
//                               margin: const EdgeInsets.symmetric(
//                                 horizontal: 12.0,
//                                 vertical: 4.0,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: index % 2 == 0
//                                     ? Colors.white
//                                     : const Color(0xFF56BE64),
//                                 border: Border.all(),
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               child: Stack(children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0,
//                                       right: 16.0,
//                                       bottom: 16.0,
//                                       top: 24.0),
//                                   child: ListTile(
//                                     onTap: () => showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) =>
//                                             _AlertDialogEventInfo()),
//                                     title: Text(
//                                       '${value[index]}',
//                                       style: const TextStyle(
//                                           color: Colors.black, fontSize: 18),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 12.0, top: 12.0),
//                                   child: Align(
//                                     alignment: Alignment.topLeft,
//                                     child: Text(
//                                       '${DateFormat.MMMMd('ru_RU').format(value[index].date!)} ${value[index].time!.format(context)}',
//                                       style: const TextStyle(
//                                           color: Colors.black, fontSize: 16),
//                                     ),
//                                   ),
//                                 ),
//                               ]),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return const Scaffold(
//             body: Center(child: Text('Неизвестаня ошибка')),
//           );
//         }
//       }),
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
//   final void Function() changeTheme;

//   const _CalendarHeader({
//     Key? key,
//     required this.focusedDay,
//     required this.onLeftArrowTap,
//     required this.onRightArrowTap,
//     required this.onTodayButtonTap,
//     required this.onClearButtonTap,
//     required this.clearButtonVisible,
//     required this.changeTheme,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final headerText = DateFormat.yMMM('ru_RU').format(focusedDay);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           const SizedBox(width: 16.0),
//           SizedBox(
//             child: Text(
//               '${headerText[0].toUpperCase()}${headerText.substring(1)}',
//               style: const TextStyle(fontSize: 26.0),
//             ),
//           ),
//           if (clearButtonVisible)
//             IconButton(
//               icon: Icon(Icons.clear, size: sizeIcon),
//               visualDensity: VisualDensity.compact,
//               onPressed: onClearButtonTap,
//             ),
//           IconButton(
//             icon: Icon(Icons.brightness_4, size: sizeIcon),
//             onPressed: () {
//               changeTheme();
//             },
//           ),
//           const Spacer(),
//           IconButton(
//             icon: Icon(Icons.chevron_left, size: sizeIcon),
//             onPressed: onLeftArrowTap,
//           ),
//           IconButton(
//             icon: Icon(Icons.chevron_right, size: sizeIcon),
//             onPressed: onRightArrowTap,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AlertDialogAddEventWidget extends StatefulWidget {
//   final List<Event> selectedEvents;
//   final EventListViewBloc eventBloc;
//   final void Function(
//       {required DateTime day,
//       required Event event,
//       required EventListViewBloc eventBloc}) addEvent;
//   final DateTime focusedDay;
//   const _AlertDialogAddEventWidget({
//     Key? key,
//     required this.selectedEvents,
//     required this.addEvent,
//     required this.focusedDay,
//     required this.eventBloc,
//   }) : super(key: key);

//   @override
//   State<_AlertDialogAddEventWidget> createState() =>
//       _AlertDialogAddEventWidgetState();
// }

// class _AlertDialogAddEventWidgetState
//     extends State<_AlertDialogAddEventWidget> {
//   @override
//   Widget build(BuildContext context) {
//     TextEditingController controller = TextEditingController();

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 500,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   TextField(
//                     decoration: const InputDecoration.collapsed(
//                         hintText: 'Введите событие'),
//                     controller: controller,
//                     style: const TextStyle(color: Colors.black),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   ElevatedButton(
//                       onPressed: () async {
//                         final TimeOfDay? time = await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay.now(),
//                           builder: (BuildContext context, Widget? child) {
//                             return Theme(
//                               data: Theme.of(context).copyWith(
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.padded,
//                               ),
//                               child: MediaQuery(
//                                 data: MediaQuery.of(context).copyWith(
//                                   alwaysUse24HourFormat: true,
//                                 ),
//                                 child: child!,
//                               ),
//                             );
//                           },
//                         );

//                         final event = Event(
//                             title: controller.text,
//                             date: widget.focusedDay,
//                             time: time);
//                         widget.addEvent(
//                             day: widget.focusedDay,
//                             event: event,
//                             eventBloc: widget.eventBloc);

//                         Navigator.of(context).pop();
//                       },
//                       child: const Text(
//                         'Добавить',
//                         style: TextStyle(color: Colors.black),
//                       ))
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AlertDialogEventInfo extends StatelessWidget {
//   const _AlertDialogEventInfo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         padding: EdgeInsets.all(16.0),
//         width: 500,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: const TextSpan(
//                   text: 'Где:\n\nКогда:',
//                   style: TextStyle(color: Colors.black)),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Center(
//                 child: ElevatedButton(
//                     onPressed: () => {Navigator.of(context).pop()},
//                     child: const Text('OK')))
//           ],
//         ),
//       ),
//     );
//   }
// }
