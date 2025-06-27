import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Color? iconColor;
  final Color? backgroundColor;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onAction,
    this.actionText,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.blue).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: iconColor ?? Colors.blue,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 32),
            
            // Action Button
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actionText!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Specific Empty States
class NoCoursesEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;
  
  const NoCoursesEmptyState({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No Courses Available',
      subtitle: 'Check back later for new learning opportunities or try adjusting your search filters.',
      icon: Icons.school_outlined,
      iconColor: Colors.blue,
      onAction: onRefresh,
      actionText: 'Refresh',
    );
  }
}

class NoBookingsEmptyState extends StatelessWidget {
  final bool isInstructor;
  
  const NoBookingsEmptyState({
    super.key,
    this.isInstructor = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: isInstructor ? 'No Bookings Yet' : 'No Bookings Found',
      subtitle: isInstructor 
          ? 'Bookings will appear here when students enroll in your sessions.'
          : 'Start exploring courses and enroll in sessions to see your bookings here.',
      icon: Icons.bookmark_border,
      iconColor: Colors.orange,
    );
  }
}

class NoSessionsEmptyState extends StatelessWidget {
  final VoidCallback? onCreateSession;
  
  const NoSessionsEmptyState({
    super.key,
    this.onCreateSession,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No Sessions Created',
      subtitle: 'Start creating your first session to share your knowledge with students.',
      icon: Icons.add_circle_outline,
      iconColor: Colors.green,
      onAction: onCreateSession,
      actionText: 'Create Session',
    );
  }
} 