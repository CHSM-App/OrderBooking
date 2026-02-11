import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order_form_screen.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary      = Color(0xFFE8720C);
const _kPrimaryLight = Color(0xFFFFF3E8);
const _kGreen        = Color(0xFF22C55E);
const _kGreenLight   = Color(0xFFDCFCE7);
const _kAmber        = Color(0xFFF59E0B);
const _kAmberLight   = Color(0xFFFEF3C7);
const _kSurface      = Color(0xFFFFFFFF);
const _kBackground   = Color(0xFFF5F5F5);
const _kTextPrimary  = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider      = Color(0xFFEEEEEE);

class ShopVisitScreen extends ConsumerStatefulWidget {
  final ShopDetails shop;
  final VisitPayload visit;

  const ShopVisitScreen({Key? key, required this.shop, required this.visit})
      : super(key: key);

  @override
  ConsumerState<ShopVisitScreen> createState() => _ShopVisitScreenState();
}

class _ShopVisitScreenState extends ConsumerState<ShopVisitScreen> {
  bool _isPunchedIn = false;
  DateTime? _punchInTime;
  DateTime? _punchOutTime;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), _autoPunchIn);
  }

  void _autoPunchIn() {
    if (!mounted) return;
    setState(() {
      _isPunchedIn = true;
      _punchInTime = DateTime.now();
    });
    _showSnack(
      'Punched in at ${widget.shop.shopName}',
      color: _kGreen,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  void _handlePunchOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        title: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: _kAmberLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: _kAmber, size: 26),
            ),
            const SizedBox(height: 14),
            const Text('Punch Out?',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'Are you sure you want to punch out from this shop visit?',
          style: TextStyle(
              fontSize: 14, color: _kTextSecondary, height: 1.5),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: _kTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _punchOutTime = now;
                _isPunchedIn = false;
              });

              final updatedVisit = VisitPayload(
                localId: widget.visit.localId,
                shopId: widget.visit.shopId,
                employeeId: widget.visit.employeeId,
                lat: widget.visit.lat,
                lng: widget.visit.lng,
                accuracy: widget.visit.accuracy,
                capturedAt: widget.visit.capturedAt,
                punchIn: widget.visit.punchIn,
                punchOut: VisitPayload.formatForApi(now.toLocal()),
              );
              ref.read(visitViewModelProvider.notifier).addVisit(updatedVisit);

              Navigator.pop(ctx);
              _showSnack(
                'Punched out at ${_formatTime(_punchOutTime)}',
                color: _kAmber,
                icon: Icons.logout_rounded,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAmber,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Punch Out',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg,
      {required Color color, required IconData icon}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }


  Future<void> _callShop() async {
    final raw = widget.shop.mobileNo?.trim() ?? '';
    if (raw.isEmpty) {
      _showSnack(
        'Phone number not available',
        color: Colors.red,
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: raw);
    if (!await canLaunchUrl(uri)) {
      _showSnack(
        'Unable to open dialer',
        color: Colors.red,
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    await launchUrl(uri);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildShopDetails(),
                const SizedBox(height: 16),
                if (_isPunchedIn) _buildActionButtons(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: const Color.fromARGB(255, 220, 165, 117),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      // actions: [
      //   Container(
      //     margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      //     decoration: BoxDecoration(
      //       color: Colors.white.withOpacity(0.2),
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //     child: IconButton(
      //       icon: const Icon(Icons.call_outlined,
      //           color: Colors.white, size: 20),
      //       onPressed: () {},
      //       padding: const EdgeInsets.all(8),
      //       constraints: const BoxConstraints(),
      //     ),
      //   ),
      // ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color.fromARGB(255, 253, 151, 62),
          child: Stack(
            children: [
              // // Watermark icon
              // Positioned(
              //   right: -16,
              //   bottom: -12,
              //   child: Icon(
              //     Icons.storefront_outlined,
              //     size: 160,
              //     color: Colors.white.withOpacity(0.1),
              //   ),
              // ),
              // Shop info
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 10, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: const Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Icon(Icons.storefront_outlined,
                    //           color: Colors.white, size: 12),
                    //       SizedBox(width: 5),
                    //       Text('Shop Visit',
                    //           style: TextStyle(
                    //               fontSize: 11,
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.w600)),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    Text(
                      widget.shop.shopName ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if ((widget.shop.address ?? '').isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.white70, size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.shop.address!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  height: 1.3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status card ────────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    final isIn = _isPunchedIn;
    final accentColor = isIn ? _kGreen : _kAmber;
    final bgColor = isIn ? _kGreenLight : _kAmberLight;

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kDivider),
      ),
      child: Column(
        children: [
          // Status row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIn
                        ? Icons.check_circle_outline_rounded
                        : Icons.access_time_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIn ? 'Punched In' : 'Not Punched In',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      // if (isIn)
                      //   Text(
                      //     'Duration: ${_getDuration()}',
                      //     style: const TextStyle(
                      //         fontSize: 12, color: _kTextSecondary),
                      //   ),
                    ],
                  ),
                ),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isIn ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Time info row (only when punched in)
          if (isIn) ...[
            const Divider(height: 1, color: _kDivider),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTimeCell(
                      label: 'Punch In',
                      value: _formatTime(_punchInTime),
                      icon: Icons.login_rounded,
                      color: _kGreen,
                    ),
                  ),
                  Container(
                      width: 1, height: 36, color: _kDivider),
                  Expanded(
                    child: _buildTimeCell(
                      label: 'Location',
                      value: 'Captured',
                      icon: Icons.location_on_outlined,
                      color: _kPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCell({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: _kTextSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary)),
      ],
    );
  }

  // ── Shop details ───────────────────────────────────────────────────────────
  Widget _buildShopDetails() {
    final rows = <Widget>[];

    if (widget.shop.ownerName != null) {
      rows.add(_DetailRow(
        icon: Icons.person_outline_rounded,
        label: 'Owner',
        value: widget.shop.ownerName!,
      ));
    }
    if (widget.shop.mobileNo != null) {
      if (rows.isNotEmpty) {
        rows.add(const Divider(height: 1, indent: 52, color: _kDivider));
      }
      rows.add(_DetailRow(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: widget.shop.mobileNo!,
        trailing: GestureDetector(
          onTap: _callShop,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _kPrimaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Call',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kPrimary)),
          ),
        ),
      ));
    }
    if (widget.shop.address != null) {
      if (rows.isNotEmpty) {
        rows.add(const Divider(height: 1, indent: 52, color: _kDivider));
      }
      rows.add(_DetailRow(
        icon: Icons.location_on_outlined,
        label: 'Address',
        value: widget.shop.address!,
        multiline: true,
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Shop Details',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kTextSecondary,
                    letterSpacing: 0.5)),
          ),
          const Divider(height: 1, color: _kDivider),
          ...rows,
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Add Order
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderFormScreen(
                  shop: widget.shop,
                  visit: widget.visit,
                ),
              ),
            ),
            icon: const Icon(Icons.add_shopping_cart_outlined, size: 20),
            label: const Text('Add Order',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Punch Out
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _handlePunchOut,
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Punch Out',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kAmber,
              side: const BorderSide(color: _kAmber, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Detail Row ─────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _kTextSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _kTextSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                        height: 1.3),
                    maxLines: multiline ? 3 : 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
