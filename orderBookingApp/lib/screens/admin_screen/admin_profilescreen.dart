import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/token_provider.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/employeelist_screen.dart';
import 'package:order_booking_app/screens/login_screen.dart';

// Minimal Theme Colors
class MinimalTheme {
  static const primaryOrange = Color(0xFFFF8C42);
  static const backgroundGray = Color(0xFFF5F5F5);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2D2D2D);
  static const textGray = Color(0xFF6B7280);
  static const iconGray = Color(0xFF9CA3AF);
  static const successGreen = Color(0xFF10B981);
  static const errorRed = Color(0xFFEF4444);
}

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

  bool _isNetworkError(String? message) {
    if (message == null) return false;
    final msg = message.toLowerCase();
    return [
      'network',
      'internet',
      'connection',
      'socket',
      'failed host',
      'no address',
      'timeout',
      'unreachable',
    ].any(msg.contains);
  }

  Widget _buildNoInternet() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 200),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: MinimalTheme.primaryOrange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 34,
                    color: MinimalTheme.primaryOrange,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: MinimalTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your WiFi or mobile data\nand try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: MinimalTheme.textGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MinimalTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 200),
        Center(child: Text('Error: $message')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminloginViewModelProvider);
    final detailsAsync = adminState.adminDetails;

    return Scaffold(
      backgroundColor: MinimalTheme.backgroundGray,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: MinimalTheme.primaryOrange,
        child: detailsAsync!.isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: CircularProgressIndicator(
                      color: MinimalTheme.primaryOrange,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              )
            : detailsAsync.hasError
                ? _isNetworkError(detailsAsync.error.toString())
                    ? _buildNoInternet()
                    : _buildError(detailsAsync.error.toString())
                : detailsAsync.when(
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
                        Center(
                          child: CircularProgressIndicator(
                            color: MinimalTheme.primaryOrange,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ],
                    ),
                    error: (e, _) => _isNetworkError(e.toString())
                        ? _buildNoInternet()
                        : _buildError(e.toString()),
                  ),
      ),
    );
  }

  Widget _buildProfileContent(AdminLogin adminLogin) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Profile Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MinimalTheme.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (adminLogin.adminName ?? "A")
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: MinimalTheme.primaryOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminLogin.adminName ?? "User",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        adminLogin.companyName ?? "",
                        style: const TextStyle(
                          fontSize: 13,
                          color: MinimalTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Icon
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          adminLogin: adminLogin,
                          mobileNo:
                              ref.read(adminloginViewModelProvider).mobileNo ??
                                  "",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: MinimalTheme.iconGray,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Profile Information Card
          _buildProfileInfoCard(adminLogin),

          const SizedBox(height: 16),

          // Deleted Employees
          _buildDeletedEmployeesCard(),

          const SizedBox(height: 16),

          // Logout Button
          _buildLogoutButton(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDeletedEmployeesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminEmployeesPage(activeStatus: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MinimalTheme.cardWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MinimalTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: MinimalTheme.errorRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deleted Employees',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MinimalTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'View inactive or deleted staff',
                      style: TextStyle(
                        fontSize: 12,
                        color: MinimalTheme.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: MinimalTheme.iconGray,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(AdminLogin adminLogin) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MinimalTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.business_outlined,
            "Company Name",
            adminLogin.companyName ?? "",
          ),
          _buildInfoRow(
            Icons.person_outline,
            "Owner Name",
            adminLogin.adminName ?? "",
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            "Mobile Number",
            adminLogin.mobileNo ?? "",
          ),
          _buildInfoRow(
            Icons.email_outlined,
            "Email Address",
            adminLogin.email ?? "",
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            "Address",
            adminLogin.address ?? "",
          ),
          _buildInfoRow(
            Icons.receipt_long_outlined,
            "GSTIN Number",
            adminLogin.gstinNo ?? "",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: MinimalTheme.iconGray),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: MinimalTheme.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : "Not provided",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MinimalTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MinimalTheme.errorRed,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: MinimalTheme.errorRed.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isConnected = ref.read(networkStateProvider).isConnected;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalTheme.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                color: MinimalTheme.errorRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MinimalTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isConnected
                  ? 'Are you sure you want to logout?'
                  : 'You are offline, logout may cause data loss. Continue?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: MinimalTheme.textGray,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isConnected ? 'Cancel' : 'No',
              style: const TextStyle(color: MinimalTheme.textGray),
            ),
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
              backgroundColor: MinimalTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
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
    nameController =
        TextEditingController(text: widget.adminLogin.adminName ?? "");
    emailController =
        TextEditingController(text: widget.adminLogin.email ?? "");
    companyController =
        TextEditingController(text: widget.adminLogin.companyName ?? "");
    mobileController =
        TextEditingController(text: widget.adminLogin.mobileNo ?? "");
    addressController =
        TextEditingController(text: widget.adminLogin.address ?? "");
    gstinController =
        TextEditingController(text: widget.adminLogin.gstinNo ?? "");
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

      await ref
          .read(adminloginViewModelProvider.notifier)
          .addAdminDetails(updatedProfile);
      await ref
          .read(adminloginViewModelProvider.notifier)
          .fetchAdminDetails(
              ref.read(adminloginViewModelProvider).mobileNo ?? "");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 12),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: MinimalTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
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
                const Icon(Icons.error, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: MinimalTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
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
            const Icon(Icons.warning, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: MinimalTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: MinimalTheme.cardWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: MinimalTheme.textDark),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: MinimalTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Profile Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  (nameController.text.isNotEmpty ? nameController.text : "A")
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: MinimalTheme.primaryOrange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Form Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MinimalTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: companyController,
                    label: "Company Name",
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: nameController,
                    label: "Owner Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: mobileController,
                    label: "Mobile Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: addressController,
                    label: "Address",
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: gstinController,
                    label: "GSTIN Number",
                    icon: Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MinimalTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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
                          : const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: !isSaving,
      style: const TextStyle(
        fontSize: 14,
        color: MinimalTheme.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: MinimalTheme.textGray,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: MinimalTheme.iconGray,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: MinimalTheme.primaryOrange,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: MinimalTheme.cardWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        counterText: '',
      ),
    );
  }
}
