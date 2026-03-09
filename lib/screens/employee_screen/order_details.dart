import 'package:flutter/material.dart';
import 'package:order_booking_app/domain/models/order_item.dart';
import 'package:order_booking_app/domain/models/orders.dart';
import 'package:order_booking_app/screens/employee_screen/order_printPdf.dart';


class OrderDetailsPage extends StatefulWidget {
  final Order order;
  final int orderNumber;

  const OrderDetailsPage({
    Key? key,
    required this.order,
    required this.orderNumber,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _itemsController;
  late AnimationController _summaryController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _summaryAnimation;
  
  List<AnimationController> _itemControllers = [];
  List<Animation<double>> _itemAnimations = [];

  @override
  void initState() {
    super.initState();
    
    // Header animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    
    // Items animation controller
    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // Summary animation
    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _summaryAnimation = CurvedAnimation(
      parent: _summaryController,
      curve: Curves.easeOutCubic,
    );
    
    // Create animation controllers for each item with staggered delay
    for (int i = 0; i < widget.order.items.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
      _itemControllers.add(controller);
      _itemAnimations.add(animation);
    }
    
    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Header animation
    _headerController.forward();
    
    // Staggered items animation
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _itemControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _itemControllers[i].forward();
    }
    
    // Summary animation
    await Future.delayed(const Duration(milliseconds: 100));
    _summaryController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _itemsController.dispose();
    _summaryController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  String _formatTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order Details'),
        
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderPrintPreviewPage(
                    order: widget.order,
                    orderNumber: widget.orderNumber,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Header Card with animation
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: _buildOrderHeader(context),
              ),
            ),
            
            // Order Items List with staggered animation
            _buildOrderItems(context),
            
            // Price Summary with animation
            FadeTransition(
              opacity: _summaryAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_summaryAnimation),
                child: _buildPriceSummary(context),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.green,
                  size: 24, // Reduced from 28
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order#${widget.orderNumber}',
                      style: const TextStyle(
                        fontSize: 18, // Reduced from 20
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(widget.order.orderDate),
                      style: TextStyle(
                        fontSize: 13, // Reduced from 14
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced from 20
          const Divider(),
          const SizedBox(height: 10), // Reduced from 16
          
          // Order Information
          _buildInfoRow(Icons.access_time, 'Time', _formatTime(widget.order.orderDate)),
          const SizedBox(height: 8), // Reduced from 12
          _buildInfoRow(Icons.person_outline, 'Employee Name', widget.order.empName ?? 'Not found'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.store_outlined, 'Shop', widget.order.shopNamep ?? 'Unknown Shop'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, 'Address', widget.order.address ?? 'Unknown'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.shopping_bag_outlined, 'Total Items', widget.order.items.length.toString()),
        ],  
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]), // Reduced from 20
        const SizedBox(width: 10), // Reduced from 12
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13, // Reduced from 14
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13, // Reduced from 14
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 16, // Reduced from 18
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, // Reduced from 10
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.order.items.length} items',
                  style: TextStyle(
                    fontSize: 11, // Reduced from 12
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 20
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.order.items.length,
            separatorBuilder: (context, index) => const Divider(height: 20), // Reduced from 24
            itemBuilder: (context, index) {
              final item = widget.order.items[index];
              return FadeTransition(
                opacity: _itemAnimations[index],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(_itemAnimations[index]),
                  child: _buildOrderItemCard(item, index + 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItem item, int itemNumber) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item number badge
        Container(
          width: 28, // Reduced from 32
          height: 28, // Reduced from 32
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$itemNumber',
              style: TextStyle(
                fontSize: 13, // Reduced from 14
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12), // Reduced from 16
        
        // Item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName ?? item.productId}',
                      style: const TextStyle(
                        fontSize: 14, // Reduced from 15
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${(item.totalPrice).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15, // Reduced from 16
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reduced from 12
              
              // Quantity and price details
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, 
                              size: 15, // Reduced from 16
                              color: Colors.grey[700]
                            ),
                            const SizedBox(width: 6), // Reduced from 8
                            Text(
                              'Unit',
                              style: TextStyle(
                                fontSize: 12, // Reduced from 13
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${item.productUnit} ${item.measuringUnit ?? ''}'.trim(),
                          style: const TextStyle(
                            fontSize: 12, // Reduced from 13
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // Reduced from 8
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart_outlined, 
                              size: 15,
                              color: Colors.grey[700]
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.currency_rupee, 
                              size: 15,
                              color: Colors.grey[700]
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Price per unit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${(item.price).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                
                style: TextStyle(
                  fontSize: 13, // Reduced from 14
                  color: Colors.white,
                ),
              ),
              Text(
                '₹${(widget.order.totalPrice).toStringAsFixed(2)}',
                style: const TextStyle(   
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Reduced from 12
          const Divider(color: Colors.white, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16, // Reduced from 18
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '₹${widget.order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22, // Reduced from 24
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
