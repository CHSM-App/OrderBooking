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
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _regionController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();

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
      barrierColor: Colors.black54,
      builder: (context) => const SuccessDialog(),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                
                // Shop Information Section
                _buildSectionCard(
                  colorScheme: colorScheme,
                  title: 'Shop Details',
                  icon: Icons.store_rounded,
                  children: [
                    _buildTextField(
                      controller: _shopNameController,
                      label: 'Shop Name',
                      icon: Icons.storefront_outlined,
                      hint: 'Enter shop name',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                      hint: 'Enter complete address',
                      maxLines: 3,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _regionController,
                      label: 'Region ID',
                      icon: Icons.map_outlined,
                      hint: 'Enter region number',
                      keyboardType: TextInputType.number,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Owner Information Section
                _buildSectionCard(
                  colorScheme: colorScheme,
                  title: 'Owner Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildTextField(
                      controller: _ownerNameController,
                      label: 'Owner Name',
                      icon: Icons.badge_outlined,
                      hint: 'Enter owner full name',
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      hint: '+91 XXXXXXXXXX',
                      keyboardType: TextInputType.phone,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                _buildSaveButton(state, colorScheme),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Shop',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            'Fill in the shop details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required ColorScheme colorScheme,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "$label is required" : null,
    );
  }

  Widget _buildSaveButton(state, ColorScheme colorScheme) {
    return FilledButton(
      onPressed: state.isLoading ? null : _saveShop,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: state.isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: colorScheme.onPrimary,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Save Shop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
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
    super.dispose();
  }
}

// Modern Success Dialog
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
      duration: const Duration(milliseconds: 800),
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
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: ScaleTransition(
                  scale: _checkAnimation,
                  child: Icon(
                    Icons.check_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 48,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Shop has been added successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
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