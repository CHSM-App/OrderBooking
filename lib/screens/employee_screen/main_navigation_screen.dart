// // import 'package:flutter/material.dart';
// // import 'home_page.dart';
// // import 'shops_page.dart';
// // import 'orders_page.dart';
// // import 'catalog_page.dart';
// // import 'profile_page.dart';

// // class MainNavigationScreen extends StatefulWidget {
// //   const MainNavigationScreen({Key? key}) : super(key: key);

// //   @override
// //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // }

// // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// //   int _currentIndex = 0;
  
// //   final List<Widget> _pages = [
// //     const HomePage(),
// //     const ShopsPage(),
// //     const OrdersPage(),
// //     const CatalogPage(),
// //     const ProfilePage(),
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: IndexedStack(
// //         index: _currentIndex,
// //         children: _pages,
// //       ),
// //       bottomNavigationBar: Container(
// //         decoration: BoxDecoration(
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.1),
// //               blurRadius: 10,
// //               offset: const Offset(0, -2),
// //             ),
// //           ],
// //         ),
// //         child: BottomNavigationBar(
// //           currentIndex: _currentIndex,
// //           onTap: (index) {
// //             setState(() {
// //               _currentIndex = index;
// //             });
// //           },
// //           type: BottomNavigationBarType.fixed,
// //           backgroundColor: Colors.white,
// //           selectedItemColor: const Color(0xFFFFC107),
// //           unselectedItemColor: Colors.grey.shade400,
// //           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
// //           items: const [
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.home),
// //               label: 'Home',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.store),
// //               label: 'Shops',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.shopping_bag),
// //               label: 'Orders',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.grid_view),
// //               label: 'Catalog',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.person),
// //               label: 'Profile',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'home_page.dart';
// import 'shops_page.dart';
// import 'orders_page.dart';
// import 'catalog_page.dart';
// import 'profile_page.dart';

// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({Key? key}) : super(key: key);

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;
  
//   final List<Widget> _pages = [
//     const HomePage(),
//     const ShopsPage(),
//     const OrdersPage(),
//     const CatalogPage(),
//     const ProfilePage(),
//   ];

//   String _employeeName = "Ramesh Kumar";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFC107),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                     Color(0xFFFFC107), // Primary yellow
//           Color(0xFFFFE082), // Soft yellow
//           Color(0xFFE0E0E0), // Light warm grey
//               ],
//             ),
//           ),
//         ),
//         elevation: 0,
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFC107),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.person,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//         ),
//         title: Text(
//           _employeeName,
//           style: const TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             color: Colors.black,
//             onPressed: () {
//               // Open notifications
//             },
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//           selectedItemColor: const Color(0xFFFFC107),
//           unselectedItemColor: Colors.grey.shade400,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.store),
//               label: 'Shops',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_bag),
//               label: 'Orders',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.grid_view),
//               label: 'Catalog',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'shops_page.dart';
import 'orders_page.dart';
import 'catalog_page.dart';
import 'profile_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  
  final List<Widget> _pages = [
    const HomePage(),
    const ShopsPage(),
    const OrdersPage(),
    const CatalogPage(),
    const ProfilePage(),
  ];

  String _employeeName = "Ramesh Kumar";
  int _notificationCount = 3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
         Color.fromARGB(255, 79, 114, 230),
          Color.fromARGB(255, 6, 25, 91),
        ],
              
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: const Color(0xFFFFC107).withOpacity(0.3),
            //     blurRadius: 12,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFFFC107),
                  size: 35,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hello,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: Colors.white,
                    iconSize: 35,
                    onPressed: () {
                      // Open notifications
                    },
                  ),
                  if (_notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          _notificationCount > 9 ? '9+' : '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFFFC107),
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            elevation: 0,
            items: [
              _buildAnimatedNavItem(Icons.home_rounded, 'Home', 0),
              _buildAnimatedNavItem(Icons.store_rounded, 'Shops', 1),
              _buildAnimatedNavItem(Icons.shopping_bag_rounded, 'Orders', 2),
              _buildAnimatedNavItem(Icons.grid_view_rounded, 'Catalog', 3),
              _buildAnimatedNavItem(Icons.person_rounded, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildAnimatedNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: isSelected ? 10 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFFC107),
                    Color(0xFFFFD54F),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: isSelected ? 28 : 26,
          color: isSelected ? Colors.white : Colors.grey.shade400,
        ),
      ),
      label: label,
    );
  }
}