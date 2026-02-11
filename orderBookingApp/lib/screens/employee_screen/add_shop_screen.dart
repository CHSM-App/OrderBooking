import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

// Theme Colors matching the booking app design
class AddShopTheme {
  // Primary magenta/pink from the design
  static const primaryPink = Color(0xFFE8720C);
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

class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
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
      barrierColor: Colors.black.withOpacity(0.5),
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
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AddShopTheme.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopViewModelProvider);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AddShopTheme.backgroundGray,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                        SizedBox(height: isTablet ? 16 : 14),
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
                        SizedBox(height: isTablet ? 16 : 14),
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

                    SizedBox(height: isTablet ? 20 : 16),

                    // Owner Information Section
                    _buildSectionCard(
                      isTablet: isTablet,
                      title: 'Owner Information',
                      children: [
                        _buildTextField(
                          controller: _ownerNameController,
                          focusNode: _ownerNameFocus,
                          nextFocus: _phoneFocus,
                          label: 'Owner Name',
                          icon: Icons.person_outline_rounded,
                          hint: 'Full name of the owner',
                          isTablet: isTablet,
                        ),
                        SizedBox(height: isTablet ? 16 : 14),
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

                    SizedBox(height: isTablet ? 32 : 28),

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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AddShopTheme.cardWhite,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AddShopTheme.backgroundGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: AddShopTheme.textDark,
          ),
        ),
      ),
      title: const Text(
        'Add New Shop',
        style: TextStyle(
          color: AddShopTheme.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isTablet,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AddShopTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AddShopTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header - Minimal
          Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 20 : 16,
              isTablet ? 18 : 16,
              isTablet ? 20 : 16,
              isTablet ? 12 : 10,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.bold,
                color: AddShopTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Divider
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
            color: Colors.grey.shade100,
          ),

          // Section Content
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
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
        fontSize: isTablet ? 15 : 14,
        fontWeight: FontWeight.w500,
        color: AddShopTheme.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: isTablet ? 20 : 18,
          color: AddShopTheme.textGray,
        ),
        labelStyle: TextStyle(
          fontSize: isTablet ? 14 : 13,
          fontWeight: FontWeight.w400,
          color: AddShopTheme.textGray,
        ),
        hintStyle: TextStyle(
          fontSize: isTablet ? 14 : 13,
          color: AddShopTheme.textGray.withOpacity(0.5),
        ),
        filled: true,
        fillColor: AddShopTheme.backgroundGray,
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
            color: AddShopTheme.primaryPink,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 14,
          vertical: isTablet ? 16 : 14,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
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
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: AddShopTheme.primaryPink,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AddShopTheme.buttonShadow,
        ),
        child: ElevatedButton(
          onPressed: state.isLoading ? null : _saveShop,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: state.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Save Shop',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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

// Minimal Success Dialog
class SuccessDialog extends StatefulWidget {
  const SuccessDialog({Key? key}) : super(key: key);

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
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
            color: AddShopTheme.cardWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AddShopTheme.primaryPink.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon - Minimal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AddShopTheme.primaryPink,
                  shape: BoxShape.circle,
                  boxShadow: AddShopTheme.buttonShadow,
                ),
                child: ScaleTransition(
                  scale: _checkAnimation,
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Success text
              const Text(
                'Shop Added!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AddShopTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'The shop has been successfully\nadded to your system',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AddShopTheme.textGray,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
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
    super.dispose();
  }
}