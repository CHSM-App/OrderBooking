import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/token_provider.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/edit_profile.dart';
import 'package:order_booking_app/screens/login_screen.dart';

// Theme Colors matching the booking app design
class ProfileTheme {
  // Primary magenta/pink from the design
  static const primaryPink =Color(0xFFE8720C);
  static const primaryPinkDark = Color(0xFFC01869);
  
  // Background colors
  static const backgroundGray = Color(0xFFF5F5F5); // Gray100
  
  // Neutral colors
  static const cardWhite = Color.fromARGB(255, 255, 255, 255);
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
      color: primaryPink.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? get mobileNo => ref.read(adminloginViewModelProvider).mobileNo;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mobileNo = ref.read(adminloginViewModelProvider).mobileNo;

      if (mobileNo != null && mobileNo.isNotEmpty) {
        ref
            .read(employeeloginViewModelProvider.notifier)
            .fetchEmployeeInfo(mobileNo);
      }
    });
  }

  Future<void> _onRefresh() async {
    final mobileNo = ref.read(adminloginViewModelProvider).mobileNo;
    if (mobileNo != null && mobileNo.isNotEmpty) {
      await ref
          .read(employeeloginViewModelProvider.notifier)
          .fetchEmployeeInfo(mobileNo);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeloginViewModelProvider);

    // 1. Loading
    if (employeeState.isLoading) {
      return Scaffold(
        backgroundColor: ProfileTheme.backgroundGray,
        body: _buildLoadingState(),
      );
    }

    // 2. Error
    if (employeeState.error != null) {
      return Scaffold(
        backgroundColor: ProfileTheme.backgroundGray,
        body: _buildErrorState(employeeState.error!),
      );
    }

    // 3. Data null (API call complete but data not set yet)
    final detailsState = employeeState.employeeDetails;

    // 4. Empty list
    final list = detailsState.value ?? [];
    if (list.isEmpty) {
      return Scaffold(
        backgroundColor: ProfileTheme.backgroundGray,
        body: _buildEmptyStateWithRefresh(),
      );
    }

    // 5. Success
    return Scaffold(
      backgroundColor: ProfileTheme.backgroundGray,
      body: _buildProfileContent(list.first),
    );
  }

  Widget _buildEmptyStateWithRefresh() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ProfileTheme.primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_off_rounded,
              size: 48,
              color: ProfileTheme.primaryPink,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No data available',
            style: TextStyle(
              fontSize: 15,
              color: ProfileTheme.textGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _ModernButton(
            label: 'Refresh',
            icon: Icons.refresh_rounded,
            onPressed: () {
              ref
                  .read(employeeloginViewModelProvider.notifier)
                  .fetchEmployeeInfo(
                    ref.read(adminloginViewModelProvider).mobileNo ?? "",
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ProfileTheme.primaryPink,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ProfileTheme.buttonShadow,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading...',
            style: TextStyle(
              fontSize: 15,
              color: ProfileTheme.textGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ProfileTheme.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: ProfileTheme.primaryPink,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ProfileTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ProfileTheme.textGray,
              ),
            ),
            const SizedBox(height: 24),
            _ModernButton(
              onPressed: () {
                ref
                    .read(employeeloginViewModelProvider.notifier)
                    .fetchEmployeeInfo(
                      ref.read(adminloginViewModelProvider).mobileNo ?? "",
                    );
              },
              label: 'Try Again',
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(EmployeeLogin employeeDetails) {
    final employeeName = employeeDetails.empName ?? "Unknown";
    final employeeId = employeeDetails.empId?.toString() ?? "N/A";
    final email = employeeDetails.empEmail ?? "";
    final address = employeeDetails.empAddress ?? "";
    final imageUrl = employeeDetails.imageUrl;
    final joiningDate = employeeDetails.joiningDate ?? "";
    final isActive = employeeDetails.checkinStatus == 1;
    final region = employeeDetails.regionName?.toString() ?? "N/A";
    final companyName = employeeDetails.companyName ?? "";

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: ProfileTheme.primaryPink,
          backgroundColor: Colors.white,
          displacement: 80,
          strokeWidth: 3,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    _buildModernProfileHeader(
                      employeeName,
                      employeeId,
                      region,
                      joiningDate,
                      companyName,
                      imageUrl,
                      isActive,
                      email,
                      address,
                    ),

                    const SizedBox(height: 20),

                    _buildModernSection(
                      title: 'Contact',
                      child: Column(
                        children: [
                          _ModernInfoCard(
                            icon: Icons.phone_rounded,
                            label: 'Phone',
                            value: mobileNo ?? "N/A",
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Container(
                              height: 1,
                              color: Colors.grey.shade100,
                            ),
                            _ModernInfoCard(
                              icon: Icons.email_rounded,
                              label: 'Email',
                              value: email,
                            ),
                          ],
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Container(
                              height: 1,
                              color: Colors.grey.shade100,
                            ),
                            _ModernInfoCard(
                              icon: Icons.location_on_rounded,
                              label: 'Address',
                              value: address,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildModernSection(
                      title: 'Settings',
                      child: Column(
                        children: [
                          _ModernSettingTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notifications',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _ModernSettingTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _ModernSettingTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Security',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _ModernSettingTile(
                            icon: Icons.help_outline_rounded,
                            title: 'Help Center',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildLogoutButton(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey.shade100,
    );
  }

  Widget _buildModernProfileHeader(
    String employeeName,
    String employeeId,
    String region,
    String joinDate,
    String companyName,
    String? imageUrl,
    bool isActive,
    String? empEmail,
    String? empAddress,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // MAIN CARD - Simplified
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ProfileTheme.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ProfileTheme.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT: AVATAR - Simplified
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ProfileTheme.primaryPink.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: ProfileTheme.primaryPink.withOpacity(0.1),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildInitialsAvatar(employeeName),
                                ),
                              )
                            : _buildInitialsAvatar(employeeName),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFF6B7280),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // RIGHT: DETAILS - Simplified
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: ProfileTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ProfileTheme.textGray,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ProfileTheme.textGray.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Joined ${_formatDate(joinDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ProfileTheme.textGray.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // EDIT BUTTON - Minimal
          Positioned(
            top: 12,
            right: 12,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(
                      name: employeeName,
                      phone: mobileNo ?? "N/A",
                      email: empEmail ?? "N/A",
                      address: empAddress ?? "N/A",
                      onSave: (_) {
                        ref
                            .read(employeeloginViewModelProvider.notifier)
                            .fetchEmployeeInfo(mobileNo ?? "");
                      },
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ProfileTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: ProfileTheme.primaryPink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String employeeName) {
    return Center(
      child: Text(
        _getInitials(employeeName),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ProfileTheme.primaryPink,
        ),
      ),
    );
  }

  Widget _buildModernSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ProfileTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ProfileTheme.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ProfileTheme.cardShadow,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: ProfileTheme.primaryPink,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ProfileTheme.buttonShadow,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: ProfileTheme.cardWhite,
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ProfileTheme.textDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 14,
            color: ProfileTheme.textGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: ProfileTheme.textGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(tokenProvider.notifier).clearTokens();
              ref.read(adminloginViewModelProvider.notifier).clearLogin();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: ProfileTheme.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// Modern Info Card Widget - Minimal Design
class _ModernInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ModernInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: ProfileTheme.textGray,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ProfileTheme.textGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ProfileTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Setting Tile Widget - Minimal Design
class _ModernSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ModernSettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: ProfileTheme.textGray,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ProfileTheme.textDark,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: ProfileTheme.textGray.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern Button Widget
class _ModernButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _ModernButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileTheme.primaryPink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ProfileTheme.buttonShadow,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}