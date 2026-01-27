import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/admin_screen/admin_addProduct.dart';

class AdminCatalogPage extends StatefulWidget {
  const AdminCatalogPage({super.key});

  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> products = [
    {"name": "Apple Juice", "type": "Beverage", "price": 50, "color": const Color(0xFFFF5252)},
    {"name": "Orange Juice", "type": "Beverage", "price": 40, "color": const Color(0xFFFF9800)},
    {"name": "Banana Smoothie", "type": "Beverage", "price": 60, "color": const Color(0xFFFFEB3B)},
    {"name": "Mango Juice", "type": "Beverage", "price": 55, "color": const Color(0xFFFFD54F)},
    {"name": "Grapes Juice", "type": "Beverage", "price": 45, "color": const Color(0xFF9C27B0)},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      return product["name"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
    
      body: Column(
        children: [
          /// 🔍 Search + Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search product...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                /// 🔽 Sort Filter
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      if (value == "low") {
                        products.sort(
                            (a, b) => a["price"].compareTo(b["price"]));
                      } else {
                        products.sort(
                            (a, b) => b["price"].compareTo(a["price"]));
                      }
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: "low",
                      child: Text("Price: Low to High"),
                    ),
                    PopupMenuItem(
                      value: "high",
                      child: Text("Price: High to Low"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 📦 Product List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return _modernProductCard(
                    context, filteredProducts[index]);
              },
            ),
          ),
        ],
      ),

      /// ➕ Add Product Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF57C00),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _modernProductCard(
      BuildContext context, Map<String, dynamic> product) {
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
                    product["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹${product["price"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
