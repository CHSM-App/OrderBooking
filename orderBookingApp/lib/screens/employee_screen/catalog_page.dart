import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/product_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/theme.dart';


class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  List<ProductDetails> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).getProductList();
    });
  }

  void _filterProducts(String query, List<ProductDetails> products) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = products;
      } else {
        _filteredProducts = products
            .where((p) =>
                p.productName!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
      _sortProducts();
    });
  }

  void _sortProducts() {
    switch (_sortBy) {
      case 'name':
        _filteredProducts
            .sort((a, b) => a.productName!.compareTo(b.productName!));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.productList!.when(
              data: (products) {
                _filteredProducts = _filteredProducts.isEmpty
                    ? products
                    : _filteredProducts;

                return Column(
                  children: [
                    const SizedBox(height: 16),

                    /// SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            _filterProducts(value, products),
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),

                    /// COUNT
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${_filteredProducts.length} Products',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    /// GRID
                    Expanded(
                      child: GridView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return Card(
                            child: Center(
                              child: Text(
                                product.productName ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
