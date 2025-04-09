import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ResourcesTab extends StatefulWidget {
  const ResourcesTab({Key? key}) : super(key: key);

  @override
  State<ResourcesTab> createState() => _ResourcesTabState();
}

class _ResourcesTabState extends State<ResourcesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Resources'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search resources...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Notes'),
                  Tab(text: 'E-Books'),
                  Tab(text: 'Papers'),
                  Tab(text: 'Videos'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResourceList(_getFilteredNotes()),
          _buildResourceList(_getFilteredBooks()),
          _buildResourceList(_getFilteredPapers()),
          _buildResourceList(_getFilteredVideos()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new resource functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new resource')),
          );
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResourceList(List<Map<String, dynamic>> resources) {
    if (resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.darkGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No resources found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return _buildResourceCard(resource);
      },
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    final IconData iconData = _getIconForResourceType(resource['type'] as String);
    final Color iconColor = _getColorForResourceType(resource['type'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Open the resource
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening: ${resource['title']}')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resource Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Resource Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Subject: ${resource['subject']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added: ${resource['date']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            resource['type'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: iconColor,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.download_outlined),
                          onPressed: () {
                            // TODO: Download the resource
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloading resource...')),
                            );
                          },
                          color: AppColors.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {
                            // TODO: Share the resource
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sharing resource...')),
                            );
                          },
                          color: AppColors.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForResourceType(String type) {
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'PPT':
        return Icons.slideshow;
      case 'DOC':
        return Icons.description;
      case 'Video':
        return Icons.video_library;
      case 'Link':
        return Icons.link;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getColorForResourceType(String type) {
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'PPT':
        return Colors.orange;
      case 'DOC':
        return Colors.blue;
      case 'Video':
        return Colors.purple;
      case 'Link':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  // Sample data for different resource types
  List<Map<String, dynamic>> _getFilteredNotes() {
    final notes = [
      {
        'title': 'Data Structures and Algorithms',
        'subject': 'Computer Science',
        'type': 'PDF',
        'date': 'Apr 15, 2023',
      },
      {
        'title': 'Object-Oriented Programming Concepts',
        'subject': 'Programming',
        'type': 'PPT',
        'date': 'Mar 22, 2023',
      },
      {
        'title': 'Database Management Systems',
        'subject': 'Database',
        'type': 'DOC',
        'date': 'Feb 10, 2023',
      },
      {
        'title': 'Computer Networks',
        'subject': 'Networking',
        'type': 'PDF',
        'date': 'Jan 28, 2023',
      },
    ];

    if (_searchQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      return note['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note['subject'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredBooks() {
    final books = [
      {
        'title': 'Introduction to Algorithms',
        'subject': 'Computer Science',
        'type': 'PDF',
        'date': 'Apr 10, 2023',
      },
      {
        'title': 'Clean Code: A Handbook of Agile Software',
        'subject': 'Programming',
        'type': 'PDF',
        'date': 'Mar 15, 2023',
      },
      {
        'title': 'Design Patterns: Elements of Reusable Object-Oriented Software',
        'subject': 'Software Engineering',
        'type': 'PDF',
        'date': 'Feb 28, 2023',
      },
    ];

    if (_searchQuery.isEmpty) {
      return books;
    }

    return books.where((book) {
      return book['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book['subject'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredPapers() {
    final papers = [
      {
        'title': 'Data Structures Mid-Term 2022',
        'subject': 'Computer Science',
        'type': 'PDF',
        'date': 'Dec 20, 2022',
      },
      {
        'title': 'Object-Oriented Programming Final 2022',
        'subject': 'Programming',
        'type': 'PDF',
        'date': 'Nov 30, 2022',
      },
      {
        'title': 'Database Management Quiz Solutions',
        'subject': 'Database',
        'type': 'DOC',
        'date': 'Oct 15, 2022',
      },
    ];

    if (_searchQuery.isEmpty) {
      return papers;
    }

    return papers.where((paper) {
      return paper['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          paper['subject'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredVideos() {
    final videos = [
      {
        'title': 'Understanding Recursion in Programming',
        'subject': 'Computer Science',
        'type': 'Video',
        'date': 'Apr 5, 2023',
      },
      {
        'title': 'Introduction to Machine Learning',
        'subject': 'AI & ML',
        'type': 'Video',
        'date': 'Mar 20, 2023',
      },
      {
        'title': 'Web Development Full Course',
        'subject': 'Web Development',
        'type': 'Video',
        'date': 'Feb 15, 2023',
      },
      {
        'title': 'Mobile App Development with Flutter',
        'subject': 'Mobile Development',
        'type': 'Video',
        'date': 'Jan 10, 2023',
      },
    ];

    if (_searchQuery.isEmpty) {
      return videos;
    }

    return videos.where((video) {
      return video['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          video['subject'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
} 