import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Schedule schedule;

  const ScheduleDetailScreen({Key? key, required this.schedule}) : super(key: key);

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isOwner = false;
  bool _isParticipating = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      setState(() {
        _isOwner = widget.schedule.ownerId == currentUser.uid;
        _isParticipating = widget.schedule.participants.contains(currentUser.uid);
      });
    }
  }

  Future<void> _joinSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      await _scheduleService.joinSchedule(widget.schedule.id);
      setState(() {
        _isParticipating = true;
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You joined the schedule')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _leaveSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      await _scheduleService.leaveSchedule(widget.schedule.id);
      setState(() {
        _isParticipating = false;
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You left the schedule')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteSchedule() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldDelete) return;

    setState(() => _isLoading = true);
    
    try {
      final success = await _scheduleService.deleteSchedule(widget.schedule.id);
      
      if (!mounted) return;
      
      if (success) {
        Navigator.pop(context, true); // Return true to indicate deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule deleted successfully')),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete schedule')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Details'),
        actions: [
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteSchedule,
              tooltip: 'Delete Schedule',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with public/private indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.schedule.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.schedule.isPublic)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'PUBLIC',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Text(
                            'PRIVATE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Creator and dates
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Created by: ${widget.schedule.ownerName}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(widget.schedule.date)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Created: ${DateFormat('MMM d, yyyy').format(widget.schedule.createdAt)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          if (widget.schedule.updatedAt != widget.schedule.createdAt) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.update, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Updated: ${DateFormat('MMM d, yyyy').format(widget.schedule.updatedAt)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  if (widget.schedule.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.schedule.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Participants
                  Text(
                    'Participants',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: widget.schedule.participants.isEmpty
                          ? const Text('No participants yet')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.schedule.participants
                                  .map((id) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 20),
                                            const SizedBox(width: 8),
                                            Text('Participant ID: $id'),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  if (!_isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(_isParticipating ? Icons.exit_to_app : Icons.person_add),
                        label: Text(_isParticipating ? 'Leave Schedule' : 'Join Schedule'),
                        onPressed: _isLoading ? null : (_isParticipating ? _leaveSchedule : _joinSchedule),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isParticipating ? Colors.red : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
} 