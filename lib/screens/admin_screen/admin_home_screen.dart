import 'package:flutter/material.dart';

import 'admin_addEmployee.dart';
import 'admin_addProduct.dart';
import 'admin_employeeDetails.dart';
import 'admin_notifications.dart';

class AdminHomePage extends StatelessWidget {
  final Function(int, {int ordersTab}) onNavigate;

  const AdminHomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2196F3).withOpacity(0.05),
            Colors.white,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your business at a glance",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                // _modernDashboardCard(
                //   title: "Pending Orders",
                //   value: "24",
                //   icon: Icons.pending_actions_rounded,
                //   gradient: const LinearGradient(
                //     colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                //   ),
                //   trend: "+12%",
                // ),
                // _modernDashboardCard(
                //   title: "Active Employees",
                //   value: "12",
                //   icon: Icons.people_rounded,
                //   gradient: const LinearGradient(
                //     colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                //   ),
                //   trend: "+5%",
                // ),
                // _modernDashboardCard(
                //   title: "Total Revenue",
                //   value: "₹45K",
                //   icon: Icons.attach_money_rounded,
                //   gradient: const LinearGradient(
                //     colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                //   ),
                //   trend: "+18%",
                // ),
                // _modernDashboardCard(
                //   title: "Products",
                //   value: "156",
                //   icon: Icons.inventory_2_rounded,
                //   gradient: const LinearGradient(
                //     colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                //   ),
                //   trend: "+3%",
                // ),
                // 🔸 Pending Orders
_modernDashboardCard(
  title: "Pending Orders",
  value: "24",
  icon: Icons.pending_actions_rounded,
  gradient: const LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
  ),
  trend: "",
  onTap: () => onNavigate(2, ordersTab: 0), // Orders → Pending
),

// 🔸 Active Employees
_modernDashboardCard(
  title: "Active Employees",
  value: "12",
  icon: Icons.people_rounded,
  gradient: const LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
  ),
  trend: "",
  onTap: () => onNavigate(3), // Employees
),

// 🔸 Products
_modernDashboardCard(
  title: "Products",
  value: "156",
  icon: Icons.inventory_2_rounded,
  gradient: const LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
  ),
  trend: "",
  onTap: () => onNavigate(1), // Catalog
),
                // 🔸 Total Revenue
_modernDashboardCard(   
  title: "Total Revenue",
  value: "₹45K",
  icon: Icons.attach_money_rounded,
  gradient: const LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
  ),  
  trend: "",
  onTap: () {   
    // No navigation for revenue
  },
),
              ],
            ),
            const SizedBox(height: 32),
            _quickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _modernDashboardCard({
  required String title,
  required String value,
  required IconData icon,
  required Gradient gradient,
  required String trend,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trend,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
  );
}


  Widget _quickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                title: "Add Product",
                icon: Icons.add_circle_outline,
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddProductPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionCard(
                title: "New Employee",
                icon: Icons.person_add_outlined,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEmployeeForm(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



//===================================== CATALOG PAGE ====================================//
class AdminCatalogPage extends StatelessWidget {
  const AdminCatalogPage({super.key});

  final List<Map<String, dynamic>> products = const [
    {"name": "Apple Juice", "type": "Beverage", "color": Color(0xFFFF5252)},
    {"name": "Orange Juice", "type": "Beverage", "color": Color(0xFFFF9800)},
    {"name": "Banana Smoothie", "type": "Beverage", "color": Color(0xFFFFEB3B)},
    {"name": "Mango Juice", "type": "Beverage", "color": Color(0xFFFFD54F)},
    {"name": "Grapes Juice", "type": "Beverage", "color": Color(0xFF9C27B0)},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.grey[50], // Light grey background
          child: Column(
            children: [
              /// Product List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _modernProductCard(context, product, index);
                  },
                ),
              ),
            ],
          ),
        ),

        /// Floating Add Product Button (Bottom Right)
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF2196F3),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductPage(),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _modernProductCard(BuildContext context, Map<String, dynamic> product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Card stays white
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        product["color"].withOpacity(0.8),
                        product["color"],
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_drink_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product["name"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product["type"]!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Price removed
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}




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

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 2, vsync: this);
  // }
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























class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   title: const Text("Profile"),
      //   backgroundColor: const Color(0xFF2196F3),
      // ),
      body: Column(
        children: [
          const SizedBox(height: 24),

          /// Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF2196F3),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Admin Name",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "admin@email.com",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// Options
          _buildTile(Icons.edit, "Edit Profile"),
          _buildTile(Icons.lock_outline, "Change Password"),
          _buildTile(Icons.logout, "Logout", isLogout: true),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xFF2196F3),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}