import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late BookingViewModel _viewModel;
  User? _currentUser;
  bool _isLoading = false;
  bool _paymentCompleted = false;

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
        foregroundColor: Colors.white,
      ),
      body: _currentUser == null
          ? const Center(child: Text('You must be logged in to book a session.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session Details Card
                    _buildSessionDetailsCard(),
                    const SizedBox(height: 20),
                    
                    // Booking Details
                    _buildBookingDetailsSection(),
                    const SizedBox(height: 20),
                    
                    // Payment Section
                    _buildPaymentSection(),
                    const SizedBox(height: 30),
                    
                    // Book Button
                    _buildBookButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSessionDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Title', widget.session.title),
            _buildDetailRow('Instructor', widget.session.instructor),
            _buildDetailRow('Category', widget.session.category),
            _buildDetailRow('Duration', '${widget.session.durationHours} hours'),
            _buildDetailRow('Price', '\$${widget.session.price}'),
            _buildDetailRow('Date', _formatDate(widget.session.startDate)),
            _buildDetailRow('Type', widget.session.isOnline ? 'Online' : 'In-Person'),
            if (!widget.session.isOnline && widget.session.location != null)
              _buildDetailRow('Location', widget.session.location!),
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _additionalNotesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any special requirements or questions...',
                border: OutlineInputBorder(),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Amount:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '\$${widget.session.price}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Payment Method Selection (Dummy for now)
            _buildPaymentMethodCard(),
            const SizedBox(height: 16),
            // Payment Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _paymentCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _paymentCompleted ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _paymentCompleted ? Icons.check_circle : Icons.pending,
                    color: _paymentCompleted ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _paymentCompleted ? 'Payment Completed' : 'Payment Pending',
                    style: TextStyle(
                      color: _paymentCompleted ? Colors.green : Colors.orange,
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

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Colors.blueAccent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Credit/Debit Card',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => _showPaymentDialog(),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Complete Booking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit/Debit Card'),
              onTap: () {
                Navigator.pop(context);
                _simulatePayment();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Transfer'),
              onTap: () {
                Navigator.pop(context);
                _simulatePayment();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Digital Wallet'),
              onTap: () {
                Navigator.pop(context);
                _simulatePayment();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _simulatePayment() {
    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _paymentCompleted = true;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Future<void> _processBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_paymentCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete payment first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create booking with all required fields
      final booking = BookingModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: _currentUser!.uid,
        sessionId: widget.session.id,
        bookingDate: DateTime.now(),
        status: 'pending',
        paymentStatus: true, // Payment completed
        additionalNotes: _additionalNotesController.text.isNotEmpty 
            ? _additionalNotesController.text 
            : 'Please confirm the booking as soon as possible.',
      );

      // Save booking to Firestore
      await _viewModel.createBooking(booking);

      // Update session status
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

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 