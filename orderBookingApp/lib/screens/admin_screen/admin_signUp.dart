
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/login_screen.dart';
import 'package:order_booking_app/domain/models/login_details.dart';


class AdminSignupScreen extends ConsumerStatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  ConsumerState<AdminSignupScreen> createState() =>
      _AdminSignupScreenState();
}

class _AdminSignupScreenState extends ConsumerState<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _ownerController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 🔥 WATCH STATE
    final state = ref.watch(adminloginViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF2196F3),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section (UNCHANGED)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Admin Registration",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create your business account",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Section (UNCHANGED)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _inputField(
                          controller: _companyController,
                          label: "Company / Business Name",
                          icon: Icons.business,
                          iconColor: const Color(0xFF2196F3),
                        ),
                        _inputField(
                          controller: _ownerController,
                          label: "Owner Name",
                          icon: Icons.person,
                          iconColor: const Color(0xFF2196F3),
                        ),
                        _inputField(
                          controller: _mobileController,
                          label: "Mobile Number",
                          icon: Icons.phone,
                          iconColor: const Color(0xFF2196F3),
                          keyboard: TextInputType.phone,
                        ),
                        _inputField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email,
                          iconColor: const Color(0xFF2196F3),
                          keyboard: TextInputType.emailAddress,
                        ),
                        _inputField(
                          controller: _addressController,
                          label: "Address",
                          icon: Icons.location_on,
                          iconColor: const Color(0xFF2196F3),
                          maxLines: 3,
                        ),
                        _inputField(
                          controller: _gstController,
                          label: "GSTIN Number",
                          icon: Icons.receipt_long,
                          iconColor: const Color(0xFF2196F3),
                        ),

                        const SizedBox(height: 32),

                        /// 🔥 ONLY THIS PART LOGIC CHANGED
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2196F3),
                                Color(0xFF1976D2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: state.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final admin = AdminLogin(
                                        companyName:
                                            _companyController.text.trim(),
                                        adminName:
                                            _ownerController.text.trim(),
                                        mobileNo:
                                            _mobileController.text.trim(),
                                        email:
                                            _emailController.text.trim(),
                                        address:
                                            _addressController.text.trim(),
                                        gstinNo:
                                            _gstController.text.trim(),
                                            role_id: 1,
                                      );

                                      await ref
                                          .read(
                                              adminloginViewModelProvider
                                                  .notifier)
                                          .addAdminDetails(admin);

                                      final result = ref.read(
                                          adminloginViewModelProvider);

                                      if (result.error == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Signup successful"),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminLoginScreen(),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(result.error!),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: state.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminLoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 INPUT FIELD (UNCHANGED)
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? "This field is required" : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }
}
