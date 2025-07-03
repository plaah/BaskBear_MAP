import 'package:flutter/material.dart';

class ModernSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSearch;
  final ValueChanged<String>? onChanged;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search courses...',
    this.onSearch,
    this.onChanged,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isFocused ? const Color(0xFF4A90E2) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            suffixIcon:
                widget.controller.text.isNotEmpty
                    ? Container(
                      margin: const EdgeInsets.all(8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            widget.controller.clear();
                            widget.onChanged?.call('');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade300,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.grey.shade600,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchWithFilters extends StatefulWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;

  const SearchWithFilters({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onSearchChanged,
  });

  @override
  State<SearchWithFilters> createState() => _SearchWithFiltersState();
}

class _SearchWithFiltersState extends State<SearchWithFilters> {
  // Colorful gradients for categories
  final Map<String, List<Color>> categoryGradients = {
    'all': [Color(0xFF4A90E2), Color(0xFF50E3C2)],
    'design': [Color(0xFFFFA07A), Color(0xFFFFD700)],
    'development': [Color(0xFF00C6FB), Color(0xFF005BEA)],
    'business': [Color(0xFF43E97B), Color(0xFF38F9D7)],
    'marketing': [Color(0xFFFF5858), Color(0xFFFFA858)],
    'photography': [Color(0xFFB06AB3), Color(0xFF4568DC)],
    'music': [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    'language': [Color(0xFFFFB347), Color(0xFFFFCC33)],
    'science': [Color(0xFF667EEA), Color(0xFF64B6FF)],
    'default': [Color(0xFFBBD2C5), Color(0xFF536976)],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Plain white background
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          ModernSearchBar(
            controller: widget.searchController,
            hintText: 'Search by course name or learning theme...',
            onChanged: widget.onSearchChanged,
          ),
          const SizedBox(height: 24),
          // Filter Label
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Category Filters (scrollable)
          SizedBox(
            height:
                48, // Ensures enough height for the chips to display and scroll
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: _buildFilterChips(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    // Make sure 'All' is first and unique
    List<String> allCategories = ['All'];
    for (String category in widget.categories) {
      if (category.toLowerCase() != 'all') {
        allCategories.add(category);
      }
    }
    return allCategories.asMap().entries.map((entry) {
      int index = entry.key;
      String category = entry.value;
      return Padding(
        padding: EdgeInsets.only(
          right: index < allCategories.length - 1 ? 12 : 0,
        ),
        child: _buildFilterChip(category, category),
      );
    }).toList();
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = widget.selectedCategory == value;
    final lowerLabel = label.toLowerCase();
    final colors =
        categoryGradients[lowerLabel] ?? categoryGradients['default']!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCategoryChanged(value),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors:
                    isSelected
                        ? [colors[0], colors[1]]
                        : [
                          colors[0].withOpacity(0.18),
                          colors[1].withOpacity(0.18),
                        ],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? colors[0].withOpacity(0.25)
                          : Colors.transparent,
                  blurRadius: isSelected ? 12 : 0,
                  offset: Offset(0, isSelected ? 4 : 0),
                ),
              ],
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(label),
                  size: 18,
                  color: isSelected ? Colors.white : colors[0],
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.apps_rounded;
      case 'design':
        return Icons.palette_outlined;
      case 'development':
        return Icons.code_rounded;
      case 'business':
        return Icons.business_center_outlined;
      case 'marketing':
        return Icons.campaign_outlined;
      case 'photography':
        return Icons.camera_alt_outlined;
      case 'music':
        return Icons.music_note_outlined;
      case 'language':
        return Icons.language_outlined;
      case 'science':
        return Icons.science_outlined;
      default:
        return Icons.category_outlined;
    }
  }
