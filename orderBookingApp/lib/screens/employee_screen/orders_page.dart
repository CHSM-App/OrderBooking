// import 'package:flutter/material.dart';
// import 'package:order_booking_app/domain/models/shop_details.dart';

// import 'package:order_booking_app/screens/theme.dart';

// class OrdersPage extends StatefulWidget {
//   const OrdersPage({Key? key}) : super(key: key);

//   @override
//   State<OrdersPage> createState() => _OrdersPageState();
// }

// class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<Order> _allOrders = [];
//   List<Order> _todayOrders = [];
//   List<Order> _weekOrders = [];
//   List<Order> _monthOrders = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadOrders();
//   }

//   void _loadOrders() {
//     final sampleShop = ShopDetails(
//       shopId: 1,
//       shopName: 'Green Juice Corner',
//       address: 'Shop 12, Market Street, Mumbai',
//       latitude: 19.0760,
//       longitude: 72.8777,
//     );

//     final sampleProducts = [
//       Product1(id: '1', name: 'Orange Juice', unit: 'Liter', price: 120),
//       Product1(id: '2', name: 'Apple Juice', unit: 'Liter', price: 150),
//       Product1(id: '3', name: 'Mango Juice', unit: 'Liter', price: 140),
//     ];

//     _allOrders = [
//       Order(
//         id: 'ORD001',
//         shop: sampleShop,
//         items: [
//           OrderItem(product: sampleProducts[0], quantity: 5),
//           OrderItem(product: sampleProducts[1], quantity: 3),
//         ],
//         createdAt: DateTime.now().subtract(const Duration(hours: 2)),
//         status: 'Delivered',
//         punchInTime: DateTime.now().subtract(const Duration(hours: 3)),
//         punchOutTime: DateTime.now().subtract(const Duration(hours: 2)),
//       ),
//       Order(
//         id: 'ORD002',
//         shop: sampleShop,
//         items: [
//           OrderItem(product: sampleProducts[2], quantity: 4),
//         ],
//         createdAt: DateTime.now().subtract(const Duration(hours: 5)),
//         status: 'Delivered',
//       ),
//       Order(
//         id: 'ORD003',
//         shop: sampleShop,
//         items: [
//           OrderItem(product: sampleProducts[0], quantity: 10),
//           OrderItem(product: sampleProducts[1], quantity: 8),
//         ],
//         createdAt: DateTime.now().subtract(const Duration(days: 2)),
//         status: 'Delivered',
//       ),
//       Order(
//         id: 'ORD004',
//         shop: sampleShop,
//         items: [
//           OrderItem(product: sampleProducts[2], quantity: 6),
//         ],
//         createdAt: DateTime.now().subtract(const Duration(days: 5)),
//         status: 'Delivered',
//       ),
//     ];

//     _todayOrders = _allOrders.where((order) {
//       final diff = DateTime.now().difference(order.createdAt);
//       return diff.inHours < 24;
//     }).toList();

//     _weekOrders = _allOrders.where((order) {
//       final diff = DateTime.now().difference(order.createdAt);
//       return diff.inDays < 7;
//     }).toList();

//     _monthOrders = _allOrders.where((order) {
//       final diff = DateTime.now().difference(order.createdAt);
//       return diff.inDays < 30;
//     }).toList();
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inHours < 1) {
//       return '${difference.inMinutes} minutes ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} hours ago';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'delivered':
//         return AppTheme.successColor;
//       case 'pending':
//         return AppTheme.warningColor;
//       case 'cancelled':
//         return AppTheme.errorColor;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Modern Header
//             Container(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 10),
//                   // Modern Tab Bar
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: TabBar(
//                       controller: _tabController,
//                       isScrollable: true,
//                       tabAlignment: TabAlignment.start,
//                       indicator: BoxDecoration(
//                         gradient: AppTheme.primaryGradient,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       labelColor: Colors.white,
//                       unselectedLabelColor: AppTheme.textSecondary,
//                       labelStyle: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                       ),
//                       unselectedLabelStyle: const TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 13,
//                         fontStyle: FontStyle.normal,
//                       ),
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       dividerColor: Colors.transparent,
//                       padding: const EdgeInsets.all(4),
//                       labelPadding: const EdgeInsets.symmetric(horizontal: 20),
//                       tabs: [
//                         Tab(text: 'All (${_allOrders.length})'),
//                         Tab(text: 'Today (${_todayOrders.length})'),
//                         Tab(text: 'Week (${_weekOrders.length})'),
//                         Tab(text: 'Month (${_monthOrders.length})'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Tab View
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _OrderList(
//                       orders: _allOrders,
//                       formatDate: _formatDate,
//                       getStatusColor: _getStatusColor),
//                   _OrderList(
//                       orders: _todayOrders,
//                       formatDate: _formatDate,
//                       getStatusColor: _getStatusColor),
//                   _OrderList(
//                       orders: _weekOrders,
//                       formatDate: _formatDate,
//                       getStatusColor: _getStatusColor),
//                   _OrderList(
//                       orders: _monthOrders,
//                       formatDate: _formatDate,
//                       getStatusColor: _getStatusColor),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }

// class _OrderList extends StatelessWidget {
//   final List<Order> orders;
//   final String Function(DateTime) formatDate;
//   final Color Function(String) getStatusColor;

//   const _OrderList({
//     required this.orders,
//     required this.formatDate,
//     required this.getStatusColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (orders.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.receipt_long_outlined,
//                 size: 60,
//                 color: Colors.grey.shade400,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'No orders found',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textSecondary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Orders will appear here once placed',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppTheme.textLight,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//       itemCount: orders.length,
//       itemBuilder: (context, index) {
//         final order = orders[index];
//         return _OrderCard(
//           order: order,
//           formatDate: formatDate,
//           getStatusColor: getStatusColor,
//         );
//       },
//     );
//   }
// }

// class _OrderCard extends StatelessWidget {
//   final Order order;
//   final String Function(DateTime) formatDate;
//   final Color Function(String) getStatusColor;

//   const _OrderCard({
//     required this.order,
//     required this.formatDate,
//     required this.getStatusColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             showModalBottomSheet(
//               context: context,
//               isScrollControlled: true,
//               backgroundColor: Colors.transparent,
//               builder: (context) => _OrderDetailsSheet(order: order),
//             );
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         gradient: AppTheme.primaryGradient,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.receipt_long,
//                         color: Colors.white,
//                         size: 22,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             order.id,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.textPrimary,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             formatDate(order.createdAt),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppTheme.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: getStatusColor(order.status).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: getStatusColor(order.status).withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         order.status,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: getStatusColor(order.status),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Shop Info
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.store_rounded,
//                         size: 18,
//                         color: AppTheme.textSecondary,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           order.shop.shopName,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppTheme.textPrimary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // Items Summary
//                 Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppTheme.primaryColor.withOpacity(0.1),
//                         AppTheme.secondaryColor.withOpacity(0.15)
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.shopping_bag_rounded,
//                             size: 18,
//                             color: AppTheme.primaryColor,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             '${order.items.length} items',
//                             style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                               color: AppTheme.textPrimary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         '₹${order.totalAmount.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: AppTheme.primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _OrderDetailsSheet extends StatelessWidget {
//   final Order order;

//   const _OrderDetailsSheet({required this.order});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         expand: false,
//         builder: (context, scrollController) {
//           return Column(
//             children: [
//               // Handle
//               Container(
//                 margin: const EdgeInsets.only(top: 12, bottom: 8),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Expanded(
//                 child: ListView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(24),
//                   children: [
//                     // Header
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             gradient: AppTheme.primaryGradient,
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: const Icon(
//                             Icons.receipt_long,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Order Details',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: AppTheme.textLight,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 order.id,
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppTheme.textPrimary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 28),

//                     // Shop Section
//                     const Text(
//                       'Shop Details',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: AppTheme.primaryColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Icon(
//                               Icons.store_rounded,
//                               color: AppTheme.primaryColor,
//                               size: 22,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   order.shop.shopName,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: AppTheme.textPrimary,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   order.shop.address,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: AppTheme.textSecondary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Items Section
//                     const Text(
//                       'Order Items',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     ...order.items.map((item) {
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.primaryColor.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Icon(
//                                 Icons.local_drink_rounded,
//                                 color: AppTheme.primaryColor,
//                                 size: 22,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     item.product.name,
//                                     style: const TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       color: AppTheme.textPrimary,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     '${item.quantity} ${item.product.unit} × ₹${item.product.price}',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: AppTheme.textSecondary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Text(
//                               '₹${item.total.toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppTheme.textPrimary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
                    
//                     const SizedBox(height: 12),
//                     Divider(color: Colors.grey.shade300, thickness: 1),
//                     const SizedBox(height: 12),

//                     // Total
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppTheme.primaryColor.withOpacity(0.1),
//                             AppTheme.secondaryColor.withOpacity(0.15)
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Total Amount',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.textPrimary,
//                             ),
//                           ),
//                           Text(
//                             '₹${order.totalAmount.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }