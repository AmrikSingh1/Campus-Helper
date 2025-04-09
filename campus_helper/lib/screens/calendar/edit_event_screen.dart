import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/calendar_event_model.dart';
import '../../services/calendar_service.dart';
import '../../services/notification_service.dart';

class EditEventScreen extends StatefulWidget {
  final CalendarEvent event;

  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  
  late bool _isAllDay;
  late String _selectedType;
  late String _selectedDepartment;
  late int _selectedSemester;
  
  late Color _selectedColor;
  final List<Color> _eventColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];
  
  final CalendarService _calendarService = CalendarService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing event data
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    
    // Initialize date and time
    _startDate = widget.event.startDate;
    _startTime = TimeOfDay(
      hour: widget.event.startDate.hour,
      minute: widget.event.startDate.minute,
    );
    
    _endDate = widget.event.endDate;
    _endTime = TimeOfDay(
      hour: widget.event.endDate.hour,
      minute: widget.event.endDate.minute,
    );
    
    // Initialize other properties
    _isAllDay = widget.event.isAllDay;
    _selectedType = widget.event.type;
    _selectedDepartment = widget.event.department;
    _selectedSemester = widget.event.semester;
    _selectedColor = widget.event.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Update end date to be at least the start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Combine date and time
        final startDateTime = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          _isAllDay ? 0 : _startTime.hour,
          _isAllDay ? 0 : _startTime.minute,
        );

        final endDateTime = DateTime(
          _endDate.year,
          _endDate.month,
          _endDate.day,
          _isAllDay ? 23 : _endTime.hour,
          _isAllDay ? 59 : _endTime.minute,
        );

        // Create updated event from the existing one
        final updatedEvent = widget.event.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          startDate: startDateTime,
          endDate: endDateTime,
          location: _locationController.text,
          type: _selectedType,
          color: _selectedColor,
          department: _selectedDepartment,
          semester: _selectedSemester,
          isAllDay: _isAllDay,
          updatedAt: DateTime.now(),
        );

        // Update the event in Firestore
        await _calendarService.updateCalendarEvent(updatedEvent);
        
        // Create a notification about the update
        final notificationService = NotificationService();
        
        // Create notification
        await notificationService.createSystemNotification(
          'Event Updated',
          'Your event "${_titleController.text}" has been updated.'
        );
        
        // If start date changed, update the reminder
        if (widget.event.startDate != startDateTime) {
          await notificationService.scheduleEventReminder(updatedEvent);
        }
        
        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Event Type Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(value: 'lecture', child: Text('Lecture')),
                        DropdownMenuItem(value: 'exam', child: Text('Exam')),
                        DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                        DropdownMenuItem(value: 'holiday', child: Text('Holiday')),
                        DropdownMenuItem(value: 'event', child: Text('Other Event')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          
                          // Set color based on type
                          switch (value) {
                            case 'lecture':
                              _selectedColor = Colors.blue;
                              break;
                            case 'exam':
                              _selectedColor = Colors.red;
                              break;
                            case 'assignment':
                              _selectedColor = Colors.orange;
                              break;
                            case 'holiday':
                              _selectedColor = Colors.green;
                              break;
                            case 'event':
                              _selectedColor = Colors.purple;
                              break;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Department Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedDepartment,
                      items: const [
                        DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                        DropdownMenuItem(value: 'Electrical Engineering', child: Text('Electrical Engineering')),
                        DropdownMenuItem(value: 'Mechanical Engineering', child: Text('Mechanical Engineering')),
                        DropdownMenuItem(value: 'Civil Engineering', child: Text('Civil Engineering')),
                        DropdownMenuItem(value: 'Business Administration', child: Text('Business Administration')),
                        DropdownMenuItem(value: 'All Departments', child: Text('All Departments')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Semester Dropdown
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSemester,
                      items: List.generate(8, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text('Semester ${index + 1}'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // All Day Toggle
                    SwitchListTile(
                      title: const Text('All Day Event'),
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Date & Time Selection
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectStartDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_startDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (!_isAllDay)
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectStartTime(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Time',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _startTime.format(context),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectEndDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_endDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (!_isAllDay)
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectEndTime(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Time',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _endTime.format(context),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Color Selection
                    Text(
                      'Event Color',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: _eventColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (_selectedColor == color)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'UPDATE EVENT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 