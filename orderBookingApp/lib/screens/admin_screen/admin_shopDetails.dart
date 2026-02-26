import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/presentation/viewModels/shop_viewmodel.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/screens/admin_screen/widgets/admin_retry_widgets.dart';

// ── Brand tokens (match your orange/amber theme) ─────────────────────────────
const _kPrimary = Color(0xFFE8720C); // warm orange
const _kPrimaryLight = Color(0xFFFFF3E8); // soft orange tint
const _kSurface = Color(0xFFFFFFFF);
const _kBackground = Color(0xFFF5F5F5);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider = Color(0xFFEEEEEE);

class ShopListPage extends ConsumerStatefulWidget {
  const ShopListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends ConsumerState<ShopListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
        setState(() {
          _searchQuery = _searchController.text.toLowerCase().trim();
        });
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

  List<ShopDetails> _filterShops(List<ShopDetails> shops) {
    if (_searchQuery.isEmpty) return shops;
    return shops.where((shop) {
      final name = shop.shopName?.toLowerCase() ?? '';
      final owner = shop.ownerName?.toLowerCase() ?? '';
      final address = shop.address?.toLowerCase() ?? '';
      final phone = shop.mobileNo?.toLowerCase() ?? '';
      final regionName = shop.regionName?.toLowerCase()?? '';
      return name.contains(_searchQuery) ||
          owner.contains(_searchQuery) ||
          address.contains(_searchQuery) ||
          phone.contains(_searchQuery) || 
          regionName.contains(_searchQuery);
    }).toList();
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

  // ── Show shop details bottom sheet ────────────────────────────────────────
  void _onShopTap(ShopDetails shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShopDetailSheet(shop: shop),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
            // ── Sticky search bar ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Body ─────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildBody(shopState),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _kDivider, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search shop, owner, region...',
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
                    onPressed: () => _searchController.clear(),
                    splashRadius: 12,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 20,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

  // ── Body sliver ───────────────────────────────────────────────────────────
  Widget _buildBody(ShopState shopState) {
    // Loading (initial)
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

    // Error
    if (shopState.error != null) {
      return SliverFillRemaining(
        child: _isNetworkError(shopState.error)
            ? _buildNoInternetState()
            : _buildErrorState(),
      );
    }

    return shopState.shopList?.when(
          data: (shops) {
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

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
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
            _searchQuery.isNotEmpty ? 'No shops found' : 'No shops yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty ? 'Try a different search' : '',
            style: const TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _searchController.clear(),
              child: const Text(
                'Clear search',
                style: TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildNoInternetState() {
    return AdminNoInternetRetry(onRetry: _onRefresh);
  }

  Widget _buildErrorState() {
    return AdminSomethingWentWrongRetry(
      onRetry: () => ref
          .read(shopViewModelProvider.notifier)
          .getShopList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
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
          // ── Drag handle ─────────────────────────────────────────────────
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

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _kPrimaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 28,
                    color: _kPrimary,
                  ),
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
                      if (shop.shopId != null) ...[
                        // const SizedBox(height: 2),
                        // Text(
                        //   'ID: ${shop.shopId}',
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: _kTextSecondary,
                        //   ),
                        // ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: _kDivider, height: 1),
          const SizedBox(height: 16),

          // ── Detail rows ──────────────────────────────────────────────────
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
                    icon: Icons.email_outlined,
                    label: 'Region',
                    value: shop.regionName!,
                  )
                // if (shop. != null)
                //   _DetailRow(
                //     icon: Icons.receipt_long_outlined,
                //     label: 'GST No.',
                //     value: shop.gstNo!,
                //   ),
                // if (shop.shopType != null)
                //   _DetailRow(
                //     icon: Icons.category_outlined,
                //     label: 'Shop Type',
                //     value: shop.shopType!,
                //   ),
                // if (shop.area != null)
                //   _DetailRow(
                //     icon: Icons.map_outlined,
                //     label: 'Area',
                //     value: shop.area!,
                //   ),
                // if (shop.city != null)
                //   _DetailRow(
                //     icon: Icons.location_city_outlined,
                //     label: 'City',
                //     value: shop.city!,
                //   ),
                // if (shop.state != null)
                //   _DetailRow(
                //     icon: Icons.flag_outlined,
                //     label: 'State',
                //     value: shop.state!,
                //   ),
                // if (shop.pincode != null)
                //   _DetailRow(
                //     icon: Icons.pin_drop_outlined,
                //     label: 'Pincode',
                //     value: shop.pincode!,
                //   ),
                // if (shop.creditLimit != null)
                //   _DetailRow(
                //     icon: Icons.account_balance_wallet_outlined,
                //     label: 'Credit Limit',
                //     value: shop.creditLimit.toString(),
                //   ),
                // if (shop.outstandingAmount != null)
                //   _DetailRow(
                //     icon: Icons.money_off_outlined,
                //     label: 'Outstanding',
                //     value: shop.outstandingAmount.toString(),
                //     valueColor: Colors.red.shade600,
                //   ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Close button ─────────────────────────────────────────────────
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single detail row ─────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    // ignore: unused_element_parameter
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

// ══════════════════════════════════════════════════════════════════════════════
// Minimal Shop Card  — matches the "Order card" style from the screenshot
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kPrimaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 22,
                      color: _kPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // ── Details ─────────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop name
                        Text(
                          widget.shop.shopName ?? 'Unknown Shop',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (widget.shop.ownerName != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 12,
                                color: _kTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.shop.ownerName!,
                                  style: const TextStyle(
                                    fontSize: 12,
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

                        if (widget.shop.mobileNo != null ||
                            widget.shop.address != null) ...[
                          const SizedBox(height: 6),
                          // Row(
                          //   children: [
                          //     if (widget.shop.mobileNo != null)
                          //       _Chip(
                          //         icon: Icons.phone_outlined,
                          //         label: widget.shop.mobileNo!,
                          //       ),
                          //     if (widget.shop.mobileNo != null &&
                          //         widget.shop.address != null)
                          //       const SizedBox(width: 8),
                          //     if (widget.shop.address != null)
                          //       Expanded(
                          //         child: _Chip(
                          //           icon: Icons.location_on_outlined,
                          //           label: widget.shop.address!,
                          //           shrink: true,
                          //         ),
                          //       ),
                          //   ],
                          // ),
                          Row(
                            children: [
                              if (widget.shop.mobileNo != null)
                                _Chip(
                                  icon: Icons.phone_outlined,
                                  label: widget.shop.mobileNo!,
                                ),

                              if (widget.shop.mobileNo != null &&
                                  (widget.shop.address != null ||
                                      widget.shop.regionName != null))
                                const SizedBox(width: 8),

                              if (widget.shop.address != null ||
                                  widget.shop.regionName != null)
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (widget.shop.address != null)
                                        Flexible(
                                          child: _Chip(
                                            icon: Icons.home_outlined,
                                            label: widget.shop.address!,
                                            shrink: true,
                                          ),
                                        ),

                                      if (widget.shop.address != null &&
                                          widget.shop.regionName != null)
                                        const SizedBox(width: 8),

                                      if (widget.shop.regionName != null)
                                        Flexible(
                                          child: _Chip(
                                            icon: Icons.location_on_outlined,
                                            label: widget.shop.regionName!,
                                            shrink: true,
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

                  const SizedBox(width: 8),
                  // ── Arrow ────────────────────────────────────────────────
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _kTextSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Small inline chip (phone / address)
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool shrink;

  const _Chip({required this.icon, required this.label, this.shrink = false});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _kTextSecondary),
        const SizedBox(width: 3),
        shrink
            ? Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 11, color: _kTextSecondary),
              ),
      ],
    );
    return content;
  }
}
