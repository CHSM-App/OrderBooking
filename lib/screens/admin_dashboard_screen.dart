import 'package:flutter/material.dart';
import 'admin_addEmployee.dart';
import 'admin_addProduct.dart';
import 'admin_employeeDetails.dart';
import 'admin_notifications.dart';

PreferredSizeWidget adminAppBar(
  BuildContext context,
  String title,
) {
  return AppBar(
    backgroundColor: const Color(0xFF2196F3),
    elevation: 0,
    automaticallyImplyLeading: false,

    // 🔹 LEFT: Profile + Title TOGETHER
    titleSpacing: 16,
    title: Row(
      children: [
        // Profile photo
        GestureDetector(
          onTap: () {
            // open profile / drawer
          },
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Color(0xFF2196F3),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Title
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),

    // 🔹 RIGHT: Notification icon
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 26,
            color: Colors.white,
          ),
          onPressed: () {
             Navigator.push(
                context,                
                MaterialPageRoute(                  
                  builder: (_) => const AdminNotificationPage(),
             )
             );
          },
        ),
      ),
    ],
  );
}



// PreferredSizeWidget adminAppBar(
//   BuildContext context,
//   String title, {
//   bool showBack = true,
// }) {
//   return AppBar(
//     backgroundColor: const Color(0xFF2196F3),
//     elevation: 0,
//     leading: showBack
//         ? Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.account_circle_outlined,
//                 color: Colors.white,
//                 size: 22,
//               ),
//               onPressed: () {},
//               padding: EdgeInsets.zero,
//             ),
//           )
//         : null,
//     titleSpacing: 0,
//     title: Text(
//       title,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         letterSpacing: 0.5,
//       ),
//     ),
//     centerTitle: false,
//     actions: [
//       Stack(
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.notifications_outlined,
//                 color: Colors.white,
//                 size: 22,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const AdminNotificationPage(),
//                   ),
//                 );
//               },
//               padding: const EdgeInsets.all(8),
//             ),
//           ),
//           Positioned(
//             right: 12,
//             top: 12,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               child: const Text(
//                 '3',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(width: 8),
//     ],
//   );
// }


// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({Key? key}) : super(key: key);

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const AdminHomePage(),
//     const AdminCatalogPage(),
//     const AdminOrdersPage(),
//     const AdminEmployeesPage(),
//     const AdminProfilePage(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: adminAppBar(context, "Admin Dashboard", showBack: true),
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 300),
//         child: _pages[_selectedIndex],
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, -5),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: const Color(0xFF2196F3),
//           unselectedItemColor: Colors.grey[400],
//           selectedFontSize: 12,
//           unselectedFontSize: 11,
//           elevation: 0,
//           backgroundColor: Colors.white,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: "Home",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.inventory_2_outlined),
//               activeIcon: Icon(Icons.inventory_2),
//               label: "Catalog",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_cart_outlined),
//               activeIcon: Icon(Icons.shopping_cart),
//               label: "Orders",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.people_outline),
//               activeIcon: Icon(Icons.people),
//               label: "Employees",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: "Profile",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  int _ordersInitialTab = 0; // 🔹 controls Pending / Completed

  void navigateToTab(int index, {int ordersTab = 0}) {
    setState(() {
      _selectedIndex = index;
      _ordersInitialTab = ordersTab;
    });
  }

  List<Widget> get _pages => [
        AdminHomePage(onNavigate: navigateToTab), // 0
        const AdminCatalogPage(),                 // 1
        AdminOrdersPage(initialTabIndex: _ordersInitialTab), // 2
        const AdminEmployeesPage(),               // 3
        const AdminProfilePage(),                 // 4
      ];

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _pages[_selectedIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => navigateToTab(index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Catalog"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Employees"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    ),
  );
}

  PreferredSizeWidget _buildAppBar() {
    String title;
    switch (_selectedIndex) {
      case 0:
        title = "Admin Dashboard";
        break;
      case 1:
        title = "Catalog";
        break;
      case 2:
        title = "Orders";
        break;
      case 3:
        title = "Employees";
        break;
      case 4:
        title = "Profile";
        break;
      default:
        title = "Admin Dashboard";
    }
    return adminAppBar(context, title,);
  }
}



// class AdminHomePage extends StatelessWidget {
//   const AdminHomePage({super.key});
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
      appBar: adminAppBar(context, "Order Details"),
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








class AdminEmployeesPage extends StatelessWidget {
  const AdminEmployeesPage({super.key});

  final List<Map<String, String>> employees = const [
    {"name": "John Doe", "region": "Sindhudurg", "status": "Active"},
    {"name": "Jane Smith", "region": "Ratnagiri", "status": "Inactive"},
    {"name": "Michael Brown", "region": "Kolhapur", "status": "Active"},
    {"name": "Emily Davis", "region": "Goa", "status": "Active"},
    {"name": "David Wilson", "region": "Pune", "status": "Inactive"},
  ];

  @override
  Widget build(BuildContext context) {
    final activeCount =
        employees.where((e) => e["status"] == "Active").length;
    final inactiveCount =
        employees.where((e) => e["status"] == "Inactive").length;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    // Navigate to AddEmployeeForm
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEmployeeForm(),
      ),
    );
  },
  backgroundColor: const Color(0xFF2196F3),
  child: const Icon(Icons.add),
),

      body: Column(
        children: [
          // 🔵 OVERVIEW CARD
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _overviewItem(
                        title: "Active",
                        count: activeCount,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: Colors.white.withOpacity(0.35),
                    ),
                    Expanded(
                      child: _overviewItem(
                        title: "Inactive",
                        count: inactiveCount,
                        icon: Icons.cancel_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 EMPLOYEE LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                 return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeDetailsPage(
                employee: employees[index],
              ),
            ),
          );
        },
        child: _employeeCard(context, employees[index], index),
      );
    },
  ),
),
                    
          
        ],
      ),
    );
  }

  // 🔹 OVERVIEW ITEM
  Widget _overviewItem({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 EMPLOYEE CARD (STATUS BOTTOM-RIGHT)
  Widget _employeeCard(
      BuildContext context, Map<String, String> employee, int index) {
    final isActive = employee["status"] == "Active";

    final avatarColors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
    ];

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
      child: Stack(
        children: [
          // ✏️ EDIT ICON (TOP RIGHT)
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF2196F3),
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Edit ${employee["name"]}"),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        avatarColors[index % avatarColors.length],
                        avatarColors[index % avatarColors.length].withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      employee["name"]!.split(" ").map((e) => e[0]).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name + Region
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee["name"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee["region"]!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔵 STATUS (BOTTOM RIGHT)
          Positioned(
            bottom: 12,
            right: 16,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  employee["status"]!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green : Colors.redAccent,
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