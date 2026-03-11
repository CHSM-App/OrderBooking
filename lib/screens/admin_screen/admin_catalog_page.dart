import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addProduct.dart';
import 'package:order_booking_app/domain/models/product.dart';
import 'package:order_booking_app/screens/admin_screen/widgets/admin_retry_widgets.dart';
import 'package:order_booking_app/widgets/app_search_bar.dart';

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

  Future<void> _onRefresh() async {
    await ref
        .read(productViewModelProvider.notifier)
        .fetchProductList(
          ref.read(adminloginViewModelProvider).companyId ?? '',
        );
  }

  bool _isNetworkError(String? message) {
    if (message == null) return false;
    final msg = message.toLowerCase();
    return [
      'network',
      'internet',
      'connection',
      'socket',
      'failed host',
      'no address',
      'timeout',
      'unreachable',
    ].any(msg.contains);
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: _kPrimary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              error: (err, _) => SliverFillRemaining(
                child: _isNetworkError(err.toString())
                    ? _buildNoInternet()
                    : _buildError(),
              ),
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
      ),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'admin_catalog_add_product_fab',
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
      child: AppSearchBar(
        controller: _searchController,
        hintText: 'Search products…',
        onChanged: (v) => setState(() => _searchQuery = v),
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
  Widget _buildNoInternet() {
    return AdminNoInternetRetry(onRetry: _onRefresh);
  }

  Widget _buildError() {
    return AdminSomethingWentWrongRetry(
      onRetry: () => ref
          .read(productViewModelProvider.notifier)
          .fetchProductList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
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



  @override
  Widget build(BuildContext context) {
    //final color = _typeColor(widget.product.productType);
    final units =  [];

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
                    // Container(
                    //   width: 44,
                    //   height: 44,
                    //   decoration: BoxDecoration(
                    //     color: color.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: Icon(
                    //     _typeIcon(widget.product.productType),
                    //     size: 22,
                    //     color: color,
                    //   ),
                    // ),
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
                          // Text(
                          //   widget.product.productType ?? '',
                          //   style: TextStyle(
                          //     fontSize: 11,
                          //     color: color,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
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
                  // _buildUnits(units),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
