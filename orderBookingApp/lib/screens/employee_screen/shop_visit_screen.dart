

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/domain/models/visite.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'order_form_screen.dart';

class ShopVisitScreen extends ConsumerStatefulWidget {
  final ShopDetails shop;
  final VisitPayload visit;

  const ShopVisitScreen({Key? key, required this.shop, required this.visit})
      : super(key: key);

  @override
  ConsumerState<ShopVisitScreen> createState() => _ShopVisitScreenState();
}

class _ShopVisitScreenState extends ConsumerState<ShopVisitScreen>
    with SingleTickerProviderStateMixin {
  bool _isPunchedIn = false;
  DateTime? _punchInTime;
  DateTime? _punchOutTime;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Auto punch in after a short delay
    Future.delayed(const Duration(milliseconds: 500), _autoPunchIn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _autoPunchIn() {
    setState(() {
      _isPunchedIn = true;
      _punchInTime = DateTime.now();
    });

    _animationController.forward();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Auto Punched In at ${widget.shop.shopName}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePunchOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Punch Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to punch out from this shop visit?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _punchOutTime = DateTime.now();
                _isPunchedIn = false;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Punched Out at ${_formatTime(_punchOutTime)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: const Color(0xFFF59E0B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Punch Out'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getDuration() {
    if (_punchInTime == null) return '--:--';
    final duration = DateTime.now().difference(_punchInTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: isTablet ? 100 : 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () {
                    // Make call
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea),
    const Color(0xFF764ba2),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    // Positioned.fill(
                    //   child: Opacity(
                    //     opacity: 0.1,
                    //     child: CustomPaint(
                    //       painter: _CirclePatternPainter(),
                    //     ),
                    //   ),
                    // ),
                    // Shop icon
                    Positioned(
                      right: -20,
                      top: 40,
                      child: Icon(
                        Icons.store_rounded,
                        size: isTablet ? 180 : 140,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    // Shop details
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.store, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Shop Visit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.shop.shopName ?? '',
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.shop.address ?? '',
                                  style: TextStyle(
                                    fontSize: isTablet ? 15 : 13,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Punch Status Card with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildPunchStatusCard(isTablet),
                  ),
                  
                  SizedBox(height: isTablet ? 32 : 24),

                  // Shop Details Section
                  _buildShopDetailsSection(isTablet),

                  SizedBox(height: isTablet ? 32 : 24),

                  // Action Buttons
                  if (_isPunchedIn) _buildActionButtons(isTablet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchStatusCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isPunchedIn
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFFF59E0B).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isPunchedIn
              ? const Color(0xFF10B981).withOpacity(0.2)
              : const Color(0xFFF59E0B).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isPunchedIn
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isPunchedIn
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B))
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isPunchedIn ? Icons.check_circle : Icons.access_time,
                  color: Colors.white,
                  size: isTablet ? 32 : 26,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPunchedIn ? 'Punched In' : 'Not Punched In',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 20,
                        fontWeight: FontWeight.bold,
                        color: _isPunchedIn
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    if (_isPunchedIn) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: isTablet ? 18 : 16,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Duration: ${_getDuration()}',
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 13,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
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
          if (_isPunchedIn) ...[
            SizedBox(height: isTablet ? 24 : 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF10B981).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfoCard(
                    'Punch In Time',
                    _formatTime(_punchInTime),
                    Icons.login,
                    const Color(0xFF10B981),
                    isTablet,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: _buildTimeInfoCard(
                    'Location',
                    'Captured',
                    Icons.location_on,
                    const Color(0xFF6366F1),
                    isTablet,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfoCard(
      String label, String value, IconData icon, Color color, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isTablet ? 18 : 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopDetailsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Shop Details',
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 20 : 16),
        if (widget.shop.ownerName != null)
          _DetailCard(
            icon: Icons.person_outline,
            label: 'Owner Name',
            value: widget.shop.ownerName!,
            color: const Color(0xFF8B5CF6),
            isTablet: isTablet,
          ),
        if (widget.shop.mobileNo != null) ...[
          SizedBox(height: isTablet ? 16 : 12),
          _DetailCard(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: widget.shop.mobileNo!,
            isPhone: true,
            color: const Color(0xFF10B981),
            isTablet: isTablet,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderFormScreen(
                    shop: widget.shop,
                    visit: widget.visit,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8F9FA),
              foregroundColor: const Color.fromARGB(255, 125, 211, 117),
              side: const BorderSide(color: Color.fromARGB(255, 125, 211, 117), width: 2),
             // foregroundColor: Colors.white,
              elevation: 0,
              //shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
              padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_shopping_cart, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Add Order',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handlePunchOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF59E0B),
              side: const BorderSide(color: Color(0xFFF59E0B), width: 2),
              padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Punch Out',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPhone;
  final Color color;
  final bool isTablet;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isPhone = false,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isTablet ? 26 : 22),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          if (isPhone)
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.phone, color: color),
                iconSize: isTablet ? 24 : 22,
                onPressed: () {
                  // Make phone call
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Custom painter for background pattern
class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3),
        30.0 * (i + 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
