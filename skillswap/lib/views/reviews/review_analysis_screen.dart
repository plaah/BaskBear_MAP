import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/review_view_model.dart';
import '../../models/review_model.dart';
import '../../services/session_service.dart';

class ReviewAnalysisScreen extends StatefulWidget {
  final String instructorId;
  const ReviewAnalysisScreen({Key? key, required this.instructorId})
    : super(key: key);

  @override
  State<ReviewAnalysisScreen> createState() => _ReviewAnalysisScreenState();
}

class _ReviewAnalysisScreenState extends State<ReviewAnalysisScreen> {
  final Map<String, String> _sessionTitles = {};
  final FirestoreSessionService _sessionService = FirestoreSessionService();
  bool _loadingTitles = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().loadInstructorReviews(
        widget.instructorId,
      );
    });
  }

  Future<void> _fetchSessionTitles(List<String> sessionIds) async {
    if (_loadingTitles) return; // Prevent multiple simultaneous calls

    setState(() => _loadingTitles = true);
    try {
      for (final id in sessionIds) {
        if (!_sessionTitles.containsKey(id)) {
          final session = await _sessionService.getSessionById(id);
          if (session != null) {
            setState(() {
              _sessionTitles[id] = session.title;
            });
          } else {
            setState(() {
              _sessionTitles[id] = 'Session $id'; // Fallback
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching session titles: $e');
    } finally {
      setState(() => _loadingTitles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Analysis'),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReviewViewModel>().loadInstructorReviews(
                widget.instructorId,
              );
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ReviewViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading || _loadingTitles) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.reviews.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          // Calculate summary statistics
          final totalReviews = vm.reviews.length;
          final avgRating =
              vm.reviews.map((r) => r.rating).reduce((a, b) => a + b) /
              totalReviews;

          // Rating distribution
          final ratingDist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
          for (var review in vm.reviews) {
            final rounded = review.rating.round().clamp(1, 5);
            ratingDist[rounded] = ratingDist[rounded]! + 1;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Reviews',
                            totalReviews.toString(),
                            Icons.rate_review,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Average Rating',
                            avgRating.toStringAsFixed(1),
                            Icons.star,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rating Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...ratingDist.entries.map(
                      (entry) =>
                          _buildRatingBar(entry.key, entry.value, totalReviews),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Session Reviews Section
              const Text(
                'Session Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Group reviews by sessionId and create session cards
              Builder(
                builder: (context) {
                  final sessions = <String, List<ReviewModel>>{};
                  for (var review in vm.reviews) {
                    sessions
                        .putIfAbsent(review.sessionId, () => [])
                        .add(review);
                  }
                  // Fetch session titles if not already fetched
                  _fetchSessionTitles(sessions.keys.toList());

                  return Column(
                    children:
                        sessions.entries.map((entry) {
                          final sessionId = entry.key;
                          final reviews = entry.value;
                          final avgRating =
                              reviews
                                  .map((r) => r.rating)
                                  .reduce((a, b) => a + b) /
                              reviews.length;
                          final sessionTitle =
                              _sessionTitles[sessionId] ?? sessionId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(sessionTitle),
                              subtitle: Text(
                                'Avg. Rating: ${avgRating.toStringAsFixed(2)} | Reviews: ${reviews.length}',
                              ),
                              trailing: const Icon(Icons.bar_chart),
                              onTap:
                                  () => _showSessionDetail(
                                    context,
                                    sessionTitle,
                                    reviews,
                                  ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int rating, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Row(
              children: [
                Text(
                  '$rating',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Icon(Icons.star, color: Colors.amber, size: 12),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetail(
    BuildContext context,
    String sessionTitle,
    List<ReviewModel> reviews,
  ) {
    final ratingDist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    double clarity = 0, relevance = 0, satisfaction = 0;
    for (var r in reviews) {
      final rounded = r.rating.round().clamp(1, 5);
      ratingDist[rounded] = ratingDist[rounded]! + 1;
      clarity += r.clarityScore;
      relevance += r.relevanceScore;
      satisfaction += r.satisfactionScore;
    }
    final n = reviews.length;
    clarity /= n;
    relevance /= n;
    satisfaction /= n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session: $sessionTitle',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Rating Distribution'),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: reviews.length.toDouble(),
                        barGroups:
                            ratingDist.entries
                                .map(
                                  (e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.toDouble(),
                                        color: const Color(0xFF667eea),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget:
                                  (value, meta) => Text('${value.toInt()}'),
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Average Scores'),
                  _buildScoreRow('Clarity', clarity),
                  _buildScoreRow('Relevance', relevance),
                  _buildScoreRow('Satisfaction', satisfaction),
                  const SizedBox(height: 24),
                  const Text('Student Comments'),
                  ...reviews
                      .where((r) => r.comment.isNotEmpty)
                      .map(
                        (r) => ListTile(
                          leading: const Icon(
                            Icons.comment,
                            color: Color(0xFF667eea),
                          ),
                          title: Text(r.comment),
                          subtitle: Text('by ${r.studentName}'),
                        ),
                      ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildScoreRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 5.0,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF667eea),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }
}

class ReviewAnalysisScreenWrapper extends StatelessWidget {
  final String instructorId;
  const ReviewAnalysisScreenWrapper({Key? key, required this.instructorId})
    : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewViewModel(),
      child: ReviewAnalysisScreen(instructorId: instructorId),
    );
  }
}
