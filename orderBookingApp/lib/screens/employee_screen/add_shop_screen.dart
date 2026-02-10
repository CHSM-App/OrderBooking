import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerAnimation;

  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _regionController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Focus nodes for better UX
  final _shopNameFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _regionFocus = FocusNode();
  final _ownerNameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    );
    
    _animationController.forward();
    _headerController.forward();
  }

  void _saveShop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final shop = ShopDetails(
      localId: const Uuid().v4(),
      shopName: _shopNameController.text,
      address: _addressController.text,
      regionId: int.tryParse(_regionController.text),
      ownerName: _ownerNameController.text,
      mobileNo: _phoneController.text,
      shopId: 0,
      updatedAt: DateTime.now(),
      companyId: ref.read(adminloginViewModelProvider).companyId ?? "",
    );

    await ref.read(shopViewModelProvider.notifier).addShop(shop);
    final state = ref.read(shopViewModelProvider);

    if (!mounted) return;

    if (state.error == null) {
      _showSuccessDialog();
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) Navigator.pop(context, shop);
    } else {
      _showErrorSnackbar(state.error!);
    }

    await ref.read(shopViewModelProvider.notifier).getShopList(
        ref.read(adminloginViewModelProvider).companyId ?? "");
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => const SuccessDialog(),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopViewModelProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern gradient app bar
          _buildSliverAppBar(isTablet),

          // Form content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Shop Information Section
                        _buildSectionCard(
                          isTablet: isTablet,
                          title: 'Shop Information',
                          subtitle: 'Basic details about the shop',
                          icon: Icons.store_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          children: [
                            _buildTextField(
                              controller: _shopNameController,
                              focusNode: _shopNameFocus,
                              nextFocus: _addressFocus,
                              label: 'Shop Name',
                              icon: Icons.storefront_outlined,
                              hint: 'e.g., Modern Mart',
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            _buildTextField(
                              controller: _addressController,
                              focusNode: _addressFocus,
                              nextFocus: _regionFocus,
                              label: 'Complete Address',
                              icon: Icons.location_on_outlined,
                              hint: 'Street, Area, City, Pincode',
                              maxLines: 3,
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            _buildTextField(
                              controller: _regionController,
                              focusNode: _regionFocus,
                              nextFocus: _ownerNameFocus,
                              label: 'Region ID',
                              icon: Icons.map_outlined,
                              hint: 'Enter region number',
                              keyboardType: TextInputType.number,
                              isTablet: isTablet,
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 24 : 20),

                        // Owner Information Section
                        _buildSectionCard(
                          isTablet: isTablet,
                          title: 'Owner Information',
                          subtitle: 'Contact details of the shop owner',
                          icon: Icons.person_outline_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          children: [
                            _buildTextField(
                              controller: _ownerNameController,
                              focusNode: _ownerNameFocus,
                              nextFocus: _phoneFocus,
                              label: 'Owner Name',
                              icon: Icons.badge_outlined,
                              hint: 'Full name of the owner',
                              isTablet: isTablet,
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            _buildTextField(
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              hint: '+91 XXXXXXXXXX',
                              keyboardType: TextInputType.phone,
                              isTablet: isTablet,
                              isLast: true,
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 40 : 32),

                        // Save Button
                        _buildSaveButton(state, isTablet),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isTablet) {
  return SliverAppBar(
    pinned: true,
    floating: false,
    elevation: 0,
 backgroundColor: const Color(0xFFF8F9FA),
    toolbarHeight: kToolbarHeight + 18, // ✅ little extra for subtitle

    leading: Container(
      margin: const EdgeInsets.all(8),
      // decoration: BoxDecoration(
      //   color: Colors.black.withOpacity(0.2),
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ),

    // ✅ Title + Subtitle
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Add New Shop',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Register shop details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
      ],
    ),

    // ✅ Right side icon
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.add_business_rounded,
            color: Colors.black,
            size: 22,
          ),
          onPressed: () {
            // TODO: right icon action
          },
        ),
      ),
    ],
  );
}


  Widget _buildSectionCard({
    required bool isTablet,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String label,
    required IconData icon,
    required String hint,
    required bool isTablet,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isLast = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else if (isLast) {
          focusNode.unfocus();
        }
      },
      style: TextStyle(
        fontSize: isTablet ? 16 : 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: isTablet ? 22 : 20, color: const Color(0xFF6366F1)),
        ),
        labelStyle: TextStyle(
          fontSize: isTablet ? 15 : 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        ),
        hintStyle: TextStyle(
          fontSize: isTablet ? 15 : 14,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 20 : 16,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        if (label == 'Phone Number' && value.length < 10) {
          return "Enter a valid phone number";
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton(state, bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _saveShop,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: state.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle_outline, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Save Shop',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _regionController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _shopNameFocus.dispose();
    _addressFocus.dispose();
    _regionFocus.dispose();
    _ownerNameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }
}

// Modern Success Dialog with advanced animations
class SuccessDialog extends StatefulWidget {
  const SuccessDialog({Key? key}) : super(key: key);

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    _controller.forward();
    _confettiController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Success Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing background circle
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return Container(
                        width: 120 + (20 * _confettiController.value),
                        height: 120 + (20 * _confettiController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981).withOpacity(
                            0.2 * (1 - _confettiController.value),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Main circle
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF10B981),
                          Color(0xFF059669),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: RotationTransition(
                      turns: _rotateAnimation,
                      child: ScaleTransition(
                        scale: _checkAnimation,
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Success text
              const Text(
                'Shop Added!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'The shop has been successfully\nadded to your system',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              // Checkmark animation indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      final delay = index * 0.2;
                      final progress = (_confettiController.value - delay).clamp(0.0, 1.0);
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981).withOpacity(
                            0.3 + (0.7 * progress),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}