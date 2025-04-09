import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({Key? key}) : super(key: key);

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Submitted', 'Late', 'Graded'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Open calendar view
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendar view coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),
          
          // Assignment List
          Expanded(
            child: _getFilteredAssignments().isEmpty
                ? _buildEmptyState()
                : _buildAssignmentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new assignment
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new assignment')),
          );
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FilterChip(
                selected: isSelected,
                label: Text(filter),
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.darkGrey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.darkGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No assignments found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add new assignments or change filters',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList() {
    final assignments = _getFilteredAssignments();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final Color statusColor = _getStatusColor(assignment['status'] as String);
    final IconData statusIcon = _getStatusIcon(assignment['status'] as String);
    final bool isPastDue = _isPastDue(assignment);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Open assignment details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: ${assignment['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          assignment['status'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Course and Points
              Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    assignment['course'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.star_outline,
                    size: 16,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${assignment['points']} points',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Due Date and Progress
              Row(
                children: [
                  // Due date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: isPastDue ? Colors.red : AppColors.darkGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            assignment['dueDate'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isPastDue ? Colors.red : AppColors.darkPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Additional buttons based on status
                  if (assignment['status'] == 'Pending')
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Submit assignment
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Submitting assignment...')),
                        );
                      },
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (assignment['status'] == 'Graded')
                    Row(
                      children: [
                        Icon(
                          Icons.grade,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Grade: ${assignment['grade']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort & Filter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Sort options
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _buildFilterOption('Due Date', Icons.event),
                  _buildFilterOption('Title', Icons.sort_by_alpha),
                  _buildFilterOption('Points', Icons.star),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Filter options
              const Text(
                'Filter by',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _filters.map((filter) {
                  return _buildFilterOption(filter, _getStatusIcon(filter));
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, IconData icon) {
    final bool isSelected = _selectedFilter == label;
    
    return ChoiceChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.darkGrey,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.darkGrey,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  bool _isPastDue(Map<String, dynamic> assignment) {
    // For simplicity, we're just checking if the status is 'Late'
    return assignment['status'] == 'Late';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Submitted':
        return Colors.blue;
      case 'Graded':
        return Colors.green;
      case 'Late':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_actions;
      case 'Submitted':
        return Icons.check_circle;
      case 'Graded':
        return Icons.grade;
      case 'Late':
        return Icons.warning;
      case 'All':
        return Icons.list_alt;
      default:
        return Icons.assignment;
    }
  }

  List<Map<String, dynamic>> _getFilteredAssignments() {
    final assignments = [
      {
        'title': 'Database Design Project',
        'course': 'Database Management',
        'dueDate': 'May 10, 2023',
        'points': 100,
        'status': 'Pending',
      },
      {
        'title': 'Mobile App Prototype',
        'course': 'Mobile Development',
        'dueDate': 'May 5, 2023',
        'points': 50,
        'status': 'Submitted',
      },
      {
        'title': 'Data Structures Quiz',
        'course': 'Advanced Programming',
        'dueDate': 'Apr 28, 2023',
        'points': 20,
        'status': 'Graded',
        'grade': 'A'
      },
      {
        'title': 'Network Security Analysis',
        'course': 'Computer Networks',
        'dueDate': 'Apr 15, 2023',
        'points': 75,
        'status': 'Late',
      },
    ];

    if (_selectedFilter == 'All') {
      return assignments;
    }

    return assignments.where((assignment) {
      return assignment['status'] == _selectedFilter;
    }).toList();
  }
} 