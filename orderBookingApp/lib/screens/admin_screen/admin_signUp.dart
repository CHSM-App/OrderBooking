import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/screens/employee_screen/login_screen.dart';

class AdminSignup extends ConsumerStatefulWidget {
  const AdminSignup({super.key});

  @override
  ConsumerState<AdminSignup> createState() => _AdminSignupState();
}

class _AdminSignupState extends ConsumerState<AdminSignup>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _ownerController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();

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
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminloginViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF9C4), // Light Yellow
              Color(0xFFFFF59D), // Soft Yellow
              Color(0xFFFFEE58), // Bright Yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✨ MODERN HEADER
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Animated Icon Container
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 25,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFEE58),
                                      Color(0xFFFFF59D),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 52,
                                  color: Color(0xFF424242),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start your business journey today",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF424242).withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✨ MODERN FORM SECTION
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          children: [
                            // Company Name Field
                            _modernInputField(
                              controller: _companyController,
                              label: "Company Name",
                              hint: "Enter your business name",
                              icon: Icons.business_rounded,
                              iconGradient: const LinearGradient(
                                colors: [Color(0xFFFFEE58), Color(0xFFFFF59D)],
                              ),
                            ),

                            // Owner Name Field
                            _modernInputField(
                              controller: _ownerController,
                              label: "Owner Name",
                              hint: "Enter owner's full name",
                              icon: Icons.person_rounded,
                              iconGradient: const LinearGradient(
                                colors: [Color(0xFFFFD54F), Color(0xFFFFE082)],
                              ),
                            ),

                            // Mobile Number Field
                            _modernInputField(
                              controller: _mobileController,
                              label: "Mobile Number",
                              hint: "Enter contact number",
                              icon: Icons.phone_rounded,
                              iconGradient: const LinearGradient(
                                colors: [Color(0xFF81C784), Color(0xFFA5D6A7)],
                              ),
                              keyboard: TextInputType.phone,
                            ),

                            // Email Field
                            _modernInputField(
                              controller: _emailController,
                              label: "Email Address",
                              hint: "Enter your email",
                              icon: Icons.email_rounded,
                              iconGradient: const LinearGradient(
                                colors: [Color(0xFF64B5F6), Color(0xFF90CAF9)],
                              ),
                              keyboard: TextInputType.emailAddress,
                            ),

                            // Address Field
                            _modernInputField(
                              controller: _addressController,
                              label: "Business Address",
                              hint: "Enter complete address",
                              icon: Icons.location_on_rounded,
                              iconGradient: const LinearGradient(
                                colors: [Color(0xFFE57373), Color(0xFFEF9A9A)],
                              ),
                              maxLines: 3,
                            ),

                            // GST Number Field
                            _modernInputField(
                              controller: _gstController,
                              label: "GSTIN Number",
                              hint: "Enter GST registration number",
                              icon: Icons.receipt_long_rounded,
                              iconGradient: const LinearGradient(
                                colors: [Color(0xFFBA68C8), Color(0xFFCE93D8)],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ✨ MODERN GRADIENT BUTTON
                            Container(
                              height: 58,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFEE58),
                                    Color(0xFFFFF59D),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFEE58).withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: state.isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!.validate()) {
                                            final admin = AdminLogin(
                                              companyName: _companyController.text.trim(),
                                              adminName: _ownerController.text.trim(),
                                              mobileNo: _mobileController.text.trim(),
                                              email: _emailController.text.trim(),
                                              address: _addressController.text.trim(),
                                              gstinNo: _gstController.text.trim(),
                                              role_id: 1,
                                            );

                                            await ref
                                                .read(adminloginViewModelProvider.notifier)
                                                .addAdminDetails(admin);

                                            final result = ref.read(adminloginViewModelProvider);

                                            if (result.error == null) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: const [
                                                        Icon(Icons.check_circle, color: Colors.white),
                                                        SizedBox(width: 12),
                                                        Text("Account created successfully!"),
                                                      ],
                                                    ),
                                                    backgroundColor: const Color(0xFF81C784),
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                );

                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => const LoginScreen(),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        const Icon(Icons.error, color: Colors.white),
                                                        const SizedBox(width: 12),
                                                        Expanded(child: Text(result.error!)),
                                                      ],
                                                    ),
                                                    backgroundColor: const Color(0xFFE57373),
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: state.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF424242),
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.check_circle_outline_rounded,
                                                color: Color(0xFF424242),
                                                size: 24,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                "Create Account",
                                                style: TextStyle(
                                                  color: Color(0xFF424242),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFFFEE58),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: Color(0xFF424242),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
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
      ),
    );
  }

  // ✨ MODERN INPUT FIELD WIDGET
  Widget _modernInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Gradient iconGradient,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
          ),
          // Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              maxLines: maxLines,
              validator: (value) =>
                  value == null || value.isEmpty ? "This field is required" : null,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF424242),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: iconGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFEE58),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE57373),
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE57373),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _companyController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }
}