import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee_login.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';


class AddEmployeeForm extends ConsumerStatefulWidget {
  final int? empId; // null means add mode, non-null means edit mode
  final String? initialName;
  final String? initialMobile;
  final String? initialEmail;
  final String? initialAddress;
  final String? initialRegion;

  const AddEmployeeForm({
    super.key,
    this.empId,
    this.initialName,
    this.initialMobile,
    this.initialEmail,
    this.initialAddress,
    this.initialRegion,
  });

  @override
  ConsumerState<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends ConsumerState<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController regionController;

  bool get isEditMode => widget.empId != null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial values if in edit mode
    nameController = TextEditingController(text: widget.initialName ?? '');
    mobileController = TextEditingController(text: widget.initialMobile ?? '');
    emailController = TextEditingController(text: widget.initialEmail ?? '');
    addressController = TextEditingController(text: widget.initialAddress ?? '');
    regionController = TextEditingController(text: widget.initialRegion ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    regionController.dispose();
    super.dispose();
  }

  Future<void> pickIDProof() async {
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    // );
    // if (result != null) {
    //   setState(() {
    //     idProof = result.files.first;
    //   });
    // }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (regionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a region")),
      );
      return;
    }

    final employee = EmployeeLogin(
      empId: widget.empId, // Include empId if editing
      empName: nameController.text,
      empMobile: mobileController.text,
      empEmail: emailController.text,
      empAddress: addressController.text,
      regionId: 1, // you can map region to actual ID if needed
    );

    if (isEditMode) {
      // Update employee
      await ref
          .read(employeeloginViewModelProvider.notifier)
          .updateEmployee(employee);
    } else {
      // Add new employee
      await ref
          .read(employeeloginViewModelProvider.notifier)
          .addEmployee(employee);
    }

    final state = ref.read(employeeloginViewModelProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? "Employee ${nameController.text} updated successfully"
                : "Employee ${nameController.text} added successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  Future<void> deleteEmployee() async {
    if (widget.empId == null) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to delete ${nameController.text}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Call delete API
    await ref
        .read(employeeloginViewModelProvider.notifier);
        // .deleteEmployee(widget.empId!);

    final state = ref.read(employeeloginViewModelProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Employee deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          isEditMode ? "Edit Employee" : "Add New Employee",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
        actions: isEditMode
            ? [
                // IconButton(
                //   // icon: const Icon(Icons.delete_outline),
                //   onPressed: deleteEmployee,
                //   tooltip: 'Delete Employee',
                // ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header decoration
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF57C00),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Icon(
                    isEditMode ? Icons.edit_rounded : Icons.person_add_rounded,
                    size: 60,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEditMode
                        ? "Update Employee Information"
                        : "Employee Information",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            // Form container
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _buildLabel("Full Name"),
                      TextFormField(
                        controller: nameController,
                        decoration: _buildInputDecoration(
                          hint: "Enter employee name",
                          icon: Icons.person_outline,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter name" : null,
                      ),
                      const SizedBox(height: 20),

                      // Mobile
                      _buildLabel("Mobile Number"),
                      TextFormField(
                        controller: mobileController,
                        decoration: _buildInputDecoration(
                          hint: "Enter mobile number",
                          icon: Icons.phone_outlined,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter mobile number" : null,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildLabel("Email Address"),
                      TextFormField(
                        controller: emailController,
                        decoration: _buildInputDecoration(
                          hint: "Enter email address",
                          icon: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter email" : null,
                      ),
                      const SizedBox(height: 20),

                      // Address
                      _buildLabel("Address"),
                      TextFormField(
                        controller: addressController,
                        decoration: _buildInputDecoration(
                          hint: "Enter complete address",
                          icon: Icons.home_outlined,
                        ),
                        maxLines: 3,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter address" : null,
                      ),
                      const SizedBox(height: 20),

                      // Region
                      _buildLabel("Region"),
                      TextFormField(
                        controller: regionController,
                        decoration: _buildInputDecoration(
                          hint: "Enter region to assign",
                          icon: Icons.location_on_outlined,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter region to assign" : null,
                      ),
                      const SizedBox(height: 20),

                      // ID Proof
                      _buildLabel("ID Proof (PDF)"),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF57C00).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.upload_file_outlined,
                                color: Color(0xFFF57C00),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                "No file selected",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: pickIDProof,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFF57C00),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                "Browse",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF57C00),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFFF57C00).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEditMode
                                    ? Icons.check_circle_outline
                                    : Icons.check_circle_outline,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEditMode ? "Update Employee" : "Add Employee",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color.fromARGB(255, 221, 113, 6),
        size: 22,
      ),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFF57C00),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}