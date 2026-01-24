import 'package:flutter/material.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({Key? key}) : super(key: key);

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Dummy shop data (replace with API response)
  final List<Map<String, String>> shops = const [
    {
      "shopName": "Sai Kirana Store",
      "owner": "Ramesh Patil",
      "mobile": "9876543210",
      "region": "Andheri East",
      "address": "Mumbai, Maharashtra"
    },
    {
      "shopName": "Shree Medical",
      "owner": "Suresh Jain",
      "mobile": "9123456780",
      "region": "Borivali West",
      "address": "Mumbai, Maharashtra"
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "All Shops",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];

          // Staggered animation
          final animation = Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.2,
                1,
                curve: Curves.easeOut,
              ),
            ),
          );

          return FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position: animation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // Handle shop tap
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shop Header
                          Row(
                            children: [
                              // Shop Icon
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF57C00).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.store_rounded,
                                  color: Color(0xFFF57C00),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Shop Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shop["shopName"]!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0A3D62),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2196F3).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        shop["region"]!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2196F3),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow Icon
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey[400],
                                size: 16,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Divider
                          Divider(
                            color: Colors.grey[200],
                            height: 1,
                          ),

                          const SizedBox(height: 12),

                          // Owner Info
                          _buildInfoRow(
                            Icons.person_outline_rounded,
                            "Owner",
                            shop["owner"]!,
                          ),
                          const SizedBox(height: 10),

                          // Mobile Info
                          _buildInfoRow(
                            Icons.phone_outlined,
                            "Mobile",
                            shop["mobile"]!,
                          ),
                          const SizedBox(height: 10),

                          // Address Info
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            "Address",
                            shop["address"]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF1A1A1A),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF1A1A1A).withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}