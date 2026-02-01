import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addProduct.dart';
import 'package:order_booking_app/domain/models/product.dart';

class AdminCatalogPage extends ConsumerStatefulWidget {
  const AdminCatalogPage({super.key});

  @override
  ConsumerState<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends ConsumerState<AdminCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    /// fetch product list (admin id = 1)
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).userId??0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: "Search product...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 📦 PRODUCT LIST
          Expanded(
            child: state.productList!.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (products) {
                final filtered = products.where((p) {
                  return p.productName!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _productCard(context, filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      /// ➕ ADD PRODUCT
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF57C00),
        onPressed: () async {
              final userId = ref.read(adminloginViewModelProvider).userId;

    if (userId == 0) return; 
          // Navigate to Add Product page (null productId = Add)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
        builder: (_) => AddProductPage(adminId: userId),
      ),
          );

          // Refresh list if product added
          if (result == true) {
            ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).userId??0);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _productCard(BuildContext context, Product product) {
    final units = product.subtypes ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Icon(getIconForType(product.productType), size: 30),
        ),

        title: Text(
          product.productName ?? "",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          product.productType ?? "",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProductPage(
                      productId: product.productId,
                      adminId: ref.read(adminloginViewModelProvider).userId??0,
                    ),
                  ),
                );

                if (result == true) {
                  ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).userId??0);
                }
              },
            ),

            // 👇 DROPDOWN INDICATOR (no logic, no state)
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
              size: 28,
            ),
          ],
        ),

        children: [_buildAdminUnits(units)],
      ),
    );
  }

  IconData getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'beverage':
        return Icons.local_drink_rounded;
      case 'grocery':
        return Icons.shopping_bag_rounded;
      case 'ice cream':
        return Icons.icecream_rounded;
      case 'bakery & snacks':
        return Icons.fastfood_rounded;
      case 'dairy':
        return Icons.emoji_food_beverage_rounded;
      case 'personal & home care':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.inventory_2_rounded; // fallback
    }
  }

  Widget _buildAdminUnits(List<ProductSubType> units) {
    if (units.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text("No available units", style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: units.map((u) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    "${formatAvailableUnit(u.availableUnit, u.measuringUnit)}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                "₹${u.price}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String formatAvailableUnit(double? value, String? unit) {
    if (value == null || unit == null) return '';

    final lowerUnit = unit.toLowerCase();

    // Liter → ml
    if (lowerUnit == 'liter' || lowerUnit == 'litre' || lowerUnit == 'l') {
      if (value < 1) {
        return '${(value * 1000).toInt()} ml';
      }
      return '$value Liter';
    }

    // Kilogram → gram
    if (lowerUnit == 'kilogram' || lowerUnit == 'kg') {
      if (value < 1) {
        return '${(value * 1000).toInt()} g';
      }
      return '$value Kg';
    }

    // Default (no conversion)
    return '$value $unit';
  }
}
