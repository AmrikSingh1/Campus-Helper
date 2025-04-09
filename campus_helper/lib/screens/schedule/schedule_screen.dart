import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_indicator.dart';
import 'schedule_detail_screen.dart';
import 'create_schedule_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleService _scheduleService = ScheduleService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    setState(() => _isLoading = true);
    
    final success = await _scheduleService.deleteSchedule(scheduleId);
    
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete schedule')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'My Schedules'),
            Tab(icon: Icon(Icons.people), text: 'Participating'),
            Tab(icon: Icon(Icons.public), text: 'Public'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserSchedules(),
          _buildParticipatingSchedules(),
          _buildPublicSchedules(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateScheduleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserSchedules() {
    return StreamBuilder<List<Schedule>>(
      stream: _scheduleService.getUserSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final schedules = snapshot.data ?? [];
        
        if (schedules.isEmpty) {
          return const Center(child: Text('You haven\'t created any schedules yet'));
        }
        
        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(schedule, isOwner: true);
          },
        );
      },
    );
  }

  Widget _buildParticipatingSchedules() {
    return StreamBuilder<List<Schedule>>(
      stream: _scheduleService.getParticipatingSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final schedules = snapshot.data ?? [];
        
        if (schedules.isEmpty) {
          return const Center(child: Text('You are not participating in any schedules'));
        }
        
        return ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(schedule);
          },
        );
      },
    );
  }

  Widget _buildPublicSchedules() {
    final currentUser = Provider.of<AuthService>(context).currentUser;

    return StreamBuilder<List<Schedule>>(
      stream: _scheduleService.getPublicSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final schedules = snapshot.data ?? [];
        
        if (schedules.isEmpty) {
          return const Center(child: Text('No public schedules available'));
        }
        
        // Filter out schedules created by the current user
        final filteredSchedules = currentUser != null 
            ? schedules.where((s) => s.ownerId != currentUser.uid).toList()
            : schedules;
            
        if (filteredSchedules.isEmpty) {
          return const Center(child: Text('No public schedules from other users'));
        }
        
        return ListView.builder(
          itemCount: filteredSchedules.length,
          itemBuilder: (context, index) {
            final schedule = filteredSchedules[index];
            final isParticipating = currentUser != null && 
                schedule.participants.contains(currentUser.uid);
            return _buildScheduleCard(
              schedule, 
              isParticipating: isParticipating
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleCard(Schedule schedule, {bool isOwner = false, bool isParticipating = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleDetailScreen(schedule: schedule),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (schedule.isPublic)
                    const Icon(Icons.public, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created by: ${schedule.ownerName}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${_formatDate(schedule.date)}',
                style: const TextStyle(color: Colors.grey),
              ),
              if (schedule.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  schedule.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isOwner)
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        // Navigate to edit screen
                      },
                    )
                  else if (isParticipating)
                    TextButton.icon(
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Leave'),
                      onPressed: () {
                        _scheduleService.leaveSchedule(schedule.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You left the schedule')),
                        );
                      },
                    )
                  else
                    TextButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Join'),
                      onPressed: () {
                        _scheduleService.joinSchedule(schedule.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You joined the schedule')),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 