import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addProduct.dart';
import 'package:order_booking_app/domain/models/product.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFFE8720C);
const _kPrimaryLight = Color(0xFFFFF3E8);
const _kGreen = Color(0xFF16A34A);
const _kGreenLight = Color(0xFFDCFCE7);
const _kSurface = Color(0xFFFFFFFF);
const _kBackground = Color(0xFFF5F5F5);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider = Color(0xFFEEEEEE);

class AdminCatalogPage extends ConsumerStatefulWidget {
  const AdminCatalogPage({super.key});

  @override
  ConsumerState<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends ConsumerState<AdminCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(productViewModelProvider.notifier)
          .fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddEdit({Product? initialProduct}) async {
    final userId = ref.read(adminloginViewModelProvider).userId;
    if (userId == 0) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddProductPage(adminId: userId, initialProduct: initialProduct),
      ),
    );

    if (result == true && mounted) {
      ref
          .read(productViewModelProvider.notifier)
          .fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: _kBackground,
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverToBoxAdapter(child: _buildSearchBar()),

          // Product list
          state.productList!.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: _kPrimary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            error: (err, _) =>
                SliverFillRemaining(child: _buildError(err.toString())),
            data: (products) {
              final filtered = products
                  .where(
                    (p) => (p.productName ?? '').toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(child: _buildEmpty());
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ProductCard(
                      product: filtered[i],
                      onEdit: () => _openAddEdit(initialProduct: filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(),
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kDivider),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search products…',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: _kTextSecondary,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: _kTextSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: _kTextSecondary,
                    ),
                    onPressed: () => setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    }),
                    splashRadius: 16,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 13,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _kPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 34,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No products yet' : 'No products found',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isEmpty
                ? 'Tap + Add Product to get started'
                : 'Try a different search',
            style: const TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildError(String msg) {
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
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _kTextSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(productViewModelProvider.notifier)
                  .fetchProductList(
                    ref.read(adminloginViewModelProvider).companyId ?? '',
                  ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Product Card — expandable with edit button
// ══════════════════════════════════════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;

  const _ProductCard({required this.product, required this.onEdit});

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
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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

  Color _typeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'beverage':
        return const Color(0xFF0EA5E9);
      case 'grocery':
        return const Color(0xFFF59E0B);
      case 'ice cream':
        return const Color(0xFFEC4899);
      case 'bakery & snacks':
        return const Color(0xFFD97706);
      case 'dairy':
        return const Color(0xFF16A34A);
      case 'personal & home care':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _typeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'beverage':
        return Icons.local_drink_outlined;
      case 'grocery':
        return Icons.shopping_bag_outlined;
      case 'ice cream':
        return Icons.icecream_outlined;
      case 'bakery & snacks':
        return Icons.cookie_outlined;
      case 'dairy':
        return Icons.emoji_food_beverage_outlined;
      case 'personal & home care':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _formatUnit(double? value, String? unit) {
    if (value == null || unit == null) return '';
    final u = unit.toLowerCase();
    if (u == 'liter' || u == 'litre' || u == 'l') {
      return value < 1 ? '${(value * 1000).toInt()} ml' : '$value L';
    }
    if (u == 'kilogram' || u == 'kg') {
      return value < 1 ? '${(value * 1000).toInt()} g' : '$value kg';
    }
    return '$value $unit';
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(widget.product.productType);
    final units = widget.product.subtypes ?? [];

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
           GestureDetector(
  onTap: _toggle,
  behavior: HitTestBehavior.opaque,
  child: Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
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
                      _typeIcon(widget.product.productType),
                      size: 22,
                      color: color,
                    ),
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unit count pill
                  if (units.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kDivider),
                      ),
                      child: Text(
                        '${units.length} unit${units.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Edit button
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _kPrimaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: _kPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Expand chevron
                  GestureDetector(
                    onTap: _toggle,
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: _kTextSecondary,
                      ),
                    ),
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
                  _buildUnits(units),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnits(List<ProductSubType> units) {
    if (units.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline_rounded, size: 16, color: _kTextSecondary),
            SizedBox(width: 6),
            Text(
              'No units available',
              style: TextStyle(fontSize: 13, color: _kTextSecondary),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          const Text(
            'Available Units',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          ...units.asMap().entries.map((e) {
            final isLast = e.key == units.length - 1;
            final u = e.value;
            return Column(
              children: [
                _UnitRow(
                  label: _formatUnit(u.availableUnit, u.measuringUnit),
                  price: '₹${u.price}',
                ),
                if (!isLast) const Divider(height: 1, color: _kDivider),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Unit row ───────────────────────────────────────────────────────────────
class _UnitRow extends StatelessWidget {
  final String label;
  final String price;

  const _UnitRow({required this.label, required this.price});

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
              color: _kBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kDivider),
            ),
            child: const Icon(
              Icons.straighten_outlined,
              size: 16,
              color: _kTextSecondary,
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _kGreenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              price,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
