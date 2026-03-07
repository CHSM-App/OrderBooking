import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/shop_viewmodel.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/screens/admin_screen/widgets/admin_retry_widgets.dart';
import 'package:order_booking_app/widgets/app_search_bar.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFFE8720C);
const _kPrimaryLight = Color(0xFFFFF3E8);
const _kSurface = Color(0xFFFFFFFF);
const _kBackground = Color(0xFFF5F5F5);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider = Color(0xFFEEEEEE);

// ── Shop-type palette ─────────────────────────────────────────────────────────
const _kShopColor = Color(0xFF6366F1); // indigo  – type 1 (Shop)
const _kGodownColor = Color(0xFF0EA5E9); // sky     – type 2 (Godown)

// ── Shop-type helpers ─────────────────────────────────────────────────────────
String _shopTypeLabel(int? type) {
  if (type == 1) return 'Shop';
  if (type == 2) return 'Godown';
  return 'Unknown';
}

Color _shopTypeColor(int? type) {
  if (type == 1) return _kShopColor;
  if (type == 2) return _kGodownColor;
  return _kTextSecondary;
}

IconData _shopTypeIcon(int? type) {
  if (type == 1) return Icons.storefront_outlined;
  if (type == 2) return Icons.warehouse_outlined;
  return Icons.help_outline_rounded;
}

// ─────────────────────────────────────────────────────────────────────────────
class ShopListPage extends ConsumerStatefulWidget {
  const ShopListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends ConsumerState<ShopListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<String> _availableRegions = [];
  String? _selectedRegion;

  /// null = all types, 1 = Shop, 2 = Godown
  int? _selectedShopType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopViewModelProvider.notifier)
          .getShopList(ref.read(adminloginViewModelProvider).companyId ?? '');
    });
    _searchController.addListener(() {
      if (mounted) {
        setState(
          () => _searchQuery = _searchController.text.toLowerCase().trim(),
        );
      }
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(shopViewModelProvider.notifier)
        .getShopList(ref.read(adminloginViewModelProvider).companyId ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  List<String> _extractRegions(List<ShopDetails> shops) {
    return shops
        .map((s) => s.regionName)
        .where((r) => r != null && r.trim().isNotEmpty)
        .map((r) => r!.trim())
        .toSet()
        .toList()
      ..sort();
  }

  List<ShopDetails> _filterShops(List<ShopDetails> shops) {
    var result = shops;

    if (_selectedShopType != null) {
      result = result.where((s) => s.type == _selectedShopType).toList();
    }

    if (_selectedRegion != null) {
      result = result
          .where((s) => (s.regionName?.trim() ?? '') == _selectedRegion)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((shop) {
        final name = shop.shopName?.toLowerCase() ?? '';
        final owner = shop.ownerName?.toLowerCase() ?? '';
        final address = shop.address?.toLowerCase() ?? '';
        final phone = shop.mobileNo?.toLowerCase() ?? '';
        final regionName = shop.regionName?.toLowerCase() ?? '';
        final typeLabel = _shopTypeLabel(shop.type).toLowerCase();
        return name.contains(_searchQuery) ||
            owner.contains(_searchQuery) ||
            address.contains(_searchQuery) ||
            phone.contains(_searchQuery) ||
            regionName.contains(_searchQuery) ||
            typeLabel.contains(_searchQuery);
      }).toList();
    }

    return result;
  }

  bool get _hasActiveFilters =>
      _selectedRegion != null || _selectedShopType != null;

  bool _isNetworkError(String? message) {
    if (message == null) return false;
    return [
      'network',
      'internet',
      'connection',
      'socket',
      'failed host',
      'no address',
      'timeout',
      'unreachable',
    ].any(message.toLowerCase().contains);
  }

  void _onShopTap(ShopDetails shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShopDetailSheet(shop: shop),
    );
  }

  // ── Filter bottom sheet ────────────────────────────────────────────────────
  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheet) {
          final regions = _availableRegions;

          return Container(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              MediaQuery.of(sheetCtx).viewInsets.bottom + 32,
            ),
            decoration: const BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _kDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title + Clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                        ),
                      ),
                      if (_hasActiveFilters)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRegion = null;
                              _selectedShopType = null;
                            });
                            setSheet(() {});
                            Navigator.pop(sheetCtx);
                          },
                          child: const Text(
                            'Clear all',
                            style: TextStyle(
                              fontSize: 13,
                              color: _kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── Shop Type section ─────────────────────────────────────
                  const SizedBox(height: 20),
                  const _SectionLabel(label: 'Shop Type'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ShopTypeTile(
                          type: 1,
                          isSelected: _selectedShopType == 1,
                          onTap: () {
                            setState(
                              () => _selectedShopType = _selectedShopType == 1
                                  ? null
                                  : 1,
                            );
                            setSheet(() {});
                            Navigator.pop(sheetCtx);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ShopTypeTile(
                          type: 2,
                          isSelected: _selectedShopType == 2,
                          onTap: () {
                            setState(
                              () => _selectedShopType = _selectedShopType == 2
                                  ? null
                                  : 2,
                            );
                            setSheet(() {});
                            Navigator.pop(sheetCtx);
                          },
                        ),
                      ),
                    ],
                  ),

                  // ── Region section ────────────────────────────────────────
                  if (regions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _SectionLabel(label: 'Region'),
                    const SizedBox(height: 10),
                    if (regions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No regions available',
                            style: TextStyle(
                              color: _kTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: regions.map((region) {
                          final isSelected = _selectedRegion == region;
                          return GestureDetector(
                            onTap: () {
                              setState(
                                () => _selectedRegion = isSelected
                                    ? null
                                    : region,
                              );
                              setSheet(() {});
                              Navigator.pop(sheetCtx);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? _kPrimary : _kBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? _kPrimary : _kDivider,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : _kTextSecondary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    region,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? Colors.white
                                          : _kTextPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopViewModelProvider);

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Shops',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: RefreshIndicator(
        color: _kPrimary,
        backgroundColor: _kSurface,
        displacement: 60,
        strokeWidth: 2.5,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Search + filter ────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Active filter chips ────────────────────────────────────────
            if (_hasActiveFilters)
              SliverToBoxAdapter(child: _buildActiveChips()),

            // ── Body ──────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildBody(shopState),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── Search bar + filter button ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search shop, owner, region...',
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showFilter(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _hasActiveFilters ? _kPrimaryLight : _kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasActiveFilters ? _kPrimary : _kDivider,
                      width: _hasActiveFilters ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: _hasActiveFilters ? _kPrimary : _kTextSecondary,
                  ),
                ),
                if (_hasActiveFilters)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: _kPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Active filter chips ────────────────────────────────────────────────────
  Widget _buildActiveChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (_selectedShopType != null)
            _ActiveChip(
              icon: _shopTypeIcon(_selectedShopType),
              label: _shopTypeLabel(_selectedShopType),
              chipColor: _shopTypeColor(_selectedShopType),
              onRemove: () => setState(() => _selectedShopType = null),
            ),
          if (_selectedRegion != null)
            _ActiveChip(
              icon: Icons.location_on_outlined,
              label: _selectedRegion!,
              onRemove: () => setState(() => _selectedRegion = null),
            ),
        ],
      ),
    );
  }

  // ── Body sliver ───────────────────────────────────────────────────────────
  Widget _buildBody(ShopState shopState) {
    if (shopState.isLoading && shopState.shopList == null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: _kPrimary,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading shops…',
                style: TextStyle(
                  fontSize: 14,
                  color: _kTextSecondary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (shopState.error != null) {
      return SliverFillRemaining(
        child: _isNetworkError(shopState.error)
            ? _buildNoInternetState()
            : _buildErrorState(),
      );
    }

    return shopState.shopList?.when(
          data: (shops) {
            _availableRegions = _extractRegions(shops);

            final filtered = _filterShops(shops);
            if (filtered.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState());
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _MinimalShopCard(
                  shop: filtered[i],
                  onTap: () => _onShopTap(filtered[i]),
                  index: i,
                ),
                childCount: filtered.length,
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _kPrimary)),
          ),
          error: (e, _) => SliverFillRemaining(
            child: _isNetworkError(e.toString())
                ? _buildNoInternetState()
                : _buildErrorState(),
          ),
        ) ??
        const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  // ── Empty ──────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final isFiltered = _searchQuery.isNotEmpty || _hasActiveFilters;
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
              Icons.storefront_outlined,
              size: 36,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No shops found' : 'No shops yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (isFiltered) ...[
            const Text(
              'Try a different search or filter',
              style: TextStyle(fontSize: 13, color: _kTextSecondary),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() {
                _searchController.clear();
                _selectedRegion = null;
                _selectedShopType = null;
              }),
              child: const Text(
                'Clear all',
                style: TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoInternetState() => AdminNoInternetRetry(onRetry: _onRefresh);

  Widget _buildErrorState() => AdminSomethingWentWrongRetry(
    onRetry: () => ref
        .read(shopViewModelProvider.notifier)
        .getShopList(ref.read(adminloginViewModelProvider).companyId ?? ''),
  );
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _kTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(child: Divider(color: _kDivider, height: 1)),
    ],
  );
}

// ── Shop-type tile (used in filter sheet) ─────────────────────────────────────
class _ShopTypeTile extends StatelessWidget {
  final int type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShopTypeTile({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _shopTypeColor(type);
    final label = _shopTypeLabel(type);
    final icon = _shopTypeIcon(type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : _kBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : _kDivider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? color : _kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.transparent : _kDivider,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : _kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type == 1 ? 'Retail shop' : 'Wholesale godown',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? color.withOpacity(0.75)
                          : _kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Active filter chip ────────────────────────────────────────────────────────
class _ActiveChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color chipColor;
  final VoidCallback onRemove;

  const _ActiveChip({
    required this.icon,
    required this.label,
    this.chipColor = _kPrimary,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: chipColor),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shop Detail Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════
class _ShopDetailSheet extends StatelessWidget {
  final ShopDetails shop;
  const _ShopDetailSheet({required this.shop});

  @override
  Widget build(BuildContext context) {
    final typeColor = _shopTypeColor(shop.type);
    final typeLabel = _shopTypeLabel(shop.type);
    final typeIcon = _shopTypeIcon(shop.type);

    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _kDivider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(typeIcon, size: 28, color: typeColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.shopName ?? 'Unknown Shop',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // ── Type badge ─────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(typeIcon, size: 11, color: typeColor),
                            const SizedBox(width: 4),
                            Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (shop.shopSelfie != null &&
              shop.shopSelfie!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    shop.shopSelfie!.trim(),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: _kPrimary),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: _kPrimaryLight,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: _kTextSecondary,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 16),

          // ── Detail rows ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (shop.ownerName != null)
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Owner',
                    value: shop.ownerName!,
                  ),
                if (shop.mobileNo != null)
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Mobile',
                    value: shop.mobileNo!,
                  ),
                if (shop.address != null)
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: shop.address!,
                  ),
                if (shop.email != null)
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: shop.email!,
                  ),
                if (shop.regionName != null)
                  _DetailRow(
                    icon: Icons.map_outlined,
                    label: 'Region',
                    value: shop.regionName!,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _kPrimaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: _kPrimary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? _kTextPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Minimal Shop Card
// ══════════════════════════════════════════════════════════════════════════════
class _MinimalShopCard extends StatefulWidget {
  final ShopDetails shop;
  final VoidCallback onTap;
  final int index;

  const _MinimalShopCard({
    required this.shop,
    required this.onTap,
    required this.index,
  });

  @override
  State<_MinimalShopCard> createState() => _MinimalShopCardState();
}

class _MinimalShopCardState extends State<_MinimalShopCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final typeColor = _shopTypeColor(widget.shop.type);
    final typeLabel = _shopTypeLabel(widget.shop.type);
    final typeIcon = _shopTypeIcon(widget.shop.type);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;
        final isTablet = constraints.maxWidth >= 600;

        final double hPad = isTablet ? 18 : (isSmall ? 11 : 14);
        final double vPad = isTablet ? 16 : (isSmall ? 11 : 13);
        final double avatarSize = isTablet ? 50 : (isSmall ? 38 : 44);
        final double avatarRadius = isTablet ? 14 : (isSmall ? 10 : 12);
        final double avatarIcon = isTablet ? 26 : (isSmall ? 18 : 22);
        final double gap = isTablet ? 16 : (isSmall ? 10 : 14);
        final double titleSize = isTablet ? 16 : (isSmall ? 13 : 15);
        final double ownerSize = isTablet ? 13 : (isSmall ? 11 : 12);
        final double chipFs = isTablet ? 11 : (isSmall ? 9 : 10);
        final double chipIcon = isTablet ? 12 : (isSmall ? 9 : 10);
        final double pillPadH = isSmall ? 6.0 : 8.0;
        final double pillPadV = isSmall ? 2.0 : 3.0;
        final double chevron = isTablet ? 22 : (isSmall ? 16 : 18);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kDivider, width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: vPad,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Avatar ──────────────────────────────────────────
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(avatarRadius),
                        ),
                        child: Icon(
                          typeIcon,
                          size: avatarIcon,
                          color: typeColor,
                        ),
                      ),
                      SizedBox(width: gap),

                      // ── Details ─────────────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Row 1: shop name + type pill ───────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.shop.shopName ?? 'Unknown Shop',
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w700,
                                      color: _kTextPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                // ── Type pill ──────────────────────────────
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: pillPadH,
                                    vertical: pillPadV,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        typeIcon,
                                        size: chipIcon,
                                        color: typeColor,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        typeLabel,
                                        style: TextStyle(
                                          fontSize: chipFs,
                                          fontWeight: FontWeight.w700,
                                          color: typeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // ── Row 2: owner name ──────────────────────────
                            if (widget.shop.ownerName != null) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    size: chipIcon + 2,
                                    color: _kTextSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.shop.ownerName!,
                                      style: TextStyle(
                                        fontSize: ownerSize,
                                        color: _kTextSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // ── Row 3: phone  •  region ────────────────────
                            if (widget.shop.mobileNo != null ||
                                widget.shop.regionName != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Phone
                                  if (widget.shop.mobileNo != null) ...[
                                    Icon(
                                      Icons.phone_outlined,
                                      size: chipIcon + 1,
                                      color: _kTextSecondary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.shop.mobileNo!,
                                      style: TextStyle(
                                        fontSize: chipFs + 1,
                                        color: _kTextSecondary,
                                      ),
                                    ),
                                  ],

                                  const Spacer(),

                                  // Region pill
                                  if (widget.shop.regionName != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: pillPadH,
                                        vertical: pillPadV,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _kPrimaryLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth: isTablet
                                            ? 160
                                            : (isSmall ? 90 : 120),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: chipIcon,
                                            color: _kPrimary,
                                          ),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              widget.shop.regionName!,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: chipFs,
                                                fontWeight: FontWeight.w600,
                                                color: _kPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(width: isSmall ? 4 : 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: chevron,
                        color: _kTextSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
