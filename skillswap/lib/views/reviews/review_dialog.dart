import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/review_view_model.dart';

class ReviewDialog extends StatefulWidget {
  final String sessionId;
  final String instructorId;
  final String sessionTitle;
  final String instructorName;
  
  const ReviewDialog({
    Key? key,
    required this.sessionId,
    required this.instructorId,
    required this.sessionTitle,
    required this.instructorName,
  }) : super(key: key);

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _clarityScore;
  int? _relevanceScore;
  int? _satisfactionScore;
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewViewModel>(
      builder: (context, reviewVM, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Rate This Session',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.sessionTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${widget.instructorName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating Section
                            const Text(
                              'How would you rate this session?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Center(
                              child: Column(
                                children: [
                                  RatingBar.builder(
                                    initialRating: _rating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemSize: 40,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        _rating = rating;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getRatingText(_rating),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Comment Section
                            const Text(
                              'Share your experience',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Tell others about your learning experience...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF667eea)),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              maxLines: 4,
                              maxLength: 500,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please share your thoughts about the session';
                                }
                                if (value.trim().length < 10) {
                                  return 'Please provide a more detailed review (at least 10 characters)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Clarity
                            const Text('Seberapa jelas penjelasan dari instruktur?', style: TextStyle(fontWeight: FontWeight.w600)),
                            _buildScaleSelector((v) => setState(() => _clarityScore = v), _clarityScore),
                            const SizedBox(height: 16),
                            // Relevance
                            const Text('Apakah materi sesuai dengan deskripsi?', style: TextStyle(fontWeight: FontWeight.w600)),
                            _buildScaleSelector((v) => setState(() => _relevanceScore = v), _relevanceScore),
                            const SizedBox(height: 16),
                            // Satisfaction
                            const Text('Seberapa puas kamu secara keseluruhan?', style: TextStyle(fontWeight: FontWeight.w600)),
                            _buildScaleSelector((v) => setState(() => _satisfactionScore = v), _satisfactionScore),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: reviewVM.isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: reviewVM.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState?.validate() != true) return;
                                    if (_clarityScore == null || _relevanceScore == null || _satisfactionScore == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please rate all aspects.')),
                                      );
                                      return;
                                    }
                                    await reviewVM.submitReview(
                                      sessionId: widget.sessionId,
                                      instructorId: widget.instructorId,
                                      rating: _rating,
                                      comment: _commentController.text.trim(),
                                      clarityScore: _clarityScore!,
                                      relevanceScore: _relevanceScore!,
                                      satisfactionScore: _satisfactionScore!,
                                    );
                                    if (reviewVM.error == null) {
                                      Navigator.pop(context, true);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(reviewVM.error!)),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: reviewVM.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Submit Review',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScaleSelector(ValueChanged<int> onChanged, int? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) => GestureDetector(
        onTap: () => onChanged(i + 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: value == i + 1 ? const Color(0xFF667eea) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('${i + 1}', style: TextStyle(
            color: value == i + 1 ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          )),
        ),
      )),
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate this session';
    }
  }
}