import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../viewmodels/booking_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final String sessionId;
  const BookingScreen({super.key, required this.sessionId});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _additionalNotesController = TextEditingController();
  late BookingViewModel _viewModel;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<BookingViewModel>(context, listen: false);
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Session'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _currentUser == null
                ? const Center(
                  child: Text('You must be logged in to book a session.'),
                )
                : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _additionalNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final booking = BookingModel(
                              id:
                                  DateTime.now().microsecondsSinceEpoch
                                      .toString(),
                              userId: _currentUser!.uid,
                              sessionId: widget.sessionId,
                              bookingDate: DateTime.now(),
                              status: 'pending',
                              paymentStatus: false,
                              additionalNotes: _additionalNotesController.text,
                            );
                            await _viewModel.createBooking(booking);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking created successfully!'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Book Session',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
