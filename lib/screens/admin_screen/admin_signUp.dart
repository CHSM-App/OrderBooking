import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/screens/login_screen.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFFE8720C);
const _kPrimaryLight  = Color(0xFFFFF3E8);
const _kSurface       = Color(0xFFFFFFFF);
const _kBackground    = Color(0xFFF5F5F5);
const _kTextPrimary   = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider       = Color(0xFFEEEEEE);
const _kRed           = Color(0xFFDC2626);

class AdminSignup extends ConsumerStatefulWidget {
  const AdminSignup({super.key});

  @override
  ConsumerState<AdminSignup> createState() => _AdminSignupState();
}

class _AdminSignupState extends ConsumerState<AdminSignup> {
  final _formKey           = GlobalKey<FormState>();
  final _companyCtrl       = TextEditingController();
  final _ownerCtrl         = TextEditingController();
  final _mobileCtrl        = TextEditingController();
  final _emailCtrl         = TextEditingController();
  final _addressCtrl       = TextEditingController();
  final _gstCtrl           = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _ownerCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  // ── Input decoration ───────────────────────────────────────────────────────
  InputDecoration _dec({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _kTextSecondary),
      hintText: hint,
      hintStyle: const TextStyle(
          fontSize: 14,
          color: _kTextSecondary,
          fontWeight: FontWeight.w400),
      prefixIcon: Icon(icon, size: 20, color: _kTextSecondary),
      filled: true,
      fillColor: _kBackground,
      floatingLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _kPrimary),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDivider)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDivider)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kRed)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kRed, width: 1.5)),
      errorStyle: const TextStyle(fontSize: 12, color: _kRed),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminloginViewModelProvider);

    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Page header ────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _kPrimaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.business_center_outlined,
                          size: 24, color: _kPrimary),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Account',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _kTextPrimary,
                                letterSpacing: -0.5)),
                        SizedBox(height: 2),
                        Text('Fill in your business details below',
                            style: TextStyle(
                                fontSize: 13,
                                color: _kTextSecondary)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Info banner ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kPrimaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _kPrimary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 18, color: _kPrimary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'All fields are required to create your account.',
                          style: TextStyle(
                              fontSize: 13,
                              color: _kPrimary,
                              fontWeight: FontWeight.w500,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Form card ──────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kDivider),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Company Name
                      TextFormField(
                        controller: _companyCtrl,
                        style: const TextStyle(
                            fontSize: 14, color: _kTextPrimary),
                        decoration: _dec(
                          label: 'Company Name',
                          hint: 'e.g. Acme Distributors',
                          icon: Icons.business_outlined,
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),

                      // Owner Name
                      TextFormField(
                        controller: _ownerCtrl,
                        style: const TextStyle(
                            fontSize: 14, color: _kTextPrimary),
                        decoration: _dec(
                          label: 'Owner Name',
                          hint: 'Enter full name',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),

                      // Mobile
                      TextFormField(
                        controller: _mobileCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                            fontSize: 14, color: _kTextPrimary),
                        decoration: _dec(
                          label: 'Mobile Number',
                          hint: '+91 98765 43210',
                          icon: Icons.phone_outlined,
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                            fontSize: 14, color: _kTextPrimary),
                        decoration: _dec(
                          label: 'Email Address',
                          hint: 'you@company.com',
                          icon: Icons.email_outlined,
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),

                      // Address
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 3,
                        style: const TextStyle(
                            fontSize: 14, color: _kTextPrimary),
                        decoration: _dec(
                          label: 'Business Address',
                          hint: 'Enter complete address',
                          icon: Icons.location_on_outlined,
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),

                      // GSTIN
                      TextFormField(
                        controller: _gstCtrl,
                        style: const TextStyle(
                            fontSize: 14, color: _kTextPrimary),
                        decoration: _dec(
                          label: 'GSTIN Number',
                          hint: '22AAAAA0000A1Z5',
                          icon: Icons.receipt_long_outlined,
                        ),
                        validator: _required,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Create account button ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _kPrimary.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 20),
                              SizedBox(width: 8),
                              Text('Create Account',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Divider ────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: _kDivider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      child: Text('OR',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  _kTextSecondary.withOpacity(0.7))),
                    ),
                    const Expanded(
                        child: Divider(color: _kDivider)),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Sign in button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    ),
                    icon: const Icon(Icons.login_rounded, size: 18),
                    label: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kPrimary,
                      side: const BorderSide(
                          color: _kPrimary, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final admin = AdminLogin(
      companyName: _companyCtrl.text.trim(),
      adminName:   _ownerCtrl.text.trim(),
      mobileNo:    _mobileCtrl.text.trim(),
      email:       _emailCtrl.text.trim(),
      address:     _addressCtrl.text.trim(),
      gstinNo:     _gstCtrl.text.trim(),
      role_id:     1,
    );

    await ref
        .read(adminloginViewModelProvider.notifier)
        .addAdminDetails(admin);

    final result = ref.read(adminloginViewModelProvider);

    if (!mounted) return;

    if (result.error == null) {
      _snack('Account created successfully!', isError: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _snack(result.error!, isError: true);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: isError ? _kRed : const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: Duration(seconds: isError ? 4 : 3),
    ));
  }
}