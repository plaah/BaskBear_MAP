import 'package:flutter/material.dart';

class BrowseSessionScreen extends StatefulWidget {
  const BrowseSessionScreen({super.key});

  @override
  State<BrowseSessionScreen> createState() => _BrowseSessionScreenState();
}

class _BrowseSessionScreenState extends State<BrowseSessionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Design',
    'Development',
    'Business',
    'Marketing',
    'Photography'
  ];

  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'UI/UX Design Fundamentals',
      'instructor': 'Sophia Yeshi',
      'price': '\$49.99',
      'rating': 4.8,
      'students': 1245,
      'image':
      'https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=400&q=80',
      'category': 'Design',
      'duration': '5h 20m',
    },
    {
      'title': 'Python for Beginners',
      'instructor': 'John Doe',
      'price': '\$39.99',
      'rating': 4.7,
      'students': 892,
      'image':
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=400&q=80',
      'category': 'Development',
      'duration': '8h 15m',
    },
    {
      'title': 'Digital Marketing 101',
      'instructor': 'Jane Smith',
      'price': '\$59.99',
      'rating': 4.9,
      'students': 2103,
      'image':
      'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?auto=format&fit=crop&w=400&q=80',
      'category': 'Marketing',
      'duration': '6h 45m',
    },
    {
      'title': 'Business Strategy',
      'instructor': 'Alex Lee',
      'price': '\$69.99',
      'rating': 4.6,
      'students': 756,
      'image':
      'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=400&q=80',
      'category': 'Business',
      'duration': '7h 30m',
    },
    {
      'title': 'Mobile Photography',
      'instructor': 'Emma Wilson',
      'price': '\$29.99',
      'rating': 4.5,
      'students': 543,
      'image':
      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=400&q=80',
      'category': 'Photography',
      'duration': '4h 10m',
    },
    {
      'title': 'Advanced Figma Techniques',
      'instructor': 'Michael Chen',
      'price': '\$54.99',
      'rating': 4.9,
      'students': 987,
      'image':
      'https://images.unsplash.com/photo-1551650975-87deedd944c3?auto=format&fit=crop&w=400&q=80',
      'category': 'Design',
      'duration': '5h 50m',
    },
  ];

  List<Map<String, dynamic>> get _filteredCourses {
    if (_selectedCategory == 'All' && _searchController.text.isEmpty) {
      return _courses;
    }
    return _courses.where((course) {
      final matchesCategory =
          _selectedCategory == 'All' || course['category'] == _selectedCategory;
      final matchesSearch = course['title']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Browse Courses'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Modern gradient background with blur shapes
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF2C5364),
                  Color(0xFF1CB5E0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Glassmorphism blurred shape
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(90),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(70),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white70),
                          onPressed: () {},
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                // Category Chips
                SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = _selectedCategory == category;
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 18 : 8,
                          right: index == _categories.length - 1 ? 18 : 0,
                        ),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          selected: selected,
                          selectedColor: Colors.blueAccent.withOpacity(0.7),
                          backgroundColor: Colors.white.withOpacity(0.10),
                          elevation: selected ? 6 : 0,
                          shadowColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (isSelected) {
                            setState(() {
                              _selectedCategory = isSelected ? category : 'All';
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Course Count and Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredCourses.length} courses found',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.filter_list, size: 22, color: Colors.white70),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Courses List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = _filteredCourses[index];
                      return _buildModernCourseCard(course);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCourseCard(Map<String, dynamic> course) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white24, width: 1),
        // Glassmorphism effect
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course['image'],
                  width: 90,
                  height: 76,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              // Course Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['instructor'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amberAccent, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          course['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${course['students']})',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            course['price'],
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.white38, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course['duration'],
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['category'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
}
