import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/token_provider.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/login_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminloginViewModelProvider.notifier).fetchAdminDetails(
          ref.read(adminloginViewModelProvider).mobileNo ?? "");
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(adminloginViewModelProvider.notifier)
        .fetchAdminDetails(
          ref.read(adminloginViewModelProvider).mobileNo ?? "",
        );
  }

  // Check if error is network-related
  bool _isNetworkError(String? errorMessage) {
    if (errorMessage == null) return false;
    
    final networkKeywords = [
      'network',
      'internet',
      'connection',
      'socket',
      'failed host lookup',
      'no address associated',
      'timeout',
      'unreachable',
      'failed to connect',
    ];
    
    final lowerError = errorMessage.toLowerCase();
    return networkKeywords.any((keyword) => lowerError.contains(keyword));
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminloginViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF6C63FF),
        child: adminState.isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 300),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : adminState.error != null
                ? _isNetworkError(adminState.error)
                    ? _buildNoInternetWidget()
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 200),
                          Center(child: Text('Error: ${adminState.error}')),
                        ],
                      )
                : adminState.adminDetails!.when(
                    data: (profile) => profile.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 200),
                              Center(child: Text('No admin details found')),
                            ],
                          )
                        : _buildProfileContent(profile.first),
                    loading: () => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 300),
                        Center(child: CircularProgressIndicator()),
                      ],
                    ),
                    error: (e, _) => _isNetworkError(e.toString())
                        ? _buildNoInternetWidget()
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 200),
                              Center(child: Text('Error: $e')),
                            ],
                          ),
                  ),
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated WiFi Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.red.shade50],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 80,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Please check your internet connection\nand try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Retry Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tips Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.shade100,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('Check your WiFi or mobile data'),
                    _buildTipItem('Try turning airplane mode on/off'),
                    _buildTipItem('Restart your router if using WiFi'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(AdminLogin adminLogin) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // White Profile Card with Image on Left
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile Avatar on Left
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      (adminLogin.adminName ?? "A").substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Name and Details on Right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminLogin.adminName ?? "User",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Text(
                          //   adminLogin.companyName != null && adminLogin.companyName!.isNotEmpty
                          //       ? adminLogin.companyName!
                          //       : "1",
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Company Name: ${adminLogin.companyName ?? "null"}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "Joined:",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Edit Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            adminLogin: adminLogin,
                            mobileNo: ref.read(adminloginViewModelProvider).mobileNo ?? "",
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.grey[700],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
              
          // Stats Cards
          _buildStatsSection(),
          
          const SizedBox(height: 24),

          // Profile Information Card
          _buildProfileInfoCard(adminLogin),

          const SizedBox(height: 20),

          // Action Buttons
          _buildActionButtons(adminLogin),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.store_rounded,
              label: "Business",
              value: "Active",
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.verified_user_rounded,
              label: "Status",
              value: "Verified",
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.admin_panel_settings_rounded,
              label: "Role",
              value: "Admin",
              color: const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(AdminLogin adminLogin) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Profile Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildModernInfoRow(
            Icons.business_rounded,
            "Company Name",
            adminLogin.companyName ?? "",
            const Color(0xFF6C63FF),
          ),
          _buildModernInfoRow(
            Icons.person_outline_rounded,
            "Owner Name",
            adminLogin.adminName ?? "",
            const Color(0xFF4CAF50),
          ),
          _buildModernInfoRow(
            Icons.phone_android_rounded,
            "Mobile Number",
            adminLogin.mobileNo ?? "",
            const Color(0xFF2196F3),
          ),
          _buildModernInfoRow(
            Icons.email_rounded,
            "Email Address",
            adminLogin.email ?? "",
            const Color(0xFFFF9800),
          ),
          _buildModernInfoRow(
            Icons.location_on_rounded,
            "Address",
            adminLogin.address ?? "",
            const Color(0xFFE91E63),
          ),
          _buildModernInfoRow(
            Icons.receipt_long_rounded,
            "GSTIN Number",
            adminLogin.gstinNo ?? "",
            const Color(0xFF9C27B0),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : "Not provided",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildActionButtons(AdminLogin adminLogin) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildModernActionTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            subtitle: "Sign out from account",
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFE91E63)],
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isConnected = ref.read(networkStateProvider).isConnected;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: Text(
          isConnected
              ? 'Are you sure you want to logout?'
              : 'You are offline, logout may cause data loss, still want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isConnected ? 'Cancel' : 'No'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tokenProvider.notifier).clearTokens();
              ref.read(adminloginViewModelProvider.notifier).clearLogin();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isConnected ? 'Logout' : 'Yes'),
          ),
        ],
      ),
    );
  }
}

// ==================== EDIT PROFILE PAGE ====================

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
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.adminLogin.adminName ?? "");
    emailController = TextEditingController(text: widget.adminLogin.email ?? "");
    companyController = TextEditingController(text: widget.adminLogin.companyName ?? "");
    mobileController = TextEditingController(text: widget.adminLogin.mobileNo ?? "");
    addressController = TextEditingController(text: widget.adminLogin.address ?? "");
    gstinController = TextEditingController(text: widget.adminLogin.gstinNo ?? "");
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
    if (!_validateFields()) return;

    setState(() => isSaving = true);

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

      await ref.read(adminloginViewModelProvider.notifier).addAdminDetails(updatedProfile);
      await ref.read(adminloginViewModelProvider.notifier).fetchAdminDetails(
          ref.read(adminloginViewModelProvider).mobileNo ?? "");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
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
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Profile Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF6C63FF), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                      child: Text(
                        (nameController.text.isNotEmpty
                                ? nameController.text
                                : "A")
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Update Profile Photo",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                // Form Fields
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildModernTextField(
                        controller: companyController,
                        label: "Company / Business Name",
                        icon: Icons.business_rounded,
                        color: const Color(0xFF6C63FF),
                      ),
                      const SizedBox(height: 20),
                      _buildModernTextField(
                        controller: nameController,
                        label: "Owner Name",
                        icon: Icons.person_outline_rounded,
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 20),
                      _buildModernTextField(
                        controller: mobileController,
                        label: "Mobile Number",
                        icon: Icons.phone_android_rounded,
                        color: const Color(0xFF2196F3),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _buildModernTextField(
                        controller: emailController,
                        label: "Email Address",
                        icon: Icons.email_rounded,
                        color: const Color(0xFFFF9800),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildModernTextField(
                        controller: addressController,
                        label: "Address",
                        icon: Icons.location_on_rounded,
                        color: const Color(0xFFE91E63),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      _buildModernTextField(
                        controller: gstinController,
                        label: "GSTIN Number",
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFF9C27B0),
                      ),
                      const SizedBox(height: 30),

                      // Save Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: !isSaving,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: color, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}