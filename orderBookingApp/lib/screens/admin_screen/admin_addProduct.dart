import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/product_viewmodel.dart';

class AddProductPage extends ConsumerStatefulWidget {
  final int? productId; // null = add, not null = edit
  final int adminId;

  const AddProductPage({super.key, this.productId, required this.adminId});

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
    "Bakery",
    "Snacks",
  ];

  final List<String> units = [
    "Kilogram",
    "Liter",
    "Piece",
    "Pack",
  ];

  List<Map<String, dynamic>> addedItems = [];
  bool _hasInitializedData = false; // To avoid overwriting user input
  @override
void initState() {
  super.initState();

  productNameController = TextEditingController();

  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  );

  _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
      .animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
  );

  _animationController.forward();

  // Delayed fetch to avoid modifying provider during build
  if (widget.productId != null) {
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier)
          .fetchProductDetails(widget.productId!, widget.adminId);
    });
  }
}




@override
void didUpdateWidget(covariant AddProductPage oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.productId != oldWidget.productId && widget.productId != null) {
    // Fetch new product when productId changes
    ref.read(productViewModelProvider.notifier)
        .fetchProductDetails(widget.productId!, widget.adminId);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both unit and price"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      addedItems.add({
        "subItemId": null,
        "productName": productName,
        "productType": productType ?? '',
        "createdBy": '1',
        "measuringUnit": measuringUnit ?? '',
        "availableUnit": unitController.text,
        "price": priceController.text,
        "companyId":"C0001"
      });
      unitController.clear();
      priceController.clear();
    });
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one unit and price"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    List<ProductSubType> subItems = addedItems
        .map((item) => ProductSubType(
              subItemId: item['subItemId'],
              measuringUnit: item['measuringUnit']!,
              availableUnit: double.tryParse(item['availableUnit']!) ?? 0,
              price: double.tryParse(item['price']!) ?? 0,
            ))
        .toList();

    final product = Product(
      productId: widget.productId,
      productName: productName,
      productType: productType!,
      createdBy: 1,
      subtypes: subItems,
      companyId: "C0001"
    );

    try {
      await ref.read(productViewModelProvider.notifier).addOrUpdateProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.productId != null
              ? "Product updated successfully!"
              : "Product added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save product: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

@override
Widget build(BuildContext context) {
  final productState = ref.watch(productViewModelProvider);

  // Safe listener to update UI
  ref.listen<ProductState>(productViewModelProvider, (previous, next) {
    final details = next.productDetails.value;
    if (details != null && !_hasInitializedData) {
      _hasInitializedData = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          productName = details.product.productName ?? '';
          productNameController.text = productName;
          productType = details.product.productType;
          addedItems = details.subitems.map((s) => {
                "subItemId": s.subItemId,
                "productName": details.product.productName ?? '',
                "productType": details.product.productType ?? '',
                "createdBy": details.product.createdBy.toString(),
                "companyId":details.product.companyId??'',
                "measuringUnit": s.measuringUnit,
                "availableUnit": s.availableUnit.toString(),
                "price": s.price.toString(),
              }).toList();
        });
      });
    }
  });
  

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          widget.productId != null ? "Edit Product" : "Add New Product",
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF57C00),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAnimatedHeader(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF57C00),
          borderRadius:
              BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: const Icon(Icons.add_box_rounded, size: 60, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              widget.productId != null ? "Edit Product Information" : "Product Information",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedField(
              delay: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Product Name"),
                  TextFormField(
                    controller: productNameController,
                    decoration: _buildInputDecoration(hint: "Enter product name", icon: Icons.inventory_2_outlined),
                    validator: (val) => val == null || val.isEmpty ? "Enter product name" : null,
                    onSaved: (val) => productName = val!,
                    onChanged: (val) => productName = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildProductTypeField(),
            const SizedBox(height: 16),
            _buildMeasuringUnitField(),
            const SizedBox(height: 16),
            _buildUnitPriceField(),
            const SizedBox(height: 12),
            _buildAddButton(),
            const SizedBox(height: 24),
            _buildAddedItemsList(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
  Widget _buildProductTypeField() {
    return _buildAnimatedField(
      delay: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Product Type"),
          DropdownButtonFormField2<String>(
            decoration: _buildDropdownDecoration(icon: Icons.category_outlined),
            items: productTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            value: productType,
            onChanged: (val) => setState(() => productType = val),
            validator: (val) => val == null || val.isEmpty ? "Select product type" : null,
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
          _buildLabel("Measuring Unit"),
          DropdownButtonFormField2<String>(
            decoration: _buildDropdownDecoration(icon: Icons.straighten_outlined),
            items: units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
            value: measuringUnit,
            onChanged: (val) => setState(() => measuringUnit = val),
            validator: (val) => val == null || val.isEmpty ? "Select measuring unit" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitPriceField() {
    return _buildAnimatedField(
      delay: 300,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Available Unit"),
                TextFormField(
                  controller: unitController,
                  decoration: _buildInputDecoration(hint: "Enter unit value", icon: Icons.straighten_outlined),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Price"),
                TextFormField(
                  controller: priceController,
                  decoration: _buildInputDecoration(hint: "Enter price (₹)", icon: Icons.price_change_outlined),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return _buildAnimatedField(
      delay: 400,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 37, 121, 180),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color.fromARGB(255, 45, 78, 139).withOpacity(0.3),
              ),
            ),
          ),
          child: const Text(
            "Add Unit & Price",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
Widget _buildAddedItemsList() {
  if (addedItems.isEmpty) return const SizedBox.shrink();

  final productVM = ref.read(productViewModelProvider.notifier);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Added Items", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
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
                scale: value,
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text("${item['productName']} (${item['productType']})"),
                subtitle: Text("Unit: ${item['availableUnit']} ${item['measuringUnit']} • Price: ₹${item['price']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final subItemId = item['subItemId'];

                    if (subItemId != null) {
                      // Confirm deletion
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Subitem"),
                          content: const Text("Are you sure you want to delete this subitem?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      // Call API to delete
                      try {
                        await productVM.deleteProductSubType(subItemId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Subitem deleted successfully"), backgroundColor: Colors.green),
                        );

                        setState(() {
                          addedItems.removeAt(index);
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to delete subitem: $e"), backgroundColor: Colors.red),
                        );
                      }
                    } else {
                      // Local item not saved yet, just remove from list
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
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFFF57C00).withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 22),
              SizedBox(width: 8),
              Text(
                "Submit Product",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      );

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 37, 121, 180), size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 37, 121, 180), width: 2),
        ),
      );

  InputDecoration _buildDropdownDecoration({required IconData icon}) =>
      InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 37, 121, 180), size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 37, 121, 180), width: 2),
        ),
      );
}


