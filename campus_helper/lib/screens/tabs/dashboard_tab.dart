import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [AppColors.secondary, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top greeting section
                _buildGreetingSection(context),
                
                const SizedBox(height: 24),
                
                // Quick Stats Cards
                _buildQuickStatsSection(),
                
                const SizedBox(height: 24),
                
                // Upcoming Events Section
                Text(
                  'Upcoming Events',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                
                const SizedBox(height: 16),
                
                _buildUpcomingEventsList(),
                
                const SizedBox(height: 24),
                
                // Recent Activity Section
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                
                const SizedBox(height: 16),
                
                _buildRecentActivities(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    // Get current time to display appropriate greeting
    final hour = DateTime.now().hour;
    String greeting = 'Good ';
    
    if (hour < 12) {
      greeting += 'Morning';
    } else if (hour < 17) {
      greeting += 'Afternoon';
    } else {
      greeting += 'Evening';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkPurple,
              ),
            ),
            Text(
              'John Doe', // Replace with actual user name
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.darkPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: Text(
            'JD', // User initials
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Current CGPA',
          value: '3.8',
          icon: Icons.school,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Attendance',
          value: '87%',
          icon: Icons.calendar_today,
          color: AppColors.accent,
        ),
        _buildStatCard(
          title: 'Assignments',
          value: '3 Due',
          icon: Icons.assignment,
          color: Colors.redAccent,
        ),
        _buildStatCard(
          title: 'Upcoming Exams',
          value: '2',
          icon: Icons.event_note,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkPurple,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsList() {
    final events = [
      {
        'title': 'Data Structures Quiz',
        'date': 'Apr 28, 2023',
        'time': '10:00 AM',
        'type': 'Quiz',
        'color': Colors.amber,
      },
      {
        'title': 'Mobile App Dev Assignment',
        'date': 'May 2, 2023',
        'time': '11:59 PM',
        'type': 'Assignment',
        'color': Colors.redAccent,
      },
      {
        'title': 'Tech Workshop',
        'date': 'May 5, 2023',
        'time': '2:00 PM',
        'type': 'Event',
        'color': Colors.teal,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 12,
              decoration: BoxDecoration(
                color: event['color'] as Color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            title: Text(
              event['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event['date'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event['time'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Chip(
              label: Text(
                event['type'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: event['color'] as Color,
              padding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    final activities = [
      {
        'title': 'Submitted Database Assignment',
        'time': '2 hours ago',
        'icon': Icons.assignment_turned_in,
      },
      {
        'title': 'Viewed Java Programming notes',
        'time': 'Yesterday',
        'icon': Icons.menu_book,
      },
      {
        'title': 'Completed Python Quiz',
        'time': '2 days ago',
        'icon': Icons.quiz,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              activity['icon'] as IconData,
              color: AppColors.primary,
            ),
          ),
          title: Text(
            activity['title'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            activity['time'] as String,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGrey,
            ),
          ),
        );
      },
    );
  }
} 