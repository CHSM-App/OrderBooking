import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/core/network/token_provider.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/employee_screen/edit_profile.dart';
import 'package:order_booking_app/screens/login_screen.dart';

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
      backgroundColor: const Color(0xFFFAFAFA),
      body: _buildLoadingState(),
    );
  }

  // 2. Error
  if (employeeState.error != null) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _buildErrorState(employeeState.error!),
    );
  }

  // 3. Data null (API call complete but data not set yet)
  final detailsState = employeeState.employeeDetails;
  if (detailsState == null) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _buildLoadingState(), // 🔥 IMPORTANT
    );
  }

  // 4. Empty list
  final list = detailsState.value ?? [];
  if (list.isEmpty) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _buildEmptyStateWithRefresh(),
    );
  }

  // 5. Success
  return Scaffold(
    backgroundColor: const Color(0xFFFAFAFA),
    body: _buildProfileContent(list.first),
  );
}
Widget _buildEmptyStateWithRefresh() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_off_rounded, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        const Text(
          'No data available',
          style: TextStyle(fontSize: 15, color: Color(0xFF999999)),
        ),
        const SizedBox(height: 16),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading...',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
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
                color: const Color(0xFFFF4757).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF4757),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No data available',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF999999),
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
    final isActive = employeeDetails.activeStatus == 1;
    final region = employeeDetails.regionId?.toString() ?? "N/A";
final companyName =ref.read(adminloginViewModelProvider).companyName??"";
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child:
        RefreshIndicator(
  onRefresh: _onRefresh,
  color: Colors.white,
  backgroundColor: const Color(0xFF667EEA),
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
            const SizedBox(height: 12),

          _buildModernProfileHeader(
  employeeName,
  employeeId,
  region ?? "N/A",        // region
  joiningDate ?? "N/A", 
   companyName,         // join date
  imageUrl,                  // image
  isActive, 
               // status
),


            // const SizedBox(height: 20),

            // _buildStatsRow(joiningDate, employeeDetails),

            const SizedBox(height: 20),

            _buildModernSection(
              title: 'Contact',
              child: Column(
                children: [
                  _ModernInfoCard(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: mobileNo ?? "N/A",
                    color: const Color(0xFF667EEA),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _ModernInfoCard(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      value: email,
                      color: const Color(0xFFFF6B9D),
                    ),
                  ],
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _ModernInfoCard(
                      icon: Icons.location_on_rounded,
                      label: 'Address',
                      value: address,
                      color: const Color(0xFFFFA94D),
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
                  _ModernSettingTile(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    onTap: () {},
                  ),
                  _ModernSettingTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Security',
                    onTap: () {},
                  ),
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
)

      ),
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
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Stack(
      children: [
        // MAIN CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT : AVATAR
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFF5F5F5),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                imageUrl,
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildInitialsAvatar(employeeName),
                              ),
                            )
                          : _buildInitialsAvatar(employeeName),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFE74C3C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // RIGHT : DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      region,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                     const SizedBox(height: 4),

                    Text(
                      'Company Name: $companyName',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Joined: $joinDate',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),

                  
                  ],
                ),
              ),
            ],
          ),
        ),

        // EDIT BUTTON
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(
                      name: employeeName,
                      phone: mobileNo ?? "N/A",
                      email: "",
                      address: "",
                      onSave: (_) {
                        ref
                            .read(employeeloginViewModelProvider.notifier)
                            .fetchEmployeeInfo(mobileNo ?? "");
                      },
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: Color(0xFF667EEA),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Widget _buildModernProfileHeader(
//   String employeeName,
//   String employeeId,
//   String? imageUrl,
//   bool isActive,
// ) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Stack(
//       children: [
//         // MAIN CARD
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Avatar + Status
//               Stack(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                       ),
//                     ),
//                     child: CircleAvatar(
//                       radius: 52,
//                       backgroundColor: const Color(0xFFF5F5F5),
//                       child: imageUrl != null && imageUrl.isNotEmpty
//                           ? ClipOval(
//                               child: Image.network(
//                                 imageUrl,
//                                 width: 104,
//                                 height: 104,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, __, ___) =>
//                                     _buildInitialsAvatar(employeeName),
//                               ),
//                             )
//                           : _buildInitialsAvatar(employeeName),
//                     ),
//                   ),
//                   Positioned(
//                     right: 6,
//                     bottom: 6,
//                     child: Container(
//                       width: 14,
//                       height: 14,
//                       decoration: BoxDecoration(
//                         color: isActive
//                             ? const Color(0xFF2ECC71)
//                             : const Color(0xFFE74C3C),
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 2),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               Text(
//                 employeeName,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF2C2C2C),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF1F5F9),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'ID: $employeeId',
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF475569),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // ✏️ EDIT BUTTON (TOP RIGHT)
//         Positioned(
//           top: 12,
//           right: 12,
//           child: Material(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             elevation: 3,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => EditProfilePage(
//                       name: employeeName,
//                       phone: mobileNo ?? "N/A",
//                       email: "", // pass email if needed
//                       address: "",
//                       onSave: (_) {
//                         ref
//                             .read(employeeloginViewModelProvider.notifier)
//                             .fetchEmployeeInfo(mobileNo ?? "");
//                       },
//                     ),
//                   ),
//                 );
//               },
//               child: const Padding(
//                 padding: EdgeInsets.all(8),
//                 child: Icon(
//                   Icons.edit_rounded,
//                   size: 18,
//                   color: Color(0xFF667EEA),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

  Widget _buildInitialsAvatar(String employeeName) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(employeeName),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(String joiningDate, EmployeeLogin employeeDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.calendar_today_rounded,
              label: 'Joined',
              value: joiningDate.isNotEmpty ? _formatDate(joiningDate) : 'N/A',
              color: const Color(0xFF667EEA),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.location_city_rounded,
              label: 'Region',
              value: employeeDetails.regionId?.toString() ?? 'N/A',
              color: const Color(0xFF2ECC71),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2C2C),
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
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
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4757), Color(0xFFE84A5F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4757).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF666666),
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
                color: Color(0xFFFF4757),
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
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// Modern Info Card Widget
class _ModernInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ModernInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
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

// Modern Setting Tile Widget
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
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF666666),
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C2C2C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }
}