
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

class _AdminCatalogPageState extends ConsumerState<AdminCatalogPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";
  late AnimationController _animationController;
  
  // 🎨 UNIFIED COLOR THEME - Change these to match your app theme
  final Color primaryColor = const Color(0xFF6366F1);      // Indigo
  final Color primaryDark = const Color(0xFF4F46E5);       // Darker Indigo
  final Color primaryLight = const Color(0xFF818CF8);      // Light Indigo
  final Color accentColor = const Color(0xFFA5B4FC);       // Very Light Indigo
  final Color successColor = const Color(0xFF10B981);      // Green
  final Color backgroundColor = const Color(0xFFF8FAFC);   // Light Gray
  final Color cardColor = Colors.white;
  final Color textPrimary = const Color(0xFF1E293B);       // Dark Gray
  final Color textSecondary = const Color(0xFF64748B);     // Medium Gray

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    /// fetch product list
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(
        ref.read(adminloginViewModelProvider).companyId ?? "",
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          /// 🔍 THEMED SEARCH BAR
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  style: TextStyle(color: textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 24),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: textSecondary),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          /// 📦 PRODUCT LIST
          state.productList!.when(
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 3,
                ),
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: primaryLight),
                    const SizedBox(height: 16),
                    Text(
                      "Error: $err",
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            data: (products) {
              final filtered = products.where((p) {
                return p.productName!.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          searchQuery.isEmpty ? "No products yet" : "No products found",
                          style: TextStyle(
                            fontSize: 18,
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          searchQuery.isEmpty 
                              ? "Add your first product to get started"
                              : "Try a different search term",
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 20,
                  vertical: 10,
                ),
                sliver: isTablet
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth > 900 ? 3 : 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _productCard(context, filtered[index], isTablet: true);
                          },
                          childCount: filtered.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _productCard(context, filtered[index]),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      /// ➕ THEMED FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: primaryColor,
          elevation: 0,
          onPressed: () async {
            final userId = ref.read(adminloginViewModelProvider).userId;
            if (userId == 0) return;

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddProductPage(
                  adminId: userId,
                  initialProduct: null,
                ),
              ),
            );

            if (result == true) {
              ref.read(productViewModelProvider.notifier).fetchProductList(
                ref.read(adminloginViewModelProvider).companyId ?? "",
              );
            }
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: const Text(
            "Add Product",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, Product product, {bool isTablet = false}) {
    final units = product.subtypes ?? [];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryLight.withOpacity(0.2),
                  accentColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryLight.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              getIconForType(product.productType),
              size: 32,
              color: primaryColor,
            ),
          ),
          title: Text(
            product.productName ?? "",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: 0.2,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.2),
                    primaryLight.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryLight.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                product.productType ?? "",
                style: TextStyle(
                  color: primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryLight.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.edit_rounded, color: primaryColor, size: 20),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductPage(
                          adminId: ref.read(adminloginViewModelProvider).userId,
                          initialProduct: product,
                        ),
                      ),
                    );

                    if (result == true) {
                      ref.read(productViewModelProvider.notifier).fetchProductList(
                        ref.read(adminloginViewModelProvider).companyId ?? "",
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: textSecondary,
                size: 28,
              ),
            ],
          ),
          children: [
            _buildAdminUnits(units),
          ],
        ),
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
        return Icons.inventory_2_rounded;
    }
  }

  Widget _buildAdminUnits(List<ProductSubType> units) {
    if (units.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryLight.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, color: textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              "No units available",
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Available Units",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        ...units.map((u) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.05),
                  cardColor,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primaryLight.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryLight.withOpacity(0.2),
                            accentColor.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primaryLight.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_basket_rounded,
                        size: 20,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatAvailableUnit(u.availableUnit, u.measuringUnit),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Unit size",
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        successColor.withOpacity(0.15),
                        successColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: successColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    "₹${u.price}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: successColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String formatAvailableUnit(double? value, String? unit) {
    if (value == null || unit == null) return '';

    final lowerUnit = unit.toLowerCase();

    if (lowerUnit == 'liter' || lowerUnit == 'litre' || lowerUnit == 'l') {
      if (value < 1) {
        return '${(value * 1000).toInt()} ml';
      }
      return '$value Liter';
    }

    if (lowerUnit == 'kilogram' || lowerUnit == 'kg') {
      if (value < 1) {
        return '${(value * 1000).toInt()} g';
      }
      return '$value Kg';
    }

    return '$value $unit';
  }
}