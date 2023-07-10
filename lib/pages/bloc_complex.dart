import 'dart:collection';

import 'package:calendar_app_flutter/domain/blocs/events_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../domain/entity/event.dart';

import '../utils.dart';

class TableComplexExampleBloc extends StatefulWidget {
  const TableComplexExampleBloc({super.key});

  @override
  _TableComplexExampleBlocState createState() =>
      _TableComplexExampleBlocState();
}

class _TableComplexExampleBlocState extends State<TableComplexExampleBloc> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    _selectedDays.add(_focusedDay.value);
    final EventListViewBloc eventBloc = context.read<EventListViewBloc>();
    eventBloc.add(EventListEventLoad(
      getEventsForDaysWidget: _getEventsForDays,
      selectedDaysWidget: _selectedDays,
      selectedEventsWidget: _selectedEvents,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;
  List<Event> _getEventsForDay(DateTime day) {
    final EventListViewBloc eventBloc = context.read<EventListViewBloc>();
    List<Event>? events;
    if (eventBloc.state is EventListLoaded) {
      events = eventBloc.state.kEvents[day];
    }

    return events ?? [];
  }

  List<Event> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }

      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDays.clear();
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  void _addEventsForDay({
    required Event event,
    required DateTime day,
    required EventListViewBloc eventBloc,
  }) {
    eventBloc.add(EventListEventAdd(
      event: event,
      day: day,
      getEventsForDaysWidget: _getEventsForDays,
      selectedDaysWidget: _selectedDays,
      selectedEventsWidget: _selectedEvents,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final EventListViewBloc eventBloc = context.watch<EventListViewBloc>();
    return BlocListener<EventListViewBloc, EventListState>(
      listener: (context, state) => EventListViewBloc(),
      child: BlocBuilder<EventListViewBloc, EventListState>(
          builder: (context, state) {
        if (state is EventInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is EventListLoaded) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  ValueListenableBuilder<DateTime>(
                    valueListenable: _focusedDay,
                    builder: (context, value, _) {
                      return _CalendarHeader(
                        focusedDay: value,
                        clearButtonVisible: canClearSelection,
                        onTodayButtonTap: () {
                          setState(() => _focusedDay.value = DateTime.now());
                        },
                        onClearButtonTap: () {
                          setState(() {
                            _rangeStart = null;
                            _rangeEnd = null;
                            _selectedDays.clear();
                            _selectedEvents.value = [];
                          });
                        },
                        onLeftArrowTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        onRightArrowTap: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                      );
                    },
                  ),
                  TableCalendar<Event>(
                    availableCalendarFormats: {CalendarFormat.month: "Июль"},
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                          color: Color(0xFF56BE64), shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                          color: Color.fromARGB(141, 86, 190, 100),
                          shape: BoxShape.circle),
                      holidayDecoration: BoxDecoration(
                          border: Border.fromBorderSide(
                              BorderSide(color: Color(0xFF56BE64), width: 1.4)),
                          shape: BoxShape.circle),
                    ),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: 'ru_RU',
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay.value,
                    headerVisible: false,
                    selectedDayPredicate: (day) => _selectedDays.contains(day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    calendarFormat: _calendarFormat,
                    rangeSelectionMode: _rangeSelectionMode,
                    eventLoader: _getEventsForDay,
                    holidayPredicate: (day) {
                      if (day.weekday == DateTime.sunday ||
                          day.weekday == DateTime.saturday) {
                        return true;
                      }
                      return false;
                    },
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onCalendarCreated: (controller) =>
                        _pageController = controller,
                    onPageChanged: (focusedDay) =>
                        _focusedDay.value = focusedDay,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() => _calendarFormat = format);
                      }
                    },
                    // calendarBuilders: CalendarBuilders(
                    //   dowBuilder: (context, day) {
                    //     if (day.weekday == DateTime.sunday) {
                    //       final text = DateFormat.E().format(day);
                    //       return Center(
                    //         child: Text(
                    //           text,
                    //           style: TextStyle(color: Colors.red),
                    //         ),
                    //       );
                    //     }
                    //   },
                    // ),
                  ),
                  const SizedBox(height: 8.0),
                  _selectedDays.isNotEmpty
                      ? ValueListenableBuilder<List<Event>>(
                          valueListenable: _selectedEvents,
                          builder: (context, value, _) {
                            return ElevatedButton.icon(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _AlertDialogWidget(
                                  eventBloc: eventBloc,
                                  selectedEvents: value,
                                  addEvent: _addEventsForDay,
                                  focusedDay: _selectedDays.last,
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: Text(
                                "Добавить событие на день: ${_selectedDays.last.day}",
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                  Expanded(
                    child: ValueListenableBuilder<List<Event>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.white
                                    : const Color(0xFF56BE64),
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                onTap: () => print('${value[index]}'),
                                title: Text('${value[index]}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Неизвестаня ошибка')),
          );
        }
      }),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM('ru_RU').format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            child: Text(
              '${headerText[0].toUpperCase()}${headerText.substring(1)}',
              style: const TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: const Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}

class _AlertDialogWidget extends StatefulWidget {
  final List<Event> selectedEvents;
  final EventListViewBloc eventBloc;
  final void Function(
      {required DateTime day,
      required Event event,
      required EventListViewBloc eventBloc}) addEvent;
  final DateTime focusedDay;
  const _AlertDialogWidget({
    Key? key,
    required this.selectedEvents,
    required this.addEvent,
    required this.focusedDay,
    required this.eventBloc,
  }) : super(key: key);

  @override
  State<_AlertDialogWidget> createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<_AlertDialogWidget> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            // height: MediaQuery.of(context).size.height * 0.54,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Введите событие'),
                    controller: controller,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        final event = Event(controller.text);
                        widget.addEvent(
                            day: widget.focusedDay,
                            event: event,
                            eventBloc: widget.eventBloc);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Добавить',
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
