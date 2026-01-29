// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:order_booking_app/domain/models/product_details_response.dart';
// import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
// import 'package:order_booking_app/screens/theme.dart';

// class CatalogPage extends ConsumerStatefulWidget {
//   const CatalogPage({Key? key}) : super(key: key);

//   @override
//   ConsumerState<CatalogPage> createState() => _CatalogPageState();
// }

// class _CatalogPageState extends ConsumerState<CatalogPage> {
//   List<ProductDetailsResponse> _filteredProducts = [];
//   final TextEditingController _searchController = TextEditingController();
//   String _sortBy = 'name';
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       ref.read(productViewModelProvider.notifier).fetchProductList(1);
//     });
//   }

//   void _filterProducts(String query, List<ProductDetailsResponse> products) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredProducts = List.from(products);
//       } else {
//         _filteredProducts = products
//             .where((p) =>
//                 p.product.productName!
//                     .toLowerCase()
//                     .contains(query.toLowerCase()))
//             .toList();
//       }
//       _sortProducts();
//     });
//   }

//   void _onSearchChanged(String query, List<ProductDetailsResponse> products) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       _filterProducts(query, products);
//     });
//   }

//   void _sortProducts() {
//     switch (_sortBy) {
//       case 'name':
//         _filteredProducts.sort(
//             (a, b) => a.product.productName!.compareTo(b.product.productName!));
//         break;
//       // Add more sorting options here if needed
//     }
//   }

//   Future<void> _refreshProducts() async {
//     await ref.read(productViewModelProvider.notifier).fetchProductList(1);
//     _searchController.clear();
//     setState(() {
//       _filteredProducts = [];
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(productViewModelProvider);

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: state.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : state.productList!.when(
//               data: (products) {
//                 // Initialize filtered list only once
//                 if (_filteredProducts.isEmpty) {
//                   _filteredProducts = List.from(products);
//                 }

//                 return RefreshIndicator(
//                   onRefresh: _refreshProducts,
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 16),

//                       /// SEARCH BAR
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                         child: TextField(
//                           controller: _searchController,
//                           onChanged: (value) =>
//                               _onSearchChanged(value, products.cast<ProductDetailsResponse>()),
//                           decoration: const InputDecoration(
//                             hintText: 'Search products...',
//                             prefixIcon: Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(8)),
//                             ),
//                           ),
//                         ),
//                       ),

//                       /// COUNT
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             '${_filteredProducts.length} Products',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       /// GRID
//                       Expanded(
//                         child: _filteredProducts.isEmpty
//                             ? const Center(child: Text('No products found'))
//                             : GridView.builder(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 16),
//                                 gridDelegate:
//                                     const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   childAspectRatio: 0.7,
//                                   crossAxisSpacing: 16,
//                                   mainAxisSpacing: 16,
//                                 ),
//                                 itemCount: _filteredProducts.length,
//                                 itemBuilder: (context, index) {
//                                   final product = _filteredProducts[index];
//                                   return Card(
//                                     elevation: 2,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         const Icon(
//                                           Icons.shopping_bag,
//                                           size: 50,
//                                           color: Colors.grey,
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 8),
//                                           child: Text(
//                                             product.product.productName ?? '',
//                                             textAlign: TextAlign.center,
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.w500),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               loading: () =>
//                   const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Center(child: Text(e.toString())),
//             ),
//     );
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }
// }

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
      ref.read(productViewModelProvider.notifier).fetchProductList(1);
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
                p.productName!.toLowerCase().contains(query.toLowerCase()))
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
    await ref.read(productViewModelProvider.notifier).fetchProductList(1);
    _searchController.clear();
    setState(() {
      _filteredProducts = [];
    });
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

                      /// GRID
                      Expanded(
                        child: _filteredProducts.isEmpty
                            ? const Center(child: Text('No products found'))
                            : GridView.builder(
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
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.shopping_bag,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            product.productName ?? '',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

