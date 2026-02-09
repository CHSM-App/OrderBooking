import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

class AddProductPage extends ConsumerStatefulWidget {
  final int adminId;
  final Product? initialProduct;

  const AddProductPage({super.key, required this.adminId, this.initialProduct});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String productName = '';
  String? productType;
  String? measuringUnit;

  late TextEditingController productNameController;
  final TextEditingController unitController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> productTypes = [
    "Beverage",
    "Grocery",
    "Ice Cream",
    "Bakery & Snacks",
    "Dairy",
    "Personal & Home Care",
    "Others",
  ];

  final List<String> units = ["Kilogram", "Liter", "Piece", "Packet"];

  List<ProductSubType> addedItems = [];
  bool _hasInitializedData = false;

  // Color scheme
  static const primaryOrange = Color(0xFFF57C00);
  static const accentBlue = Color(0xFF2579B4);
  static const lightOrange = Color(0xFFFFE0B2);
  static const darkOrange = Color(0xFFE65100);

  @override
  void initState() {
    super.initState();

    productNameController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    if (widget.initialProduct != null) {
      _initFromProduct(widget.initialProduct!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    productNameController.dispose();
    unitController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void addItem() {
    if (unitController.text.isEmpty || priceController.text.isEmpty) {
      _showSnackBar(
        "Please enter both unit and price",
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    if (productName.isEmpty) {
      _showSnackBar(
        "Please enter product name first",
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    if (measuringUnit == null || measuringUnit!.isEmpty) {
      _showSnackBar(
        "Please select measuring unit first",
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() {
      final subtype = ProductSubType(
        localId: Uuid().v4(),
        subItemId: null,
        measuringUnit: measuringUnit ?? '',
        // measuringUnit: measuringUnit ?? '',
        availableUnit: double.tryParse(unitController.text) ?? 0,
        price: double.tryParse(priceController.text),
      );


      addedItems.add(subtype);
      unitController.clear();
      priceController.clear();
    });
  }

  Future<bool> _ensureOnline() async {
    final isConnected = await ref
        .read(networkServiceProvider)
        .checkConnection();
    if (!isConnected) {
      // Ensure the global banner reflects the latest status.
      ref.invalidate(networkStatusProvider);
      return false;
    }
    return true;
  }

  Future<void> submitForm() async {
    final online = await _ensureOnline();
    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.wifi_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text("No internet connection!"),
            ],
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (addedItems.isEmpty) {
      _showSnackBar(
        "Please add at least one unit and price",
        Colors.orange,
        Icons.info_outline_rounded,
      );
      return;
    }

    _formKey.currentState!.save();

    final product = Product(
      productId: widget.initialProduct?.productId,
      productName: productName,
      productType: productType!,
      createdBy: ref.read(adminloginViewModelProvider).userId,
      subtypes: addedItems,
      companyId: ref.read(adminloginViewModelProvider).companyId ?? '',
    );

    try {
      await ref
          .read(productViewModelProvider.notifier)
          .addOrUpdateProduct(product);

      ref
          .read(productViewModelProvider.notifier)
          .fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? "",
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialProduct != null
                ? "Product updated successfully!"
                : "Product added successfully!",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar(
        "Failed to save product: $e",
        Colors.red,
        Icons.error_outline_rounded,
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
     backgroundColor: Colors.grey[100],
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 31, 30, 30)),
        title: Text(
          widget.initialProduct != null ? "Edit Product" : "Add New Product",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 241, 239, 236),
               // Color(0xFFF57C00),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // boxShadow: [
        //   BoxShadow(
        //     color: primaryOrange.withOpacity(0.1),
        //     blurRadius: 30,
        //     offset: const Offset(0, 10),
        //   ),
        // ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 237, 219, 191).withOpacity(0.3),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 9, 9, 9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color.fromARGB(255, 16, 16, 15),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Fill in the information below",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Form fields
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAnimatedField(
                    delay: 0,
                    child: _buildModernTextField(
                      label: "Product Name",
                      controller: productNameController,
                      icon: Icons.shopping_bag_rounded,
                      hint: "Enter product name",
                      validator: (val) => val == null || val.isEmpty
                          ? "Enter product name"
                          : null,
                      onSaved: (val) => productName = val!,
                      onChanged: (val) => productName = val,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProductTypeField(),
                  const SizedBox(height: 20),
                  _buildMeasuringUnitField(),
                  const SizedBox(height: 24),
                  
                  // Unit and Price section
                  _buildUnitPriceSection(),
                  
                  const SizedBox(height: 24),
                  _buildAddedItemsList(),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: primaryOrange),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryOrange, size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryOrange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildProductTypeField() {
    return _buildAnimatedField(
      delay: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: const [
                Icon(Icons.category_rounded, size: 18, color: primaryOrange),
                SizedBox(width: 8),
                Text(
                  "Product Type",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField2<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: primaryOrange,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: primaryOrange, width: 2),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              elevation: 8,
            ),
            items: productTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            value: productType,
            onChanged: (val) => setState(() => productType = val),
            validator: (val) =>
                val == null || val.isEmpty ? "Select product type" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMeasuringUnitField() {
    return _buildAnimatedField(
      delay: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: const [
                Icon(Icons.straighten_rounded, size: 18, color: primaryOrange),
                SizedBox(width: 8),
                Text(
                  "Measuring Unit",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonFormField2<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.straighten_rounded,
                  color: primaryOrange,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: primaryOrange, width: 2),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              elevation: 8,
            ),
            items: units
                .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(
                        unit,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            value: measuringUnit,
            onChanged: (val) => setState(() => measuringUnit = val),
            validator: (val) =>
                val == null || val.isEmpty ? "Select measuring unit" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitPriceSection() {
    return _buildAnimatedField(
      delay: 300,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentBlue.withOpacity(0.05),
              accentBlue.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentBlue.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: accentBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Add Unit & Price",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCompactTextField(
                    label: "Unit",
                    controller: unitController,
                    icon: Icons.scale_rounded,
                    hint: "Value",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactTextField(
                    label: "Price",
                    controller: priceController,
                    icon: Icons.currency_rupee_rounded,
                    hint: "₹ Amount",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 120, 115, 223),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Add to List",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: accentBlue, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accentBlue, width: 2),
            ),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildAddedItemsList() {
    if (addedItems.isEmpty) return const SizedBox.shrink();

    final productVM = ref.read(productViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.playlist_add_check_rounded,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Added Items (${addedItems.length})",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addedItems.length,
          itemBuilder: (context, index) {
            final item = addedItems[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryOrange.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_rounded,
                      color: primaryOrange,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    "$productName (${item.measuringUnit})",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
               
                  subtitle: Padding(
  padding: const EdgeInsets.only(top: 6),
  child: Wrap(
    spacing: 12,
    runSpacing: 6,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.straighten_rounded,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            "${item.availableUnit} ${item.measuringUnit}",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.currency_rupee_rounded,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 2),
          Text(
            "${item.price}",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ],
  ),
),

                  trailing: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    onPressed: () async {
                      final subItemlocalId = item.localId;

                      if (subItemlocalId != null) {
                        // Confirm deletion
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: const [
                                Icon(Icons.warning_rounded, color: Colors.orange),
                                SizedBox(width: 12),
                                Text("Delete Item"),
                              ],
                            ),
                            content: const Text(
                              "Are you sure you want to delete this item?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        try {
                          await productVM.deleteProductSubType(subItemlocalId);

                          _showSnackBar(
                            "Item deleted successfully",
                            Colors.green,
                            Icons.check_circle_rounded,
                          );

                          setState(() {
                            addedItems.removeAt(index);
                          });
                        } catch (e) {
                          _showSnackBar(
                            "Failed to delete item: $e",
                            Colors.red,
                            Icons.error_outline_rounded,
                          );
                        }
                      } else {
                        setState(() {
                          addedItems.removeAt(index);
                        });
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return _buildAnimatedField(
      delay: 500,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [primaryOrange, darkOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_rounded, size: 24),
              SizedBox(width: 12),
              Text(
                "Submit Product",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initFromProduct(Product product) {
    if (_hasInitializedData) return;
    _hasInitializedData = true;

    setState(() {
      productName = product.productName ?? '';
      productNameController.text = productName;
      productType = product.productType;
      addedItems = _normalizeSubtypes(product.subtypes);
    });
  }

  List<ProductSubType> _normalizeSubtypes(List? raw) {
    if (raw == null) return [];

    return raw
        .map((item) {
          if (item is ProductSubType) return item;
          if (item is Map<String, dynamic>) {
            return ProductSubType.fromJson(item);
          }
          if (item is Map<String, Object?>) {
            return ProductSubType.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        })
        .whereType<ProductSubType>()
        .toList();
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}