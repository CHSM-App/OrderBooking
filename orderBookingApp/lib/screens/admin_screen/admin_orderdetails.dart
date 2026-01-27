//===================================== ORDERS PAGE ====================================//

import 'package:flutter/material.dart';


class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 🔍 SEARCH FILTER
  List<Map<String, String>> get filteredOrders {
    if (_searchQuery.isEmpty) return orders;

    final query = _searchQuery.toLowerCase();
    return orders.where((o) {
      return o["shop"]!.toLowerCase().contains(query) ||
          o["region"]!.toLowerCase().contains(query) ||
          o["address"]!.toLowerCase().contains(query) ||
          o["date"]!.toLowerCase().contains(query) ||
          o["amount"]!.toLowerCase().contains(query) ||
          o["status"]!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: "Search orders...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 📦 ORDER LIST
          Expanded(
            child: _ordersList(context, filteredOrders),
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

  Widget _modernOrderCard(
    BuildContext context, Map<String, String> order) {
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
            /// SHOP NAME
            Text(
              order["shop"]!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 6),

            /// REGION
            Text(
              order["region"]!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 4),

            /// DATE
            Text(
              order["date"]!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(height: 10),

            /// AMOUNT + ARROW
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6F00),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: FadeTransition(
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
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  ...orderItems.map((item) {
                    final double total = item['qty'] * item['price'];
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
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Download Invoice",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "${item['size']} • Qty ${item['qty']} • ₹${item['price']}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
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
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w700,
              color: isTotal
                  ? const Color(0xFF4F8DF7)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
