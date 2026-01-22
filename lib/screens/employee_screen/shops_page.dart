import 'package:flutter/material.dart';
import 'package:order_booking_app/domain/models/models.dart';
import 'add_shop_screen.dart';
import 'shop_visit_screen.dart';

class ShopsPage extends StatefulWidget {
  const ShopsPage({Key? key}) : super(key: key);

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  List<Shop> _shops = [];
  List<Shop> _filteredShops = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _loadShops() {
    _shops = [
      Shop(
        id: '1',
        shopName: 'Green Juice Corner',
        address: 'Shop 12, Market Street, Andheri West, Mumbai',
        latitude: 19.0760,
        longitude: 72.8777,
        ownerName: 'Ramesh Kumar',
        phoneNumber: '9876543210',
      ),
      Shop(
        id: '2',
        shopName: 'Fresh Fruits Hub',
        address: 'Plot 45, Station Road, Dadar, Mumbai',
        latitude: 19.0896,
        longitude: 72.8656,
        ownerName: 'Suresh Patel',
        phoneNumber: '9876543211',
      ),
      Shop(
        id: '3',
        shopName: 'Health Juice Bar',
        address: 'Building 7, Gandhi Nagar, Bandra, Mumbai',
        latitude: 19.0544,
        longitude: 72.8320,
        ownerName: 'Vijay Shah',
        phoneNumber: '9876543212',
      ),
      Shop(
        id: '4',
        shopName: 'Natural Drinks Shop',
        address: 'Shop 23, Main Market, Borivali, Mumbai',
        latitude: 19.2305,
        longitude: 72.8567,
        ownerName: 'Prakash Desai',
        phoneNumber: '9876543213',
      ),
    ];
    _filteredShops = _shops;
  }

  void _filterShops(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredShops = _shops;
      } else {
        _filteredShops = _shops
            .where((shop) =>
                shop.shopName.toLowerCase().contains(query.toLowerCase()) ||
                shop.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectShop(Shop shop) {
    // Auto punch in when shop selected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopVisitScreen(shop: shop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   backgroundColor: Colors.white,
      body: Column(
        children: [
        
            const SizedBox(height: 10),
          Container(
 // color: Colors.green,
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  child: TextField(
    controller: _searchController,
    onChanged: _filterShops,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Search shops by name or address...',
      hintStyle: const TextStyle(color: Colors.black),
      prefixIcon: const Icon(Icons.search, color: Colors.black),
      suffixIcon: _searchController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _searchController.clear();
                _filterShops('');
              },
            )
          : null,
      filled: false, // remove background fill
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1), // black border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2), // black border when focused
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),
  ),
),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        '${_filteredShops.length} Shops',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.map, size: 18),
        label: const Text('View Map'),
      ),
    ],
  ),
),


          // Shop List
          Expanded(
            child: _filteredShops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No shops found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredShops.length,
                    itemBuilder: (context, index) {
                      final shop = _filteredShops[index];
                      return _ShopCard(
                        shop: shop,
                        onTap: () => _selectShop(shop),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddShopScreen(),
            ),
          );
          if (result != null && result is Shop) {
            setState(() {
              _shops.add(result);
              _filteredShops = _shops;
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Shop'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

  const _ShopCard({
    required this.shop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.shopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shop.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (shop.ownerName != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            shop.ownerName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            shop.phoneNumber ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
