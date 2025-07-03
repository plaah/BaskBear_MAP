import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/session_model.dart';

class ShareService {
  
  // Share session to general platforms
  static Future<void> shareSession(Session session) async {
    try {
      final String deepLink = _generateDeepLink(session.id);
      final String shareText = _generateShareText(session, deepLink);
      
      if (kIsWeb) {
        // Web platform - use basic share API or fallback
        await _shareOnWeb(shareText, session.title);
      } else {
        // Mobile platforms
        await Share.share(
          shareText,
          subject: 'Check out this SkillSwap session: ${session.title}',
        );
      }
    } catch (e) {
      throw Exception('Failed to share session: $e');
    }
  }

  // Share to WhatsApp specifically (mobile only)
  static Future<void> shareToWhatsApp(Session session) async {
    try {
      if (kIsWeb) {
        throw Exception('WhatsApp sharing is not available on web platform');
      }
      
      final String deepLink = _generateDeepLink(session.id);
      final String shareText = _generateShareText(session, deepLink);
      
      await Share.shareWithResult(
        shareText,
        subject: 'SkillSwap Session: ${session.title}',
      );
    } catch (e) {
      throw Exception('Failed to share to WhatsApp: $e');
    }
  }

  // Share to Twitter with hashtags
  static Future<void> shareToTwitter(Session session) async {
    try {
      final String deepLink = _generateDeepLink(session.id);
      final String twitterText = _generateTwitterText(session, deepLink);
      
      if (kIsWeb) {
        // Web - open Twitter in new window
        await _shareToTwitterWeb(twitterText);
      } else {
        // Mobile - use share with specific text format
        await Share.share(
          twitterText,
          subject: 'SkillSwap Learning Session',
        );
      }
    } catch (e) {
      throw Exception('Failed to share to Twitter: $e');
    }
  }

  // Share to LinkedIn
  static Future<void> shareToLinkedIn(Session session) async {
    try {
      final String deepLink = _generateDeepLink(session.id);
      final String linkedInText = _generateLinkedInText(session, deepLink);
      
      if (kIsWeb) {
        await _shareToLinkedInWeb(linkedInText, session.title, deepLink);
      } else {
        await Share.share(
          linkedInText,
          subject: 'Professional Learning Opportunity: ${session.title}',
        );
      }
    } catch (e) {
      throw Exception('Failed to share to LinkedIn: $e');
    }
  }

  // Generate deep link for the session
  static String _generateDeepLink(String sessionId) {
    // In production, this should be your actual domain
    return 'https://skillswap.app/session/$sessionId';
  }

  // Generate general share text
  static String _generateShareText(Session session, String deepLink) {
    final String emoji = session.isOnline ? '💻' : '📍';
    final String location = session.isOnline 
        ? 'Online Session' 
        : 'Location: ${session.location ?? 'TBD'}';
    
    return '''
🎓 Join this amazing learning session on SkillSwap!

📚 ${session.title}
👨‍🏫 Instructor: ${session.instructor}
💰 Price: \$${session.price.toStringAsFixed(2)}
⏰ Duration: ${session.durationHours} ${session.durationHours == 1 ? 'hour' : 'hours'}
📅 ${_formatDate(session.startDate)}
$emoji $location

${session.description.length > 100 ? session.description.substring(0, 100) + '...' : session.description}

Learn more and book: $deepLink

#SkillSwap #Learning #SkillSharing #Education
    ''';
  }

  // Generate Twitter-specific text (with character limit)
  static String _generateTwitterText(Session session, String deepLink) {
    final String baseText = '''
🎓 ${session.title} with ${session.instructor}
💰 \$${session.price.toStringAsFixed(2)} | ⏰ ${session.durationHours}h
📅 ${_formatDateShort(session.startDate)}

Learn more: $deepLink

#SkillSwap #Learning #Education''';
    
    // Twitter has ~280 character limit
    return baseText.length > 280 ? baseText.substring(0, 277) + '...' : baseText;
  }

  // Generate LinkedIn-specific text
  static String _generateLinkedInText(Session session, String deepLink) {
    return '''
🚀 Exciting Learning Opportunity Available!

I'd like to share this professional development session I found on SkillSwap:

📚 ${session.title}
👨‍🏫 Instructor: ${session.instructor}
💰 Investment: \$${session.price.toStringAsFixed(2)}
⏰ Duration: ${session.durationHours} ${session.durationHours == 1 ? 'hour' : 'hours'}
📅 Scheduled: ${_formatDate(session.startDate)}

${session.description}

This could be valuable for anyone looking to develop skills in ${session.category}.

Learn more and register: $deepLink

#ProfessionalDevelopment #SkillSwap #Learning #${session.category.replaceAll(' ', '')}
    ''';
  }

  // Web sharing fallbacks
  static Future<void> _shareOnWeb(String text, String title) async {
    try {
      // Try to use Web Share API if available
      if (kIsWeb) {
        // For web, we can try to copy to clipboard as fallback
        // Note: This would require additional web-specific implementation
        print('Web sharing: $text');
        // In a real implementation, you might want to show a modal with sharing options
        // or copy the text to clipboard
      }
    } catch (e) {
      throw Exception('Web sharing not supported: $e');
    }
  }

  static Future<void> _shareToTwitterWeb(String text) async {
    // In a real implementation, you would open Twitter URL
    // Example: https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}
    print('Twitter web share: $text');
  }

  static Future<void> _shareToLinkedInWeb(String text, String title, String url) async {
    // In a real implementation, you would open LinkedIn URL
    // Example: https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(url)}
    print('LinkedIn web share: $text');
  }

  // Helper method to format date
  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to format date short
  static String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Generate share options for bottom sheet
  static List<ShareOption> getShareOptions() {
    List<ShareOption> options = [
      ShareOption(
        title: 'Share',
        icon: 'share',
        action: ShareAction.general,
      ),
    ];

    // Add platform-specific options only for mobile
    if (!kIsWeb) {
      options.addAll([
        ShareOption(
          title: 'WhatsApp',
          icon: 'whatsapp',
          action: ShareAction.whatsapp,
        ),
        ShareOption(
          title: 'Twitter',
          icon: 'twitter',
          action: ShareAction.twitter,
        ),
        ShareOption(
          title: 'LinkedIn',
          icon: 'linkedin',
          action: ShareAction.linkedin,
        ),
      ]);
    }

    return options;
  }

  // Execute share action
  static Future<void> executeShareAction(Session session, ShareAction action) async {
    switch (action) {
      case ShareAction.general:
        await shareSession(session);
        break;
      case ShareAction.whatsapp:
        await shareToWhatsApp(session);
        break;
      case ShareAction.twitter:
        await shareToTwitter(session);
        break;
      case ShareAction.linkedin:
        await shareToLinkedIn(session);
        break;
    }
  }
}

// Share option model
class ShareOption {
  final String title;
  final String icon;
  final ShareAction action;

  ShareOption({
    required this.title,
    required this.icon,
    required this.action,
  });
}

// Share action enum
enum ShareAction {
  general,
  whatsapp,
  twitter,
  linkedin,
}