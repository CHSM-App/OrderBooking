import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme Colors matching the booking app design with orange tones
class EditProfileTheme {
  // Primary orange from the design
  static const primaryOrange = Color(0xFFE8720C);
  static const primaryOrangeDark = Color(0xFFD66608);
  
  // Background colors
  static const backgroundGray = Color(0xFFF5F5F5); // Gray100
  
  // Neutral colors
  static const cardWhite = Color(0xFFFFFBFE);
  static const textDark = Color(0xFF1E1E1E);
  static const textGray = Color(0xFF6B7280);
  
  // Soft shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryOrange.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

class EditProfilePage extends ConsumerStatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String address;
  final Function(Map<String, String>) onSave;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.onSave,
  });

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);
    await Future.delayed(const Duration(seconds: 1));

    widget.onSave({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "email": emailController.text.trim(),
      "address": addressController.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: EditProfileTheme.primaryOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                "Profile updated successfully",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    }

    if (mounted) setState(() => isSaving = false);
  }

  String _initial() => nameController.text.isNotEmpty
      ? nameController.text[0].toUpperCase()
      : "A";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditProfileTheme.backgroundGray,

      // APP BAR - Minimal
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: EditProfileTheme.cardWhite,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: EditProfileTheme.backgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: EditProfileTheme.textDark,
            ),
          ),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: EditProfileTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // AVATAR - Minimal
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: EditProfileTheme.primaryOrange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor:
                    EditProfileTheme.primaryOrange.withOpacity(0.1),
                child: Text(
                  _initial(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: EditProfileTheme.primaryOrange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              "Update profile photo",
              style: TextStyle(
                color: EditProfileTheme.textGray,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 28),

            // FORM CARD - Minimal
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: EditProfileTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: EditProfileTheme.cardShadow,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _modernField(
                      controller: nameController,
                      label: "Full Name",
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v == null || v.length < 3 ? "Invalid name" : null,
                    ),
                    const SizedBox(height: 16),

                    _modernField(
                      controller: phoneController,
                      label: "Phone Number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) => v == null || v.length != 10
                          ? "Invalid number"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _modernField(
                      controller: emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains("@")
                          ? "Invalid email"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _modernField(
                      controller: addressController,
                      label: "Address",
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      validator: (v) => v == null || v.length < 10
                          ? "Enter full address"
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Save Button - Minimal
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: EditProfileTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: EditProfileTheme.buttonShadow,
                        ),
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _modernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 14,
        color: EditProfileTheme.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: EditProfileTheme.textGray,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          icon,
          color: EditProfileTheme.textGray,
          size: 18,
        ),
        filled: true,
        fillColor: EditProfileTheme.backgroundGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: EditProfileTheme.primaryOrange,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        counterText: '', // Hide character counter
      ),
    );
  }
}