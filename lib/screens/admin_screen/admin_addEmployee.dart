import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee_login.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';


class AddEmployeeForm extends ConsumerStatefulWidget {
  const AddEmployeeForm({super.key});

  @override
  ConsumerState<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends ConsumerState<AddEmployeeForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String mobile = '';
  String address = '';
  String email = '';
  String? region;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

    // Save all form fields
    _formKey.currentState!.save();

    // region is now saved; check for empty string
    if (region == null || region!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a region")),
      );
      return;
    }

    final employee = EmployeeLogin(
      empName: name,
      empMobile: mobile,
      empEmail: email,
      empAddress: address,
      regionId: 1,
      roleId: 2,
    );

    await ref
        .read(employeeloginViewModelProvider.notifier)
        .addEmployee(employee);

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
          content: Text("Employee $name added successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Add New Employee",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFF57C00),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Animated Header decoration
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
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
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 60,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Employee Information",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Animated Form container
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
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
                          _buildAnimatedField(
                            delay: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Full Name"),
                                TextFormField(
                                  decoration: _buildInputDecoration(
                                    hint: "Enter employee name",
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (val) => val == null || val.isEmpty
                                      ? "Enter name"
                                      : null,
                                  onSaved: (val) => name = val!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mobile
                          _buildAnimatedField(
                            delay: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Mobile Number"),
                                TextFormField(
                                  decoration: _buildInputDecoration(
                                    hint: "Enter mobile number",
                                    icon: Icons.phone_outlined,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (val) => val == null || val.isEmpty
                                      ? "Enter mobile number"
                                      : null,
                                  onSaved: (val) => mobile = val!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email
                          _buildAnimatedField(
                            delay: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Email Address"),
                                TextFormField(
                                  decoration: _buildInputDecoration(
                                    hint: "Enter email address",
                                    icon: Icons.email_outlined,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) => val == null || val.isEmpty
                                      ? "Enter email"
                                      : null,
                                  onSaved: (val) => email = val!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Address
                          _buildAnimatedField(
                            delay: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Address"),
                                TextFormField(
                                  decoration: _buildInputDecoration(
                                    hint: "Enter complete address",
                                    icon: Icons.home_outlined,
                                  ),
                                  maxLines: 3,
                                  validator: (val) => val == null || val.isEmpty
                                      ? "Enter address"
                                      : null,
                                  onSaved: (val) => address = val!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Region
                          _buildAnimatedField(
                            delay: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Region"),
                                TextFormField(
                                  decoration: _buildInputDecoration(
                                    hint: "Enter region to assign",
                                    icon: Icons.location_on_outlined,
                                  ),
                                  validator: (val) => val == null || val.isEmpty
                                      ? "Enter region to assign"
                                      : null,
                                  onSaved: (val) => region = val!,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ID Proof
                          _buildAnimatedField(
                            delay: 500,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          color: const Color.fromARGB(
                                                  255, 17, 89, 148)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: pickIDProof,
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF2196F3),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text("Browse"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Animated Submit Button
                          _buildAnimatedField(
                            delay: 600,
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF57C00),
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor:
                                      const Color(0xFFF57C00).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      "Add Employee",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
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
        color: const Color.fromARGB(255, 41, 145, 219),
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
          color: Color.fromARGB(255, 37, 121, 180),
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