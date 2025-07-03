import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillswap/widgets/earning_widgets.dart';
import '../../viewmodels/earnings_view_model.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsViewModel>().loadEarningsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Consumer<EarningsViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isLoading ? null : viewModel.loadEarningsData,
              );
            },
          ),
        ],
      ),
      body: Consumer<EarningsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadEarningsData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadEarningsData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PeriodSelector(
                    selectedPeriod: viewModel.selectedPeriod,
                    onPeriodChanged: viewModel.updateTimePeriod,
                  ),
                  const SizedBox(height: 20),
                  TotalEarningsCard(earnings: viewModel.earningsData?.totalEarnings ?? 0),
                  const SizedBox(height: 16),
                  EarningsBreakdownCard(earningsData: viewModel.earningsData),
                  const SizedBox(height: 16),
                  BookingStatsCard(
                    earningsData: viewModel.earningsData,
                    averagePrice: viewModel.getAverageSessionPrice(),
                  ),
                  const SizedBox(height: 16),
                  RecentBookingsCard(
                    bookings: viewModel.earningsData?.recentBookings ?? [],
                    sessions: viewModel.instructorSessions,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}