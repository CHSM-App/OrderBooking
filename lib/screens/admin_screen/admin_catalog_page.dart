

//===================================== CATALOG PAGE ====================================//
import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addProduct.dart';

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



