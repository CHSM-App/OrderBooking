import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/admin_login.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/landing_Screen.dart';
import 'package:order_booking_app/screens/employee_screen/login_screen.dart';

class AdminProfilePage extends ConsumerStatefulWidget {
  final String mobileNo;

  const AdminProfilePage({
    super.key,
    required this.mobileNo,
  });

  @override
  ConsumerState<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends ConsumerState<AdminProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch admin details when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminloginViewModelProvider.notifier).fetchAdminDetails("9876543210");
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminloginViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${adminState.error}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(adminloginViewModelProvider.notifier)
                              .fetchAdminDetails("9876543210");
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : adminState.adminDetails!.when(
  data: (profile) => profile.isEmpty 
      ? const Center(child: Text('No admin details found'))
      : _buildProfileContent(profile.first),  // or profile[0]
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, stack) => Center(
    child: Text('Error: $error'),
  ),
),
    );
  }

  Widget _buildProfileContent(AdminLogin adminLogin) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header with gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF57C00), Color(0xFFF57C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  // child: CircleAvatar(
                  //   radius: 50,
                  //   backgroundColor: Colors.white,
                  //   backgroundImage: profile.imagePath != null
                  //       ? FileImage(File(profile.imagePath!))
                  //       : null,
                  //   child: profile.imagePath == null
                  //       ? const Icon(
                  //           Icons.person,
                  //           size: 50,
                  //           color: Color(0xFF2196F3),
                  //         )
                  //       : null,
                  // ),
                   child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: FileImage(File("")),
                    child: null,
                  ),  
                ),
                const SizedBox(height: 16),
                Text(
                  adminLogin.adminName??"",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adminLogin.email??"",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Profile Information Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.business, "Company", adminLogin.companyName??""),
                _buildInfoRow(Icons.person_outline, "Owner", adminLogin.adminName??""),
                _buildInfoRow(Icons.phone_outlined, "Mobile", adminLogin.mobileNo??""),
                _buildInfoRow(Icons.email_outlined, "Email", adminLogin.email??""),
                _buildInfoRow(
                    Icons.location_on_outlined, "Address", adminLogin.address??""),
                _buildInfoRow(
                    Icons.receipt_long_outlined, "GSTIN", adminLogin.gstinNo??""),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          _buildActionTile(
            Icons.edit_outlined,
            "Edit Profile",
            "Update your profile information",
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    adminLogin: adminLogin,
                    mobileNo: "9876543210",
                  ),
                ),
              );
            },
          ),

          _buildActionTile(
            Icons.logout,
            "Logout",
            "Sign out from your account",
            Colors.red,
            () {
              // Handle logout
              _showLogoutDialog(context);
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // close dialog

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // remove all previous routes
            );
          },
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

}

//  admin Edit Profile Page
class EditProfilePage extends ConsumerStatefulWidget {
  final AdminLogin adminLogin;
  final String mobileNo;

  const EditProfilePage({
    super.key,
    required this.adminLogin,
    required this.mobileNo,
  });

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController companyController;
  late TextEditingController mobileController;
  late TextEditingController addressController;
  late TextEditingController gstinController;
  String? imagePath;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.adminLogin.adminName??"");
    emailController = TextEditingController(text: widget.adminLogin.email??"");
    companyController = TextEditingController(text: widget.adminLogin.companyName??"");
    mobileController = TextEditingController(text: widget.adminLogin.mobileNo??"");
    addressController = TextEditingController(text: widget.adminLogin.address??"");
    gstinController = TextEditingController(text: widget.adminLogin.gstinNo??"");
    // imagePath = widget.profile.imagePath;
    
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    mobileController.dispose();
    addressController.dispose();
    gstinController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedProfile = AdminLogin(
        adminId: widget.adminLogin.adminId,
        adminName: nameController.text.trim(),
        email: emailController.text.trim(),
        companyName: companyController.text.trim(),
       mobileNo: mobileController.text.trim(),
        address: addressController.text.trim(),
        gstinNo: gstinController.text.trim(),
      role_id: 1,
      );

      // Call your update method here
      await ref.read(adminloginViewModelProvider.notifier).addAdminDetails(updatedProfile);

      // Refresh the profile data
      await ref.read(adminloginViewModelProvider.notifier).fetchAdminDetails("9876543210");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  bool _validateFields() {
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter owner name');
      return false;
    }
    if (companyController.text.trim().isEmpty) {
      _showError('Please enter company name');
      return false;
    }
    if (mobileController.text.trim().isEmpty) {
      _showError('Please enter mobile number');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter email');
      return false;
    }
    if (!_isValidEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF2196F3),
       
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Image Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2196F3), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        imagePath != null ? FileImage(File(imagePath!)) : null,
                    child: imagePath == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Profile Photo",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            // Form Fields
         // Form Fields
Container(
  margin: const EdgeInsets.symmetric(horizontal: 20),
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 15,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: [
      _buildTextField(
        controller: companyController,
        label: "Company / Business Name",
        icon: Icons.business,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: nameController,
        label: "Owner Name",
        icon: Icons.person_outline,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: mobileController,
        label: "Mobile Number",
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: emailController,
        label: "Email",
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: addressController,
        label: "Address",
        icon: Icons.location_on_outlined,
        maxLines: 2,
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: gstinController,
        label: "GSTIN Number",
        icon: Icons.receipt_long_outlined,
      ),
      
      // ✅ Save Button added here (below GSTIN field)
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    ],
  ),
),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !isSaving,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
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
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}