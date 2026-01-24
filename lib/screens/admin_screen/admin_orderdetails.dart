
//===================================== ORDERS PAGE ====================================//

import 'dart:ui';

import 'package:flutter/material.dart';

class AdminOrdersPage extends StatefulWidget {
  final int initialTabIndex;

  const AdminOrdersPage({
    super.key,
    this.initialTabIndex = 0, // Pending by default
  });


  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> orders = const [
    {
      "shop": "Raju Mart",
      "region": "Sawantwadi",
      "address": "Main Road, Sawantwadi",
      "date": "21 Dec 2025",
      "amount": "₹12,450",
      "status": "Pending",
    },
    {
      "shop": "Shree Stores",
      "region": "Kudal",
      "address": "Market Area, Kudal",
      "date": "22 Dec 2025",
      "amount": "₹8,300",
      "status": "Completed",
    },
    {
      "shop": "Om Sai Shop",
      "region": "Vengurla",
      "address": "Near Bus Stand, Vengurla",
      "date": "23 Dec 2025",
      "amount": "₹5,900",
      "status": "Pending",
    },
  ];

  
@override
void initState() {
  super.initState();
  _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTabIndex, // ✅ REQUIRED
  );
}


  @override
  Widget build(BuildContext context) {
    final pendingOrders =
        orders.where((o) => o["status"] == "Pending").toList();
    final completedOrders =
        orders.where((o) => o["status"] == "Completed").toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// 🔹 TAB BAR — NO TOP GAP
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFF57C00),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFF57C00),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Pending (${pendingOrders.length})"),
              Tab(text: "Completed (${completedOrders.length})"),
            ],
          ),

          /// 🔹 TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ordersList(context, pendingOrders),
                _ordersList(context, completedOrders),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ordersList(
      BuildContext context, List<Map<String, String>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _modernOrderCard(context, list[index]);
      },
    );
  }

  Widget _modernOrderCard(BuildContext context, Map<String, String> order) {
    final isPending = order["status"] == "Pending";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order["shop"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? Colors.red.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order["status"]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isPending ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                order["region"]!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order["date"]!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order["amount"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



//===================================== ORDER DETAILS PAGE ====================================//






class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key, required Map<String, String> order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  // ---------------- DUMMY DATA ----------------

  String orderStatus = "Pending";

  final Map<String, String> shopDetails = {
    "shopName": "Fresh Juice Center",
    "ownerName": "Rahul Sharma",
    "mobile": "9876543210",
    "address": "Andheri East, Mumbai",
    "region": "Mumbai West",
  };

  final List<Map<String, dynamic>> orderItems = [
    {
      "product": "Apple Juice",
      "size": "0.25L",
      "qty": 50,
      "price": 15.0,
    },
    {
      "product": "Orange Juice",
      "size": "0.5L",
      "qty": 30,
      "price": 25.0,
    },
    {
      "product": "Mango Juice",
      "size": "1L",
      "qty": 20,
      "price": 60.0,
    },
  ];

  final int gstPercent = 18;

  // --------------------------------------------

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
          ..forward();

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get subTotal {
    double total = 0;
    for (final item in orderItems) {
      total += item['qty'] * item['price'];
    }
    return total;
  }

  double get gstAmount => subTotal * gstPercent / 100;
  double get grandTotal => subTotal + gstAmount;

  Color get statusColor =>
      orderStatus == "Completed" ? Colors.green : Colors.red;

  Color get statusBg =>
      orderStatus == "Completed"
          ? Colors.green.shade50
          : Colors.red.shade50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Order Details"),
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔹 STATUS BAR
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  "Order Status",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: orderStatus,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Pending",
                            child: Text("Pending"),
                          ),
                          DropdownMenuItem(
                            value: "Completed",
                            child: Text("Completed"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => orderStatus = value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 CONTENT
          Expanded(
            child: FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _section("Shop Details"),
                      _card([
                        _info("Shop Name", shopDetails["shopName"]!),
                        _info("Owner Name", shopDetails["ownerName"]!),
                        _info("Mobile", shopDetails["mobile"]!),
                        _info("Address", shopDetails["address"]!),
                        _info("Region", shopDetails["region"]!),
                      ]),

                      const SizedBox(height: 24),

                      _section("Order Details"),
                      _card([
                        _info("Order Date", "21 Jan 2026, 11:30 AM"),
                        _info("Order Taken By", "Ajay Kumar"),
                        const SizedBox(height: 12),

                        const Text(
                          "Order Items",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),

                        ...orderItems.map((item) {
                          final double total =
                              item['qty'] * item['price'];
                          return _orderItem(item, total);
                        }),

                        const Divider(height: 30),

                        _amount("Sub Total", subTotal),
                        _amount("GST ($gstPercent%)", gstAmount),
                        _amount("Total Amount", grandTotal, isTotal: true),
                      ]),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6F00),
                            foregroundColor:  Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Download Invoice",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget _section(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderItem(Map<String, dynamic> item, double total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_drink, color: Color(0xFF4F8DF7)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product'],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  "${item['size']} • Qty ${item['qty']} • ₹${item['price']}",
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            "₹${total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F8DF7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amount(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                      isTotal ? FontWeight.w700 : FontWeight.w500)),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w700,
              color:
                  isTotal ? const Color(0xFF4F8DF7) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

