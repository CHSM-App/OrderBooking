
import 'package:flutter/material.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/screens/theme.dart';
import 'order_form_screen.dart';


class ShopVisitScreen extends StatefulWidget {
  final ShopDetails shop;

  const ShopVisitScreen({Key? key, required this.shop}) : super(key: key);

  @override
  State<ShopVisitScreen> createState() => _ShopVisitScreenState();
}

class _ShopVisitScreenState extends State<ShopVisitScreen> {
  bool _isPunchedIn = false;
  DateTime? _punchInTime;
  DateTime? _punchOutTime;

  @override
  void initState() {
    super.initState();
    // Auto punch in after a short delay
    Future.delayed(const Duration(milliseconds: 500), _autoPunchIn);
  }

  void _autoPunchIn() {
    setState(() {
      _isPunchedIn = true;
      _punchInTime = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Auto Punched In at ${widget.shop.shopName}'),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePunchOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Punch Out'),
        content: const Text('Are you sure you want to punch out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isPunchedIn = false;
                _punchOutTime = DateTime.now();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Punched Out from ${widget.shop.shopName}'),
                  backgroundColor: AppTheme.warningColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.shop.shopName??
        ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Make call
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Header with Gradient
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Icon(
                      Icons.store,
                      size: 100,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shop.shopName ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.shop.address ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Punch Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isPunchedIn
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isPunchedIn
                            ? AppTheme.successColor.withOpacity(0.5)
                            : AppTheme.warningColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isPunchedIn
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPunchedIn
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPunchedIn
                                        ? 'Punched In'
                                        : 'Not Punched In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _isPunchedIn
                                          ? AppTheme.successColor
                                          : AppTheme.warningColor,
                                    ),
                                  ),
                                  if (_isPunchedIn) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Duration: ${_getDuration()}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_isPunchedIn) ...[
                          const SizedBox(height: 16),
                          Divider(color: AppTheme.textLight),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Punch In Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(_punchInTime),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppTheme.textLight,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 16,
                                            color: AppTheme.successColor),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Captured',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
                  const SizedBox(height: 24),

                  // Shop Details
                  Text(
                    'Shop Details',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  if (widget.shop.ownerName != null)
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Owner',
                      value: widget.shop.ownerName!,
                    ),
                  if (widget.shop.mobileNo != null) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: widget.shop.mobileNo!,
                      isPhone: true,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isPunchedIn) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderFormScreen(shop: widget.shop),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handlePunchOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Punch Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.warningColor,
                          side: BorderSide(
                              color: AppTheme.warningColor, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPhone;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isPhone)
            IconButton(
              icon: Icon(Icons.phone, color: AppTheme.primaryColor),
              onPressed: () {
                // Make phone call
              },
            ),
        ],
      ),
    );
  }
}
