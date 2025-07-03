import 'package:skillswap/models/booking_model.dart';

class EarningsData {
  final double totalEarnings;
  final double pendingEarnings;
  final double confirmedEarnings;
  final double completedEarnings;
  final int totalBookings;
  final int paidBookings;
  final List<BookingModel> recentBookings;

  EarningsData({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.confirmedEarnings,
    required this.completedEarnings,
    required this.totalBookings,
    required this.paidBookings,
    required this.recentBookings,
  });

  double get paymentRate => totalBookings > 0 ? (paidBookings / totalBookings) * 100 : 0;
}
