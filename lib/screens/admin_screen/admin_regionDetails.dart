import 'package:flutter/material.dart';
import 'admin_addRegion.dart';

class RegionListPage extends StatefulWidget {
  const RegionListPage({Key? key}) : super(key: key);

  @override
  State<RegionListPage> createState() => _RegionListPageState();
}

class _RegionListPageState extends State<RegionListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, String>> regions = const [
    {
      "region": "Andheri East",
      "pincode": "400069",
      "district": "Mumbai",
      "state": "Maharashtra",
    },
    {
      "region": "Borivali West",
      "pincode": "400092",
      "district": "Mumbai",
      "state": "Maharashtra",
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
          "Regions",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          elevation: 4,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRegionPage()),
            );
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: regions.length,
        itemBuilder: (context, index) {
                final region = regions[index];

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
                            // Handle region tap
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                // Icon Container
                                Container(
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Color(0xFF2196F3),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        region["region"]!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_city_outlined,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "${region["district"]}, ${region["state"]}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.pin_drop_outlined,
                                              size: 12,
                                              color: Colors.grey[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              region["pincode"]!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
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
}