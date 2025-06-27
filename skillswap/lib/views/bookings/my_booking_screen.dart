import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../viewmodels/booking_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  _MyBookingScreenState createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  late BookingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<BookingViewModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _viewModel.fetchBookingsByUserId(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Consumer<BookingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            itemCount: viewModel.bookings.length,
            itemBuilder: (context, index) {
              final booking = viewModel.bookings[index];
              return ListTile(
                title: Text('Booking ID: ${booking.id}'),
                subtitle: Text('Status: ${booking.status}, Payment: ${booking.paymentStatus ? 'Paid' : 'Unpaid'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        // Example: Update booking status
                        await _viewModel.updateBookingStatus(booking.id, 'confirmed');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Example: Delete booking
                        await _viewModel.deleteBooking(booking.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}