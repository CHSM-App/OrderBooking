
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
            labelColor: const Color(0xFF2196F3),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2196F3),
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
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order["status"]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isPending ? Colors.orange : Colors.green,
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



class OrderDetailsPage extends StatelessWidget {
  final Map<String, String> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // appBar: adminAppBar(context, "Order Details"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Shop Name", order["shop"]!),
                _detailRow("Region", order["region"]!),
                _detailRow("Address", order["address"]!),
                _detailRow("Order Date", order["date"]!),
                _detailRow("Amount", order["amount"]!),
                _detailRow("Status", order["status"]!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}











