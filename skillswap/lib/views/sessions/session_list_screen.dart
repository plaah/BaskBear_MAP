import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/session_view_model.dart';
import '../../models/session_model.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionViewModel>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SessionViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.sessions.isEmpty && !viewModel.isLoading) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.sessions.length,
            itemBuilder: (context, index) {
              final session = viewModel.sessions[index];
              return _buildSessionCard(session, index, viewModel);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(Session session, int index, SessionViewModel vm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with action buttons
          ListTile(
            leading: session.image.startsWith('http')
                ? Image.network(
              session.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 60),
            )
                : session.image.isNotEmpty
                ? Image.file(
              File(session.image),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 60),
            )
                : const Icon(Icons.school, size: 60, color: Colors.indigo),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),                
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(session.category),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () {
                    // Show edit dialog
                    _showEditDialog(context, session, vm);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, session, vm);
                  },
                ),
              ],
            ),
          ),
          // Expandable content
          ExpansionTile(
            title: const Text('View Details'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.description, session.description),
                    _buildDetailRow(Icons.calendar_today,
                        '${_formatDate(session.startDate)} - ${_formatDate(session.endDate)}'),
                    _buildDetailRow(Icons.access_time, '${session.durationHours} Hours'),
                    if (!session.isOnline && session.location != null)
                      _buildDetailRow(Icons.location_on, session.location!),
                    _buildDetailRow(Icons.attach_money,
                        session.price > 0 ? '\$${session.price}' : 'Free'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Session session, SessionViewModel vm) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: session.title);
    final descriptionController = TextEditingController(text: session.description);
    final priceController = TextEditingController(text: session.price.toString());
    final durationController = TextEditingController(text: session.durationHours.toString());
    final locationController = TextEditingController(text: session.location ?? '');

    String selectedCategory = session.category;
    bool isOnline = session.isOnline;
    DateTime? startDate = session.startDate;
    DateTime? endDate = session.endDate;
    bool isBooked = session.isBooked;

    final List<String> categories = [
      'Technology',
      'Business',
      'Design',
      'Marketing',
      'Photography',
      'Music',
      'Health & Fitness',
      'Language',
      'Cooking',
      'Other'
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.85,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edit Course',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Course Details Section
                        _buildSectionTitle('Course Details'),
                        const SizedBox(height: 16),

                        // Course Title
                        _buildDialogTextField(
                          controller: titleController,
                          label: 'Course Title',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter course title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        _buildDialogTextField(
                          controller: descriptionController,
                          label: 'Description',
                          icon: Icons.description,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF404040)),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.category, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            dropdownColor: const Color(0xFF2D2D2D),
                            style: const TextStyle(color: Colors.white),
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price
                        _buildDialogTextField(
                          controller: priceController,
                          label: 'Price (\$)',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter valid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Duration
                        _buildDialogTextField(
                          controller: durationController,
                          label: 'Duration (Total hours)',
                          icon: Icons.access_time,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter duration';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter valid duration';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Delivery Method Section
                        _buildSectionTitle('Delivery Method'),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF404040)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: isOnline,
                                      onChanged: (value) {
                                        setState(() {
                                          isOnline = value!;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    const Text(
                                      'Online',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<bool>(
                                      value: false,
                                      groupValue: isOnline,
                                      onChanged: (value) {
                                        setState(() {
                                          isOnline = value!;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    const Text(
                                      'In-Person',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location field (only show if in-person)
                        if (!isOnline)
                          _buildDialogTextField(
                            controller: locationController,
                            label: 'Location',
                            icon: Icons.location_on,
                            validator: (value) {
                              if (!isOnline && (value == null || value.isEmpty)) {
                                return 'Please enter location for in-person course';
                              }
                              return null;
                            },
                          ),
                        if (!isOnline) const SizedBox(height: 24),

                       
                        // Schedule Section
                        _buildSectionTitle('Schedule'),
                        const SizedBox(height: 16),

                        // Start Date
                        GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      surface: Color(0xFF2D2D2D),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null && picked != startDate) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF404040)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start Date',
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    Text(
                                      startDate != null
                                          ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                          : 'Select start date',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // End Date
                        GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? (startDate?.add(const Duration(days: 30)) ?? DateTime.now()),
                              firstDate: startDate ?? DateTime.now(),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      surface: Color(0xFF2D2D2D),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null && picked != endDate) {
                              setState(() {
                                endDate = picked;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF404040)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'End Date (Optional)',
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    Text(
                                      endDate != null
                                          ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                          : 'Select end date',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    // Validation for start date
                                    if (startDate == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please select a start date'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final updatedSession = Session(
                                      id: session.id,
                                      title: titleController.text,
                                      instructor: session.instructor, // or provide a controller if editable
                                      instructorId: session.instructorId, // required
                                      description: descriptionController.text,
                                      category: selectedCategory,
                                      isOnline: isOnline,
                                      location: isOnline ? null : locationController.text,
                                      //meetingUrl: isOnline ? meetingUrlController.text : null, // add this if you have a controller
                                      price: double.parse(priceController.text),
                                      startDate: startDate!,
                                      endDate: endDate,
                                      rating: session.rating, // or provide a controller if editable
                                      image: session.image,
                                      durationHours: int.parse(durationController.text),
                                      isBooked: isBooked,
                                    );


                                    vm.updateSession(updatedSession);

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Course updated successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Update Course',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Session session, SessionViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text(
              'Are you sure you want to delete "${session.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                vm.deleteSession(session.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Not set';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'No Courses Created Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Tap the + button to create your first course'),
        ],
      ),
    );
  }
}