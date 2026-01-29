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
      ref.read(productViewModelProvider.notifier).fetchProductList(1);
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
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text("Error: $err"),
              ),
              data: (products) {
                final filtered = products.where((p) {
                  return p.productName!
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
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
          // Navigate to Add Product page (null productId = Add)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductPage(adminId: 1),
            ),
          );

          // Refresh list if product added
          if (result == true) {
            ref.read(productViewModelProvider.notifier).fetchProductList(1);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 🧱 PRODUCT CARD
  Widget _productCard(BuildContext context, Product product) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// 📦 COMMON ICON
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Color(0xFFF57C00),
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            /// PRODUCT INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.productType ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// ✏️ EDIT
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () async {
                // Navigate to AddProductPage with productId (Edit)
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddProductPage(
                      productId: product.productId,
                      adminId: 1,
                    ),
                  ),
                );

                // Refresh list if edited
                if (result == true) {
                  ref.read(productViewModelProvider.notifier).fetchProductList(1);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
