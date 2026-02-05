import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/screens/login_screen.dart';

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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminloginViewModelProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE0B2), // Light Peach
              Color.fromARGB(255, 237, 179, 91), // Soft Orange
              Color(0xFFFFB74D), // Primary Orange
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🎨 HEADER SECTION
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      children: [
                        // Animated Logo Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xFFFFFDF9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9933).withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 15,
                                offset: const Offset(-5, -5),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFB74D),
                                  Color(0xFFFF9933),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF9933).withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.store_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C1810),
                            letterSpacing: -1,
                            shadows: [
                              Shadow(
                                color: Color(0x20000000),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Join us and grow your business",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B4423),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 📋 FORM CONTAINER
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFDF9),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 30,
                            offset: Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          children: [
                            // Company Name
                            _buildModernField(
                              controller: _companyController,
                              label: "Company Name",
                              hint: "e.g., ABC Enterprises",
                              icon: Icons.business_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB74D), Color(0xFFFF9933)],
                              ),
                            ),

                            // Owner Name
                            _buildModernField(
                              controller: _ownerController,
                              label: "Owner Name",
                              hint: "e.g., John Smith",
                              icon: Icons.person_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
                              ),
                            ),

                            // Mobile Number
                            _buildModernField(
                              controller: _mobileController,
                              label: "Mobile Number",
                              hint: "e.g., +91 98765 43210",
                              icon: Icons.phone_android_rounded,
                              keyboard: TextInputType.phone,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                              ),
                            ),

                            // Email
                            _buildModernField(
                              controller: _emailController,
                              label: "Email Address",
                              hint: "e.g., owner@company.com",
                              icon: Icons.email_rounded,
                              keyboard: TextInputType.emailAddress,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                              ),
                            ),

                            // Address
                            _buildModernField(
                              controller: _addressController,
                              label: "Business Address",
                              hint: "Enter your complete address",
                              icon: Icons.location_city_rounded,
                              maxLines: 3,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                              ),
                            ),

                            // GST Number
                            _buildModernField(
                              controller: _gstController,
                              label: "GSTIN Number",
                              hint: "e.g., 22AAAAA0000A1Z5",
                              icon: Icons.account_balance_wallet_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // 🚀 CREATE ACCOUNT BUTTON
                            _buildGradientButton(
                              context: context,
                              isLoading: state.isLoading,
                              onTap: () async {
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
                                      _showSuccessSnackbar();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      _showErrorSnackbar(result.error!);
                                    }
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 24),

                            // Sign In Link
                            _buildSignInLink(context),

                            const SizedBox(height: 12),
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

  // 🎨 MODERN INPUT FIELD
  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Gradient gradient,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C1810),
              ),
            ),
          ),
          // Field Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB74D).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              maxLines: maxLines,
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? "This field is required"
                      : null,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C1810),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFFF8F0),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: const Color(0xFFFFB74D).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFB74D),
                    width: 2.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFE53935),
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFE53935),
                    width: 2.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 GRADIENT BUTTON
  Widget _buildGradientButton({
    required BuildContext context,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB74D),
            Color(0xFFFF9933),
            Color(0xFFFF8800),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9933).withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFFFB74D).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // 🔗 SIGN IN LINK
  Widget _buildSignInLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?  ",
          style: TextStyle(
            color: const Color(0xFF6B4423).withOpacity(0.8),
            fontSize: 15,
            fontWeight: FontWeight.w500,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB74D), Color(0xFFFF9933)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB74D).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ SUCCESS SNACKBAR
  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Account created successfully!",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ❌ ERROR SNACKBAR
  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 4),
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