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

  // Stripe payment intent creation
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );

      setState(() {
        _paymentCompleted = true;
      });

      paymentIntent = null;
    } on StripeException catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Cancelled")),
      );
    } catch (e) {
      print("Error in displaying");
      print('$e');
    }
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent(
        widget.session.price.toInt().toString(),
        'myr',
      );

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

      await displayPaymentSheet();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Book Session'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _currentUser == null
              ? const Center(
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 32),
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'You must be logged in to book a session.',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          child: _buildSessionDetailsCard(),
                        ),
                        const SizedBox(height: 24),
                        _buildBookingDetailsSection(),
                        const SizedBox(height: 24),
                        _buildPaymentSection(),
                        const SizedBox(height: 36),
                        _buildBookButton(),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSessionDetailsCard() {
    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      margin: EdgeInsets.zero,
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Color(0xFF6A82FB), size: 32),
                const SizedBox(width: 10),
                Text(
                  'Session Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6A82FB),
                      ),
                ),
              ],
            ),
            const Divider(height: 28, thickness: 1.1),
            _buildDetailRow('Title', widget.session.title, Icons.title),
            _buildDetailRow(
                'Instructor', widget.session.instructor, Icons.person),
            _buildDetailRow(
                'Category', widget.session.category, Icons.category),
            _buildDetailRow(
                'Duration',
                '${widget.session.durationHours} hours',
                Icons.timer),
            _buildDetailRow(
                'Price', 'RM ${widget.session.price.toStringAsFixed(2)}', Icons.attach_money),
            _buildDetailRow(
                'Date',
                _formatDate(widget.session.startDate),
                Icons.calendar_today),
            _buildDetailRow(
                'Type',
                widget.session.isOnline ? 'Online' : 'In-Person',
                widget.session.isOnline ? Icons.computer : Icons.location_on),
            if (!widget.session.isOnline && widget.session.location != null)
              _buildDetailRow(
                'Location',
                widget.session.location!,
                Icons.location_city,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 22),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.97),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, color: Color(0xFF6A82FB), size: 28),
                const SizedBox(width: 8),
                Text(
                  'Booking Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6A82FB),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
              decoration: InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any special requirements or questions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: const Icon(Icons.notes, color: Colors.blueAccent),
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
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.97),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: Color(0xFF6A82FB), size: 28),
                const SizedBox(width: 8),
                Text(
                  'Payment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6A82FB),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Amount:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  'RM ${widget.session.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _paymentCompleted
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _paymentCompleted ? Colors.green : Colors.orange,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _paymentCompleted ? Icons.check_circle : Icons.pending,
                    color: _paymentCompleted ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _paymentCompleted
                        ? 'Payment Completed'
                        : 'Payment Pending',
                    style: TextStyle(
                      color: _paymentCompleted ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!_paymentCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : makePayment,
                  icon: const Icon(Icons.credit_card),
                  label: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.7,
                          ),
                        )
                      : const Text('Pay with Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
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

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading || !_paymentCompleted ? null : _processBooking,
        icon: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.7,
                ),
              )
            : const Icon(Icons.check_circle, size: 24),
        label: const Text(
          'Complete Booking',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
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
      // Create booking after successful payment
      final booking = BookingModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: _currentUser!.uid,
        sessionId: widget.session.id,
        bookingDate: DateTime.now(),
        status: 'confirmed',
        paymentStatus: true,
        additionalNotes: _additionalNotesController.text.isNotEmpty
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
