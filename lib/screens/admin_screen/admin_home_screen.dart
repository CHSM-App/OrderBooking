import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/admin_login.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/landing_Screen.dart';

import 'admin_addEmployee.dart';
import 'admin_addProduct.dart';
import 'admin_employeeDetails.dart';
import 'admin_notifications.dart';
import 'admin_regionDetails.dart';
import 'admin_shopDetails.dart';



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
                icon: Icons.add_box_outlined,
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
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _quickActionCard(
              title: "View Regions",
              icon: Icons.location_on_outlined,
              color: const Color(0xFFFF5722),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegionListPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _quickActionCard(
              title: "View Shops",
              icon: Icons.store_outlined,
              color: const Color(0xFF9C27B0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShopListPage(),
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

