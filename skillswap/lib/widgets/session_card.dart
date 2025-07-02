import 'package:flutter/material.dart';

import '../models/session_model.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final bool showEnrollButton;
  final VoidCallback? onEnroll;
  final bool isDone;
  final bool isReviewed;
  final VoidCallback? onDone;
  final VoidCallback? onReview;

  const SessionCard({
    super.key,
    required this.session,
    this.showEnrollButton = false,
    this.onEnroll,
    this.isDone = false,
    this.isReviewed = false,
    this.onDone,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSessionDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      session.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFF666666),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${session.instructor}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 4, 0, 0),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.access_time,
                              label: session.durationHour,
                              color: const Color(0xFF1565C0),
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              icon: Icons.attach_money,
                              label: '\$${session.price.toStringAsFixed(0)}',
                              color: const Color(0xFF2E7D32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (session.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  session.description,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start: ${_formatDate(session.startDate)}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showEnrollButton && onEnroll != null)
                    ElevatedButton(
                      onPressed: onEnroll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: const Color(0xFFFFFFFF),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Enroll',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Session Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  session.image,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF666666),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Instructor
            Text(
              'by ${session.instructor}',
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info chips
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: session.durationHour,
                  color: const Color(0xFF1565C0),
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.attach_money,
                  label: '\$${session.price.toStringAsFixed(0)}',
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(session.startDate),
                  color: const Color(0xFF7B1FA2),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Description
            if (session.description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                session.description,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Action buttons section
            Row(
              children: [
                // Done Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDone,
                    icon: Icon(
                      isDone ? Icons.check_circle : Icons.check_circle_outline,
                      size: 18,
                      color: isDone 
                          ? const Color(0xFF2E7D32) 
                          : Colors.white,
                    ),
                    label: Text(
                      isDone ? 'Completed' : 'Mark Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDone 
                            ? const Color(0xFF2E7D32) 
                            : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDone 
                          ? const Color(0xFF2E7D32).withOpacity(0.15)
                          : const Color(0xFF2E7D32),
                      foregroundColor: isDone 
                          ? const Color(0xFF2E7D32) 
                          : Colors.white,
                      elevation: isDone ? 0 : 2,
                      side: isDone 
                          ? BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.3))
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Review Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReview,
                    icon: Icon(
                      isReviewed ? Icons.star : Icons.star_outline,
                      size: 18,
                      color: isReviewed 
                          ? const Color(0xFF1565C0) 
                          : Colors.white,
                    ),
                    label: Text(
                      isReviewed ? 'Reviewed' : 'Add Review',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isReviewed 
                            ? const Color(0xFF1565C0) 
                            : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReviewed 
                          ? const Color(0xFF1565C0).withOpacity(0.15)
                          : const Color(0xFF1565C0),
                      foregroundColor: isReviewed 
                          ? const Color(0xFF1565C0) 
                          : Colors.white,
                      elevation: isReviewed ? 0 : 2,
                      side: isReviewed 
                          ? BorderSide(color: const Color(0xFF1565C0).withOpacity(0.3))
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Close button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}