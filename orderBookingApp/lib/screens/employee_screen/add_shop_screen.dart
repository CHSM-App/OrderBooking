import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

class AddShopTheme {
  static const primaryPink = Color(0xFFE8720C);
  static const backgroundGray = Color(0xFFF5F5F5);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF1E1E1E);
  static const textGray = Color(0xFF6B7280);

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
  final ShopDetails? initialShop;

  const AddShopScreen({Key? key, this.initialShop}) : super(key: key);

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // ✅ Only store the selected regionId, not the Region object
  int? _selectedRegionId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Load regions when screen opens
    Future.microtask(() {
      ref.read(regionofflineViewModelProvider.notifier).fetchRegionList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    });

    if (widget.initialShop != null) {
      final shop = widget.initialShop!;


      _shopNameController.text = shop.shopName ?? '';
      _addressController.text = shop.address ?? '';
      _ownerNameController.text = shop.ownerName ?? '';
      _phoneController.text = shop.mobileNo ?? '';
      // ✅ Store only the ID, resolve the object from the list later
      _selectedRegionId = shop.regionId;
    }
  }

  void _saveShop() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final shopName = _capitalizeFirst(_shopNameController.text);
    final ownerName = _capitalizeFirst(_ownerNameController.text);
    final shop = ShopDetails(
      localId: const Uuid().v4(),
      shopName: shopName,
      address: _addressController.text,
      regionId: ref.read(adminloginViewModelProvider).regionId!, // ✅ Use the stored regionId
      ownerName: ownerName,
      mobileNo: _phoneController.text,
      shopId: widget.initialShop?.shopId ?? 0,
      createdBy: ref.read(adminloginViewModelProvider).userId,
      updatedAt: DateTime.now(),
      companyId: ref.read(adminloginViewModelProvider).companyId ?? "",
    );

    try {
      if (widget.initialShop == null) {
        await ref.read(shopViewModelProvider.notifier).addShop(shop);
      } else {
        await ref.read(shopViewModelProvider.notifier).updateShop(shop);
      }
      final state = ref.read(shopViewModelProvider);
      if (!mounted) return;

      if (state.error == null) {
        _showSuccessDialog(
          title: widget.initialShop == null ? 'Shop Added' : 'Shop Updated',
          subtitle: widget.initialShop == null
              ? 'Saved successfully'
              : 'Updated successfully',
        );
        await Future.delayed(const Duration(milliseconds: 1800));
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // close dialog
        Navigator.pop(context, true); // return to shops page
      } else {
        _showErrorSnackbar(state.error!);
      }

      await ref.read(shopViewModelProvider.notifier).getEmpShopList(
            ref.read(adminloginViewModelProvider).companyId ?? "",
            ref.read(adminloginViewModelProvider).regionId ?? 0,
          );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog({
    required String title,
    required String subtitle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SuccessDialog(
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  String _capitalizeFirst(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
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
              child: const Icon(Icons.error_outline,
                  color: Colors.white, size: 20),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regionState = ref.watch(regionofflineViewModelProvider).regionList;
    final shopState = ref.watch(shopViewModelProvider);

    return Scaffold(
      backgroundColor: AddShopTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.initialShop == null ? "Add New Shop" : "Update Shop",
          style: TextStyle(
              color: AddShopTheme.textDark, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: regionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildCard(
                      title: "Shop Information",
                      children: [
                        _buildTextField(
                            controller: _shopNameController,
                            label: "Shop Name"),
                        const SizedBox(height: 14),
                        _buildTextField(
                            controller: _addressController,
                            label: "Address",
                            maxLines: 3),
                        const SizedBox(height: 14),

                        /// ✅ FIXED REGION DROPDOWN
                        /* regionState.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Text(
                            'Failed to load regions: $e',
                            style: const TextStyle(color: Colors.red),
                          ),
                          data: (regions) {
                            // ✅ Resolve the Region object from the SAME list
                            // that will be used for items — guarantees same instance
                            Region? selectedRegion;
                            if (_selectedRegionId != null) {
                              try {
                                selectedRegion = regions.firstWhere(
                                  (r) => r.regionId == _selectedRegionId,
                                );
                              } catch (_) {
                                selectedRegion = null;
                              }
                            }

                            return DropdownButtonFormField<Region>(
                              initialValue: selectedRegion, // ✅ Same instance as item
                              decoration: InputDecoration(
                                labelText: 'Region Name',
                                prefixIcon:
                                    const Icon(Icons.map_outlined),
                                filled: true,
                                fillColor: AddShopTheme.backgroundGray,
                                border: OutlineInputBorder(
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
                              ),
                              items: regions
                                  .map(
                                    (region) => DropdownMenuItem<Region>(
                                      value: region,
                                      child: Text(region.regionName ?? ''),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  // ✅ Store only the ID, not the object
                                  _selectedRegionId = value?.regionId;
                                });

                              },
                              validator: (value) =>
                                  value == null ? "Region is required" : null,
                            );
                          },
                        ), */
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      title: "Owner Information",
                      children: [
                        _buildTextField(
                            controller: _ownerNameController,
                            label: "Owner Name"),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_isSaving || shopState.isLoading) ? null : _saveShop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AddShopTheme.primaryPink,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: (_isSaving || shopState.isLoading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save Shop",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AddShopTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AddShopTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...children
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: label == "Phone Number"
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        if (label == "Phone Number" && value.length < 10) {
          return "Enter valid phone number";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AddShopTheme.backgroundGray,
        border: OutlineInputBorder(
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
      ),
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AddShopTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AddShopTheme.primaryPink.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AddShopTheme.primaryPink,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AddShopTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AddShopTheme.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
