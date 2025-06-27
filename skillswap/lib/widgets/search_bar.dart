import 'package:flutter/material.dart';

class ModernSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSearch;
  final ValueChanged<String>? onChanged;
  final List<String>? suggestions;
  final Function(String)? onSuggestionSelected;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search courses...',
    this.onSearch,
    this.onChanged,
    this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 24,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        ModernSearchBar(
          controller: widget.searchController,
          hintText: 'Search by course name or learning theme...',
          onChanged: widget.onSearchChanged,
        ),
        
        const SizedBox(height: 16),
        
        // Category Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', 'All'),
              const SizedBox(width: 8),
              ...widget.categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(category, category),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = widget.selectedCategory == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        widget.onCategoryChanged(value);
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
} 