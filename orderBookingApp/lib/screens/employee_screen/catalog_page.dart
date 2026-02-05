import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/theme.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Fetch product list on init
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).companyId??"");
    });
  }


  // Filter products based on search query
  void _filterProducts(String query, List<Product> products) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(products);
      } else {
        _filteredProducts = products
            .where((p) =>
  (p.productName ?? '')
      .toLowerCase()
      .contains(query.toLowerCase()))

            .toList();
      }
      _sortProducts();
    });
  }


  // Debounce search input to prevent rebuild on every keystroke
  void _onSearchChanged(String query, List<Product> products) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterProducts(query, products);
    });
  }


  // Sort products (currently only by name)
  void _sortProducts() {
    switch (_sortBy) {
      case 'name':
        _filteredProducts
            .sort((a, b) => a.productName!.compareTo(b.productName!));
        break;
    }
  }


  // Pull-to-refresh
  Future<void> _refreshProducts() async {
    await ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).companyId??"");
    _searchController.clear();
    setState(() {
      _filteredProducts = [];
    });
  }



String formatUnit(double availableUnit, String measuringUnit) {
  String format(double value) {
    // If the value is whole number, show as int, else show as double
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
  }

  switch (measuringUnit.toLowerCase()) {
    case 'liter':
      if (availableUnit >= 1) {
        return '${format(availableUnit)} L';
      } else {
        return '${(availableUnit * 1000).toStringAsFixed(0)} ml';
      }
    case 'kilogram':
      if (availableUnit >= 1) {
        return '${format(availableUnit)} kg';
      } else {
        return '${(availableUnit * 1000).toStringAsFixed(0)} g';
      }
    default:
      return '$availableUnit $measuringUnit';
  }
}



Widget _buildUnits(Product product) {
  final units = product.subtypes;

  if (units == null || units.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'No units available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Column(
      children: units.map((u) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatUnit(u.availableUnit ?? 0, u.measuringUnit ?? ''),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${u.price}',
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
    ),
  );
}


IconData getProductIcon(String? type) {
  switch (type) {
    case 'Beverage':
      return Icons.local_drink;
    case 'Grocery':
      return Icons.shopping_bag;
    case 'Ice Cream':
      return Icons.icecream;
    case 'Bakery & Snacks':
      return Icons.cookie;
    case 'Dairy':
      return Icons.emoji_food_beverage; // milk / beverage icon
    case 'Personal & Home Care':
      return Icons.cleaning_services;
    case 'Others':
    default:
      return Icons.inventory_2_outlined;
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
                // Initialize filtered list only once
                if (_filteredProducts.isEmpty) {
                  _filteredProducts = List.from(products);
                }

                return RefreshIndicator(
                  onRefresh: _refreshProducts,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      /// SEARCH BAR
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              _onSearchChanged(value, products),
                          decoration: const InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                        ),
                      ),

                      /// COUNT
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_filteredProducts.length} Products',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),


                      /// PRODUCT LIST
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProducts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExpansionTile(
                                // leading: const Icon(Icons.inventory_2_outlined),
                                 leading: Icon(getProductIcon(product.productType)),

                                title: Text(
                                  product.productName ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  product.productType ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                children: [_buildUnits(product)],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();   
    _searchController.dispose();
    super.dispose();
  }
}

