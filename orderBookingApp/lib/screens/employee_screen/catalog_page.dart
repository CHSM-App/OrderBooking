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

class _CatalogPageState extends ConsumerState<CatalogPage> with TickerProviderStateMixin {
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name';
  Timer? _debounce;
  
  late AnimationController _headerController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();

        print("inside the initState of the Catalog_page");
    
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // _headerFade = CurvedAnimation(
    //   parent: _headerController,
    //   curve: Curves.easeOut,
    // );
    
    // _headerSlide = Tween<Offset>(
    //   begin: const Offset(0, -0.1),
    //   end: Offset.zero,
    // ).animate(CurvedAnimation(
    //   parent: _headerController,
    //   curve: Curves.easeOutCubic,
    // ));
    
    _headerController.forward();
    
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).companyId??"");
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _filterProducts(String query, List<Product> products) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(products);
      } else {
        _filteredProducts = products
            .where((p) => (p.productName ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
      _sortProducts();
    });
  }

  void _onSearchChanged(String query, List<Product> products) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterProducts(query, products);
    });
  }

  void _sortProducts() {
    switch (_sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a.productName!.compareTo(b.productName!));
        break;
    }
  }

  Future<void> _refreshProducts() async {
    await ref.read(productViewModelProvider.notifier).fetchProductList(ref.read(adminloginViewModelProvider).companyId??"");
    _searchController.clear();
    setState(() {
      _filteredProducts = [];
    });
  }

  String formatUnit(double availableUnit, String measuringUnit) {
    String format(double value) {
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

  Color getProductColor(String? type) {
    switch (type) {
      case 'Beverage':
        return const Color(0xFF00D2FF);
      case 'Grocery':
        return const Color(0xFFFFA94D);
      case 'Ice Cream':
        return const Color(0xFFFF6B9D);
      case 'Bakery & Snacks':
        return const Color(0xFFFFC371);
      case 'Dairy':
        return const Color(0xFF2ECC71);
      case 'Personal & Home Care':
        return const Color(0xFF667EEA);
      case 'Others':
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData getProductIcon(String? type) {
    switch (type) {
      case 'Beverage':
        return Icons.local_drink_rounded;
      case 'Grocery':
        return Icons.shopping_bag_rounded;
      case 'Ice Cream':
        return Icons.icecream_rounded;
      case 'Bakery & Snacks':
        return Icons.cookie_rounded;
      case 'Dairy':
        return Icons.emoji_food_beverage_rounded;
      case 'Personal & Home Care':
        return Icons.cleaning_services_rounded;
      case 'Others':
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: state.isLoading
            ? _buildLoadingState()
            : state.productList!.when(
                data: (products) {
                  if (_filteredProducts.isEmpty && _searchController.text.isEmpty) {
                    _filteredProducts = List.from(products);
                  }

                  return Column(
                    children: [
                      
                      // Modern Header
                      _buildModernHeader(products),
                      
                      // Product List
                      Expanded(
                        child: _buildProductList(),
                      ),
                    ],
                  );
                },
                loading: () => _buildLoadingState(),
                error: (e, _) => _buildErrorState(e.toString()),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF4757),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildModernHeader(List<Product> products) {
  return SafeArea(
    bottom: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          const Text(
            'Product Catalog',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C2C2C),
            ),
          ),

          const SizedBox(height: 14),

          /// SEARCH
          _buildSearchField(products),

          const SizedBox(height: 10),

          /// COUNT BELOW SEARCH
          Text(
            '${_filteredProducts.length} products found',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildSearchField(List<Product> products) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7FB),
      borderRadius: BorderRadius.circular(14),
    ),
    child: TextField(
      controller: _searchController,
      onChanged: (value) => _onSearchChanged(value, products),
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF667EEA),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}

  Widget _buildProductList() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      color: const Color(0xFF667EEA),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _ModernProductCard(
            product: product,
            index: index,
            getProductIcon: getProductIcon,
            getProductColor: getProductColor,
            formatUnit: formatUnit,
          );
        },
      ),
    );
  }
}

// Modern Product Card Widget
class _ModernProductCard extends StatefulWidget {
  final Product product;
  final int index;
  final IconData Function(String?) getProductIcon;
  final Color Function(String?) getProductColor;
  final String Function(double, String) formatUnit;

  const _ModernProductCard({
    required this.product,
    required this.index,
    required this.getProductIcon,
    required this.getProductColor,
    required this.formatUnit,
  });

  @override
  State<_ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<_ModernProductCard> 
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.getProductColor(widget.product.productType);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _controller.forward();
                  } else {
                    _controller.reverse();
                  }
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.getProductIcon(widget.product.productType),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    
                    const SizedBox(width: 14),
                    
                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.productName ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C2C2C),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.product.productType ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Expand Icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF666666),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Expandable Units Section
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildUnitsSection(widget.product, color),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsSection(Product product, Color color) {
    final units = product.subtypes;

    if (units == null || units.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'No units available',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: units.asMap().entries.map((entry) {
        final index = entry.key;
        final unit = entry.value;
        final isLast = index == units.length - 1;
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.05),
                    color.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category_rounded,
                          color: color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.formatUnit(
                          unit.availableUnit ?? 0,
                          unit.measuringUnit ?? '',
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2ECC71),
                          const Color(0xFF27AE60),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '₹${unit.price}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast) const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
}