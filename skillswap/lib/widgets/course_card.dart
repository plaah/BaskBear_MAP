import 'package:flutter/material.dart';

import '../models/session_model.dart';

class CourseCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;
  final bool showEnrollButton;
  final VoidCallback? onEnroll;
  final bool isDone;
  final bool isReview;
  final VoidCallback? onReview;

  const CourseCard({
    super.key,
    required this.session,
    this.onTap,
    this.showEnrollButton = false,
    this.onEnroll,
    this.isDone = false,
    this.isReview = false,
    this.onReview,
  });

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return Icons.palette_outlined;
      case 'development':
        return Icons.code_outlined;
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
        return Icons.school_outlined;
    }
  }

  List<Color> _categoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case 'development':
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case 'business':
        return [
          const Color.fromARGB(255, 121, 73, 4),
          const Color.fromARGB(255, 254, 166, 137),
        ];
      case 'marketing':
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      case 'photography':
        return [
          const Color(0xFF8B5CF6),
          const Color(0xFFA855F7),
        ];
      case 'music':
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case 'language':
        return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
      case 'science':
        return [const Color(0xFF43e97b), const Color(0xFF38f9d7)];
      default:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _categoryGradient(session.category);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withOpacity(0.8),
                gradientColors[1].withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact header with image/icon
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 45,
                  width: double.infinity,
                  child: session.image.isNotEmpty
                      ? Image.network(
                          session.image,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildPlaceholderIcon(session.category),
                        )
                      : _buildPlaceholderIcon(session.category),
                ),
              ),
              // Compact content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip and title in same row to save space
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _categoryIcon(session.category),
                                  color: gradientColors.first,
                                  size: 10,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  session.category,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: gradientColors.first,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title - more compact
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Instructor - more compact
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.white,
                            child: Text(
                              session.instructor.isNotEmpty
                                  ? session.instructor[0].toUpperCase()
                                  : 'I',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: gradientColors.first,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              session.instructor,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Bottom row with details and price/button
                      Row(
                        children: [
                          _buildDetailChip(
                            Icons.access_time_outlined,
                            '${session.durationHours}h',
                          ),
                          const SizedBox(width: 4),
                          _buildDetailChip(
                            Icons.calendar_today_outlined,
                            _formatDate(session.startDate),
                          ),
                          const Spacer(),
                          if (showEnrollButton && session.isAvailable)
                            _buildEnrollButton(gradientColors.first)
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '\$${session.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: gradientColors.first,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Show "Done" and "Write Review" if isDone is true
                      if (isDone) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isReview && onReview != null)
                              ElevatedButton.icon(
                                onPressed: onReview,
                                icon: const Icon(Icons.rate_review, color: Colors.white, size: 16),
                                label: const Text('Write Review', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(String category) {
    final icon = _categoryIcon(category);
    final gradientColors = _categoryGradient(category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors.first.withOpacity(0.6),
            gradientColors.last.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollButton(Color primaryColor) {
    return Container(
      height: 24,
      child: ElevatedButton(
        onPressed: onEnroll,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Enroll',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
