import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_event_model.dart';
import '../../services/calendar_service.dart';
import '../../constants/app_colors.dart';
import 'add_event_screen.dart';
import 'edit_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<CalendarEvent>> _events;
  late List<CalendarEvent> _selectedEvents;
  final CalendarService _calendarService = CalendarService();
  bool _isLoading = true;
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _selectedEvents = [];
    _fetchEvents();
  }

  void _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    // Get the events for current month
    final DateTime firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final DateTime lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    Stream<List<CalendarEvent>> eventsStream;

    // If filter is applied, use the appropriate method
    if (_currentFilter != null) {
      eventsStream = _calendarService.getCalendarEventsByType(_currentFilter!);
    } else {
      eventsStream = _calendarService.getCalendarEventsForDateRange(firstDay, lastDay);
    }

    // Listen to events stream
    eventsStream.listen((events) {
      final Map<DateTime, List<CalendarEvent>> eventMap = {};
      
      // Group events by day
      for (final event in events) {
        final DateTime date = DateTime(
          event.startDate.year, 
          event.startDate.month, 
          event.startDate.day,
        );
        
        if (eventMap[date] == null) {
          eventMap[date] = [];
        }
        eventMap[date]!.add(event);
      }
      
      setState(() {
        _events = eventMap;
        _isLoading = false;
        _updateSelectedEvents();
      });
    });
  }

  void _updateSelectedEvents() {
    final DateTime selectedDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    
    setState(() {
      _selectedEvents = _events[selectedDate] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Academic Calendar',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.darkPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (_currentFilter != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(
                                    _currentFilter!.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: _getColorForEventType(_currentFilter!),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _currentFilter = null;
                                    });
                                    _fetchEvents();
                                  },
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: _showFilterDialog,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TableCalendar<CalendarEvent>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        eventLoader: (day) {
                          final normDay = DateTime(day.year, day.month, day.day);
                          return _events[normDay] ?? [];
                        },
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                            _updateSelectedEvents();
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                          _fetchEvents();
                        },
                        calendarStyle: CalendarStyle(
                          markersMaxCount: 3,
                          markerDecoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return null;
                            
                            // Display different colors for different event types
                            return Positioned(
                              bottom: 1,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: events.take(3).map((event) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (event as CalendarEvent).color,
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: _buildEventList(),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventScreen()),
          ).then((result) {
            if (result == true) {
              // Refresh events after adding a new event
              _fetchEvents();
            }
          });
        },
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedEvents.isEmpty) {
      return const Center(
        child: Text('No events for this day.'),
      );
    }

    return ListView.builder(
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: event.color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 12,
              height: double.infinity,
              color: event.color,
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('h:mm a').format(event.startDate)} - ${DateFormat('h:mm a').format(event.endDate)}',
                    ),
                  ],
                ),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(event.location),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Text(
              event.type.toUpperCase(),
              style: TextStyle(
                color: event.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onTap: () => _showEventDetails(event),
          ),
        );
      },
    );
  }

  // Helper method to get color for event type
  Color _getColorForEventType(String type) {
    switch (type) {
      case 'lecture':
        return Colors.blue;
      case 'exam':
        return Colors.red;
      case 'assignment':
        return Colors.orange;
      case 'holiday':
        return Colors.green;
      case 'event':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showEventDetails(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: event.color),
                    ),
                    child: Text(
                      event.type.toUpperCase(),
                      style: TextStyle(
                        color: event.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(event.startDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('h:mm a').format(event.startDate)} - ${DateFormat('h:mm a').format(event.endDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${event.getFormattedDuration()})',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (event.location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Text(
                      event.location,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              if (event.description.isNotEmpty) ...[
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(event.description),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Close the bottom sheet
                      Navigator.pop(context);
                      
                      // Navigate to edit screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEventScreen(event: event),
                        ),
                      ).then((result) {
                        if (result == true) {
                          // Refresh events after editing
                          _fetchEvents();
                        }
                      });
                    },
                    child: const Text('EDIT'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      _calendarService.deleteCalendarEvent(event.id);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'DELETE',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Events'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All Events'),
                  leading: const Icon(Icons.calendar_today),
                  selected: _currentFilter == null,
                  onTap: () {
                    setState(() {
                      _currentFilter = null;
                    });
                    Navigator.pop(context);
                    _fetchEvents();
                  },
                ),
                ListTile(
                  title: const Text('Exams'),
                  leading: Icon(Icons.quiz, color: _getColorForEventType('exam')),
                  selected: _currentFilter == 'exam',
                  onTap: () {
                    setState(() {
                      _currentFilter = 'exam';
                    });
                    Navigator.pop(context);
                    _fetchEvents();
                  },
                ),
                ListTile(
                  title: const Text('Assignments'),
                  leading: Icon(Icons.assignment, color: _getColorForEventType('assignment')),
                  selected: _currentFilter == 'assignment',
                  onTap: () {
                    setState(() {
                      _currentFilter = 'assignment';
                    });
                    Navigator.pop(context);
                    _fetchEvents();
                  },
                ),
                ListTile(
                  title: const Text('Lectures'),
                  leading: Icon(Icons.menu_book, color: _getColorForEventType('lecture')),
                  selected: _currentFilter == 'lecture',
                  onTap: () {
                    setState(() {
                      _currentFilter = 'lecture';
                    });
                    Navigator.pop(context);
                    _fetchEvents();
                  },
                ),
                ListTile(
                  title: const Text('Holidays'),
                  leading: Icon(Icons.celebration, color: _getColorForEventType('holiday')),
                  selected: _currentFilter == 'holiday',
                  onTap: () {
                    setState(() {
                      _currentFilter = 'holiday';
                    });
                    Navigator.pop(context);
                    _fetchEvents();
                  },
                ),
                ListTile(
                  title: const Text('Other Events'),
                  leading: Icon(Icons.event, color: _getColorForEventType('event')),
                  selected: _currentFilter == 'event',
                  onTap: () {
                    setState(() {
                      _currentFilter = 'event';
                    });
                    Navigator.pop(context);
                    _fetchEvents();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }
} 