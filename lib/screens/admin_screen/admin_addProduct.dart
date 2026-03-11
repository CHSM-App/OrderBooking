import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFFE8720C);
const _kSurface       = Color(0xFFFFFFFF);
const _kBackground    = Color(0xFFF5F5F5);
const _kTextPrimary   = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider       = Color(0xFFEEEEEE);
const _kGreen         = Color(0xFF16A34A);
const _kRed           = Color(0xFFDC2626);

class AddProductPage extends ConsumerStatefulWidget {
  final int adminId;
  final Product? initialProduct;

  const AddProductPage({super.key, required this.adminId, this.initialProduct});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _qtyCtrl;

  bool _hasInitializedData = false;

  bool get _isEdit => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _qtyCtrl = TextEditingController();
    if (_isEdit){
    _initFromProduct(widget.initialProduct!);
      
    } 

  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _initFromProduct(Product p) {
    if (_hasInitializedData) return;
    _hasInitializedData = true;
    _nameCtrl.text = p.productName ?? '';
    _qtyCtrl.text = p.quantityPerBox?.toString() ?? '0';
    // final qty = p.subtypes?.isNotEmpty == true ? p.subtypes![0].quantityPerBox : null;
    // if (qty != null) _qtyCtrl.text = qty.toString();
  }

  void _snack(String msg, {Color color = _kPrimary, IconData icon = Icons.info_outline_rounded}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<bool> _ensureOnline() async {
    final ok = await ref.read(networkServiceProvider).checkConnection();
    if (!ok) ref.invalidate(networkStatusProvider);
    return ok;
  }

  String _capitalizeFirst(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  Future<void> _submit() async {
    if (!await _ensureOnline()) {
      _snack('No internet connection', color: Colors.grey.shade800, icon: Icons.wifi_off_rounded);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final productName = _capitalizeFirst(_nameCtrl.text);
    final int? qtyPerBox = _qtyCtrl.text.trim().isNotEmpty
        ? int.tryParse(_qtyCtrl.text.trim())
        : null;

    final product = Product(
      productId: widget.initialProduct?.productId,
      productName: productName,
      createdBy: ref.read(adminloginViewModelProvider).userId,
      companyId: ref.read(adminloginViewModelProvider).companyId ?? '',
      quantityPerBox: qtyPerBox,
      localId: widget.initialProduct == null ? const Uuid().v4() : widget.initialProduct!.localId,
    );

    final productVM = ref.read(productViewModelProvider.notifier);

    try {
      await productVM.addOrUpdateProduct(product);
      productVM.fetchProductList(ref.read(adminloginViewModelProvider).companyId ?? '');
      _snack(
        _isEdit ? 'Product updated successfully' : 'Product added successfully',
        color: _kGreen,
        icon: Icons.check_circle_outline_rounded,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _snack('Failed to save product: $e', color: _kRed, icon: Icons.error_outline_rounded);
    }
  }

  InputDecoration _inputDec({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: _kTextSecondary, fontWeight: FontWeight.w400),
      prefixIcon: Icon(icon, size: 20, color: _kTextSecondary),
      filled: true,
      fillColor: _kBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kDivider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kDivider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kRed)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kRed, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _kTextPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kDivider),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card ──────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.inventory_2_outlined, size: 17, color: _kPrimary),
                          ),
                          const SizedBox(width: 10),
                          const Text('Product Information',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kTextPrimary)),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: _kDivider),

                    // Fields
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name label
                          Row(children: [
                            const Icon(Icons.shopping_bag_outlined, size: 14, color: _kTextSecondary),
                            const SizedBox(width: 5),
                            const Text('Product Name',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSecondary)),
                          ]),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                            decoration: _inputDec(hint: 'Enter product name', icon: Icons.shopping_bag_outlined),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter product name' : null,
                          ),

                          const SizedBox(height: 18),

                          // Quantity / Box label
                          Row(children: [
                            const Icon(Icons.inventory_2_outlined, size: 14, color: _kTextSecondary),
                            const SizedBox(width: 5),
                            const Text('Quantity per Box',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSecondary)),
                          ]),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                            decoration: _inputDec(hint: 'Enter quantity per box', icon: Icons.inventory_2_outlined),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Submit ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: Text(
                    _isEdit ? 'Update Product' : 'Submit Product',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}