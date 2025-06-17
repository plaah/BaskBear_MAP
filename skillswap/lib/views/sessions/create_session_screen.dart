import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/session_view_model.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({Key? key}) : super(key: key);

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingUrlController = TextEditingController(); // Added meeting URL controller
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'Technology';
  bool _isOnline = true;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<String> _categories = [
    'Technology',
    'Business',
    'Design',
    'Marketing',
    'Photography',
    'Music',
    'Language',
    'Fitness',
    'Cooking',
    'Art',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _meetingUrlController.dispose(); // Dispose meeting URL controller
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? _startDate.add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before the new start date
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _createCourse() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<SessionViewModel>(context, listen: false);

      // Clear any previous errors
      viewModel.clearError();

      await viewModel.createSession(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        isOnline: _isOnline,
        location: _isOnline ? null : _locationController.text.trim(),
        meetingUrl: _isOnline ? _meetingUrlController.text.trim() : null, // Added meeting URL
        price: double.parse(_priceController.text),
        startDate: _startDate,
        endDate: _endDate,
        durationHours: int.parse(_durationController.text),
      );

      if (mounted) {
        if (viewModel.error == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Course'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SessionViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Course Image Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.image, color: Colors.indigo),
                              const SizedBox(width: 8),
                              const Text(
                                'Course Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (viewModel.selectedImage != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.red),
                                  onPressed: viewModel.clearSelectedImage,
                                  tooltip: 'Remove image',
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: viewModel.pickImage,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: viewModel.selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        viewModel.selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to select image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '(Optional)',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course Details Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                'Course Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Title
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Course Title *',
                              hintText: 'Enter an engaging course title',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a course title';
                              }
                              if (value.trim().length < 3) {
                                return 'Title must be at least 3 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              hintText: 'Describe what students will learn',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 4,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a description';
                              }
                              if (value.trim().length < 10) {
                                return 'Description must be at least 10 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Category
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Price
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price (\$) *',
                              hintText: '0.00',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              final price = double.tryParse(value);
                              if (price == null) {
                                return 'Please enter a valid price';
                              }
                              if (price < 0) {
                                return 'Price cannot be negative';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Duration
                          TextFormField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Duration (Total hours) *',
                              hintText: 'e.g., 10',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.schedule),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter duration in hours';
                              }
                              final duration = int.tryParse(value);
                              if (duration == null || duration <= 0) {
                                return 'Please enter a valid duration (positive number)';
                              }
                              if (duration > 1000) {
                                return 'Duration seems too long. Please check.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Method Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.delivery_dining, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                'Delivery Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Online/In-Person Toggle
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _isOnline = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _isOnline ? Colors.indigo : Colors.transparent,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.computer,
                                            color: _isOnline ? Colors.white : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Online',
                                            style: TextStyle(
                                              color: _isOnline ? Colors.white : Colors.grey[600],
                                              fontWeight: _isOnline ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _isOnline = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !_isOnline ? Colors.indigo : Colors.transparent,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: !_isOnline ? Colors.white : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'In-Person',
                                            style: TextStyle(
                                              color: !_isOnline ? Colors.white : Colors.grey[600],
                                              fontWeight: !_isOnline ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Location or Meeting URL field
                          if (_isOnline) ...[
                            TextFormField(
                              controller: _meetingUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Meeting URL *',
                                hintText: 'https://zoom.us/j/123456789',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.video_call),
                              ),
                              validator: (value) {
                                if (_isOnline && (value == null || value.trim().isEmpty)) {
                                  return 'Please enter a meeting URL for online course';
                                }
                                if (_isOnline && value != null && value.trim().isNotEmpty) {
                                  // Basic URL validation
                                  if (!value.trim().startsWith('http://') && 
                                      !value.trim().startsWith('https://')) {
                                    return 'Please enter a valid URL (starting with http:// or https://)';
                                  }
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location *',
                                hintText: 'Enter venue address',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (value) {
                                if (!_isOnline && (value == null || value.trim().isEmpty)) {
                                  return 'Please enter a location for in-person course';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Schedule Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                'Schedule',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Start Date
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today, color: Colors.indigo),
                              title: const Text('Start Date *'),
                              subtitle: Text(
                                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _selectDate(context, isStartDate: true),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // End Date (Optional)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.event, color: Colors.grey),
                              title: const Text('End Date (Optional)'),
                              subtitle: Text(
                                _endDate != null
                                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                    : 'Not set',
                                style: TextStyle(
                                  fontWeight: _endDate != null ? FontWeight.w500 : FontWeight.normal,
                                  color: _endDate != null ? Colors.black87 : Colors.grey,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_endDate != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                                      onPressed: () => setState(() => _endDate = null),
                                      tooltip: 'Clear end date',
                                    ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                              onTap: () => _selectDate(context, isStartDate: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Display
                  if (viewModel.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: viewModel.clearError,
                            color: Colors.red[700],
                          ),
                        ],
                      ),
                    ),

                  // Create Course Button
                  ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _createCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: viewModel.isLoading
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
                              Text('Creating Course...'),
                            ],
                          )
                        : const Text(
                            'Create Course',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
