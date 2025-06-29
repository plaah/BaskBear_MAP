import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/booking_model.dart';
import '../../models/session_model.dart';
import '../../viewmodels/booking_view_model.dart';

class AdvancedBookingScreen extends StatefulWidget {
  final Session session;
  final String studentId;
  final String studentName;

  const AdvancedBookingScreen({
    super.key,
    required this.session,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<AdvancedBookingScreen> createState() => _AdvancedBookingScreenState();
}

class _AdvancedBookingScreenState extends State<AdvancedBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _additionalNotesController = TextEditingController();
  final _emailController = TextEditingController();
  late BookingViewModel _viewModel;
  User? _currentUser;
  bool _isLoading = false;
  bool _paymentCompleted = false;
  final String _selectedPaymentMethod = 'credit_card';
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<BookingViewModel>(context, listen: false);
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser?.email != null) {
      _emailController.text = _currentUser!.email!;
    }
  }

  // Following paste-3.txt tutorial exactly
  Future createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((int.parse(amount)) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var secretKey = dotenv.env['STRIPE_SECRET_KEY'];

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print('Payment Intent Body: ${response.body.toString()}');
      return jsonDecode(response.body.toString());
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Paid successfully")));

      setState(() {
        _paymentCompleted = true;
      });

      paymentIntent = null;
    } on StripeException catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment Cancelled")));
    } catch (e) {
      print("Error in displaying");
      print('$e');
    }
  }

  Future<void> makePayment() async {
    try {
      // Create payment intent data
      paymentIntent = await createPaymentIntent(
        widget.session.price.toInt().toString(),
        'myr',
      );

      // Initialize the payment sheet setup
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
            testEnv: true,
            currencyCode: "MYR",
            merchantCountryCode: "MY",
          ),
          merchantDisplayName: 'SkillSwap',
        ),
      );

      // Display payment sheet
      displayPaymentSheet();
    } catch (e) {
      print("exception $e");

      if (e is StripeConfigException) {
        print("Stripe exception ${e.message}");
      } else {
        print("exception $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Session'),
        centerTitle: true,
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _currentUser == null
              ? const Center(
                child: Text('You must be logged in to book a session.'),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSessionDetailsCard(),
                      const SizedBox(height: 20),
                      _buildBookingDetailsSection(),
                      const SizedBox(height: 20),
                      _buildPaymentSection(),
                      const SizedBox(height: 30),
                      _buildBookButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isLoading
                ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Processing...'),
                  ],
                )
                : Text(
                  _paymentCompleted ? 'Complete Booking' : 'Pay & Book Session',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _processBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!_paymentCompleted) {
        // Process Real Stripe Payment following tutorial
        await makePayment();
      } else {
        // Create booking after successful payment
        await _createBooking();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createBooking() async {
    try {
      final booking = BookingModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: _currentUser!.uid,
        sessionId: widget.session.id,
        bookingDate: DateTime.now(),
        status: 'confirmed',
        paymentStatus: true,
        additionalNotes:
            _additionalNotesController.text.isNotEmpty
                ? _additionalNotesController.text
                : 'Booking confirmed with Stripe payment',
      );

      await _viewModel.createBooking(booking);

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.session.id)
          .update({
            'isBooked': true,
            'enrolledStudentId': widget.studentId,
            'enrolledStudentName': widget.studentName,
            'enrolledAt': Timestamp.now(),
            'status': 'scheduled',
            'updatedAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }

  // Keep your existing UI building methods
  Widget _buildSessionDetailsCard() {
    // Your existing implementation
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Title', widget.session.title),
            _buildDetailRow('Instructor', widget.session.instructor),
            _buildDetailRow('Category', widget.session.category),
            _buildDetailRow(
              'Duration',
              '${widget.session.durationHours} hours',
            ),
            _buildDetailRow(
              'Price',
              'RM ${widget.session.price.toStringAsFixed(2)}',
            ),
            _buildDetailRow('Date', _formatDate(widget.session.startDate)),
            _buildDetailRow(
              'Type',
              widget.session.isOnline ? 'Online' : 'In-Person',
            ),
            if (!widget.session.isOnline && widget.session.location != null)
              _buildDetailRow('Location', widget.session.location!),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                hintText: 'Enter your email for receipt',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _additionalNotesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any special requirements or questions...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'RM ${widget.session.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_paymentCompleted)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Payment Completed Successfully',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
