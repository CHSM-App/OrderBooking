import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFFE8720C);
const _kPrimaryLight  = Color(0xFFFFF3E8);
const _kSurface       = Color(0xFFFFFFFF);
const _kBackground    = Color(0xFFF5F5F5);
const _kTextPrimary   = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider       = Color(0xFFEEEEEE);

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productViewModelProvider.notifier).fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query, List<Product> products) {
    setState(() {
      _filteredProducts = query.isEmpty
          ? List.from(products)
          : products
              .where((p) => (p.productName ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
      _filteredProducts.sort(
          (a, b) => (a.productName ?? '').compareTo(b.productName ?? ''));
    });
  }

  void _onSearchChanged(String query, List<Product> products) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterProducts(query, products);
    });
  }

  Future<void> _refreshProducts() async {
    await ref.read(productViewModelProvider.notifier).fetchProductList(
          ref.read(adminloginViewModelProvider).companyId ?? '',
        );
    _searchController.clear();
    setState(() => _filteredProducts = []);
  }

  String formatUnit(double availableUnit, String measuringUnit) {
    String fmt(double v) =>
        v % 1 == 0 ? v.toStringAsFixed(0) : v.toString();
    switch (measuringUnit.toLowerCase()) {
      case 'liter':
        return availableUnit >= 1
            ? '${fmt(availableUnit)} L'
            : '${(availableUnit * 1000).toStringAsFixed(0)} ml';
      case 'kilogram':
        return availableUnit >= 1
            ? '${fmt(availableUnit)} kg'
            : '${(availableUnit * 1000).toStringAsFixed(0)} g';
      default:
        return '$availableUnit $measuringUnit';
    }
  }

  // Each product type gets a distinct but muted accent
  Color _typeColor(String? type) {
    switch (type) {
      case 'Beverage':           return const Color(0xFF0EA5E9);
      case 'Grocery':            return const Color(0xFFF59E0B);
      case 'Ice Cream':          return const Color(0xFFEC4899);
      case 'Bakery & Snacks':    return const Color(0xFFD97706);
      case 'Dairy':              return const Color(0xFF16A34A);
      case 'Personal & Home Care': return const Color(0xFF7C3AED);
      default:                   return const Color(0xFF64748B);
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'Beverage':           return Icons.local_drink_outlined;
      case 'Grocery':            return Icons.shopping_bag_outlined;
      case 'Ice Cream':          return Icons.icecream_outlined;
      case 'Bakery & Snacks':    return Icons.cookie_outlined;
      case 'Dairy':              return Icons.emoji_food_beverage_outlined;
      case 'Personal & Home Care': return Icons.cleaning_services_outlined;
      default:                   return Icons.inventory_2_outlined;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: state.isLoading
            ? _buildLoading()
            : state.productList!.when(
                data: (products) {
                  if (_filteredProducts.isEmpty &&
                      _searchController.text.isEmpty) {
                    _filteredProducts = List.from(products)
                      ..sort((a, b) => (a.productName ?? '')
                          .compareTo(b.productName ?? ''));
                  }
                  return Column(
                    children: [
                      _buildHeader(products),
                      Expanded(child: _buildList()),
                    ],
                  );
                },
                loading: _buildLoading,
                error: (e, _) => _buildError(e.toString()),
              ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(List<Product> products) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: _kBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kDivider),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _onSearchChanged(v, products),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _kTextPrimary),
              decoration: InputDecoration(
                hintText: 'Search products…',
                hintStyle: const TextStyle(
                    fontSize: 14,
                    color: _kTextSecondary,
                    fontWeight: FontWeight.w400),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 20, color: _kTextSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: _kTextSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('', products);
                        },
                        splashRadius: 16,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 13),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredProducts.length} product${_filteredProducts.length == 1 ? '' : 's'}',
            style: const TextStyle(
                fontSize: 12,
                color: _kTextSecondary,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────
  Widget _buildList() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: _kPrimaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded,
                  size: 30, color: _kPrimary),
            ),
            const SizedBox(height: 14),
            const Text('No products found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary)),
            const SizedBox(height: 6),
            const Text('Try a different search',
                style: TextStyle(fontSize: 13, color: _kTextSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      color: _kPrimary,
      backgroundColor: _kSurface,
      strokeWidth: 2.5,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _filteredProducts.length,
        itemBuilder: (_, i) => _ProductCard(
          product: _filteredProducts[i],
          typeColor: _typeColor,
          typeIcon: _typeIcon,
          formatUnit: formatUnit,
        ),
      ),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Loading products…',
              style: TextStyle(
                  fontSize: 14,
                  color: _kTextSecondary.withOpacity(0.8))),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  size: 32, color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _kTextSecondary, height: 1.4)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshProducts,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Product Card — expandable, minimal
// ══════════════════════════════════════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  final Product product;
  final Color Function(String?) typeColor;
  final IconData Function(String?) typeIcon;
  final String Function(double, String) formatUnit;

  const _ProductCard({
    required this.product,
    required this.typeColor,
    required this.typeIcon,
    required this.formatUnit,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnim =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.typeColor(widget.product.productType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kDivider),
        ),
        child: Column(
          children: [
            // ── Header row ─────────────────────────────────────────────
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Type icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          widget.typeIcon(widget.product.productType),
                          size: 22,
                          color: color),
                    ),
                    const SizedBox(width: 12),

                    // Name + type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.productName ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.product.productType ?? '',
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Unit count pill
                    if ((widget.product.subtypes ?? []).isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _kDivider),
                        ),
                        child: Text(
                          '${widget.product.subtypes!.length} unit${widget.product.subtypes!.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: _kTextSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),

                    // Chevron
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: _kTextSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable units ───────────────────────────────────────
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Column(
                children: [
                  const Divider(height: 1, color: _kDivider),
                  _buildUnits(color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnits(Color color) {
    final units = widget.product.subtypes;

    if (units == null || units.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline_rounded,
                size: 16, color: _kTextSecondary),
            SizedBox(width: 6),
            Text('No units available',
                style:
                    TextStyle(fontSize: 13, color: _kTextSecondary)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        children: units.asMap().entries.map((e) {
          final isLast = e.key == units.length - 1;
          final unit = e.value;
          return Column(
            children: [
              _UnitRow(
                label: widget.formatUnit(
                  unit.availableUnit ?? 0,
                  unit.measuringUnit ?? '',
                ),
                price: '₹${unit.price}',
                color: color,
              ),
              if (!isLast)
                const Divider(height: 1, color: _kDivider),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Unit row ───────────────────────────────────────────────────────────────
class _UnitRow extends StatelessWidget {
  final String label;
  final String price;
  final Color color;

  const _UnitRow({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.straighten_outlined,
                size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
            ),
          ),
          // Price pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              price,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}