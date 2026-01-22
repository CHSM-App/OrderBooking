import 'package:flutter/material.dart';
import 'package:order_booking_app/domain/models/models.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // name, price_low, price_high

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _products = [
      Product(id: '1', name: 'Orange Juice', unit: 'Liter', price: 120, imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&h=400&fit=crop'),
      Product(id: '2', name: 'Apple Juice', unit: 'Liter', price: 150, imageUrl: 'https://images.unsplash.com/photo-1576673442511-7e39b6545c87?w=400&h=400&fit=crop'),
      Product(id: '3', name: 'Mango Juice', unit: 'Liter', price: 140, imageUrl: 'https://images.unsplash.com/photo-1587373604449-0b7de7b2e1c4?w=400&h=400&fit=crop'),
      Product(id: '4', name: 'Pineapple Juice', unit: 'Liter', price: 130, imageUrl: 'https://images.unsplash.com/photo-1589589254225-f0a35e83e83f?w=400&h=400&fit=crop'),
      Product(id: '5', name: 'Mixed Fruit Juice', unit: 'Liter', price: 160, imageUrl: 'https://images.unsplash.com/photo-1546548970-71785318a17b?w=400&h=400&fit=crop'),
      Product(id: '6', name: 'Watermelon Juice', unit: 'Liter', price: 110, imageUrl: 'https://images.unsplash.com/photo-1563227812-0ea4c22e6cc8?w=400&h=400&fit=crop'),
      Product(id: '7', name: 'Pomegranate Juice', unit: 'Liter', price: 180, imageUrl: 'https://images.unsplash.com/photo-1610885434515-23ff3fafad8a?w=400&h=400&fit=crop'),
      Product(id: '8', name: 'Grape Juice', unit: 'Liter', price: 135, imageUrl: 'https://images.unsplash.com/photo-1596215143922-eeab8d77b19c?w=400&h=400&fit=crop'),
      Product(id: '9', name: 'Carrot Juice', unit: 'Liter', price: 125, imageUrl: 'https://images.unsplash.com/photo-1585238341710-886a75e3dbc9?w=400&h=400&fit=crop'),
      Product(id: '10', name: 'Beetroot Juice', unit: 'Liter', price: 140, imageUrl: 'https://images.unsplash.com/photo-1598513068456-ccc79d1e2edf?w=400&h=400&fit=crop'),
      Product(id: '11', name: 'Lemon Juice', unit: 'Liter', price: 100, imageUrl: 'https://images.unsplash.com/photo-1523677011781-c91d1bbe1c80?w=400&h=400&fit=crop'),
      Product(id: '12', name: 'Coconut Water', unit: 'Liter', price: 90, imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&h=400&fit=crop'),
    ];
    _filteredProducts = _products;
    _sortProducts();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _sortProducts();
    });
  }

  void _sortProducts() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'price_low':
          _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     
      
      body: Column(
        children: [
          // Search Bar
          const SizedBox(height: 16),
        Container(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  child: Row(
    children: [
      // Search Field
      Expanded(
        child: TextField(
          controller: _searchController,
          onChanged: _filterProducts,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Search products by name...',
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      _searchController.clear();
                      _filterProducts('');
                    },
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
      ),

      const SizedBox(width: 12),

      // Sort Button
      Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: Colors.black),
          onSelected: (value) {
            setState(() {
              _sortBy = value;
              _sortProducts();
            });
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'name',
              child: Text('Sort by Name'),
            ),
            PopupMenuItem(
              value: 'price_low',
              child: Text('Price: Low to High'),
            ),
            PopupMenuItem(
              value: 'price_high',
              child: Text('Price: High to Low'),
            ),
          ],
        ),
      ),
    ],
  ),
),


          // Product Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} Products',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Sorted by: ${_sortBy == "name" ? "Name" : _sortBy == "price_low" ? "Price ↑" : "Price ↓"}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Product Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showProductDetails(context, product);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.green.shade100,
                                  Colors.green.shade200,
                                ],
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.green.shade100,
                                  Colors.green.shade200,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.local_drink,
                              size: 60,
                              color: Colors.green.shade700,
                            ),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.shade100,
                              Colors.green.shade200,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.local_drink,
                          size: 60,
                          color: Colors.green.shade700,
                        ),
                      ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'per ${product.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade100, Colors.green.shade200],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.local_drink,
                          size: 80,
                          color: Colors.green.shade700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.shopping_cart,
              label: 'Unit',
              value: product.unit,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.currency_rupee,
              label: 'Price',
              value: '₹${product.price.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fresh and natural juice with no artificial flavors',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}