import 'package:flutter/material.dart';
import 'browse_sessions_screen.dart'; // Import your target screen

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  _CreateSessionPageState createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _sessionName = TextEditingController();
  final _description = TextEditingController();
  final _category = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newSession = {
        'title': _sessionName.text,
        'instructor': 'You',
        'price': _price.text == '0' ? 'Free' : '\$${_price.text}',
        'rating': 0.0,
        'students': 0,
        'image': 'https://via.placeholder.com/150', // default/fallback image
        'category': _category.text.isNotEmpty ? _category.text : 'General',
        'duration': 'TBD',
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BrowseSessionScreen(newSession: newSession),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Create Session",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _sessionName,
                decoration: InputDecoration(hintText: 'Session Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: InputDecoration(hintText: 'Session Description'),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText:
                                _startDate == null
                                    ? 'Start Date'
                                    : _startDate!.toLocal().toString().split(
                                      ' ',
                                    )[0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText:
                                _endDate == null
                                    ? 'End Date'
                                    : _endDate!.toLocal().toString().split(
                                      ' ',
                                    )[0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _category,
                decoration: InputDecoration(hintText: 'Category'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: InputDecoration(hintText: 'Location'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Price (Type 0 if free)'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Submit', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
