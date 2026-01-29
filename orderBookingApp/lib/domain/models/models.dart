class Shop {
  final String id;
  final String shopName;
  final String address;
  final double latitude;
  final double longitude;
  final String? ownerName;
  final String? phoneNumber;

  Shop({
    required this.id,
    required this.shopName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.ownerName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'shopName': shopName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'ownerName': ownerName,
        'phoneNumber': phoneNumber,
      };

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json['id'],
        shopName: json['shopName'],
        address: json['address'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        ownerName: json['ownerName'],
        phoneNumber: json['phoneNumber'],
      );
}

class Product1 {
  final String id;
  final String name;
  final String unit;
  final double price;
  final String? imageUrl;

  Product1({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'price': price,
        'imageUrl': imageUrl,
      };

  factory Product1.fromJson(Map<String, dynamic> json) => Product1(
        id: json['id'],
        name: json['name'],
        unit: json['unit'],
        price: json['price'],
        imageUrl: json['imageUrl'],
      );
}

class OrderItem {
  final Product1 product;
  int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        product: Product1.fromJson(json['product']),
        quantity: json['quantity'],
      );
}

class Order {
  final String id;
  final Shop shop;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String status;
  final double? punchInLat;
  final double? punchInLng;
  final double? punchOutLat;
  final double? punchOutLng;
  final DateTime? punchInTime;
  final DateTime? punchOutTime;

  Order({
    required this.id,
    required this.shop,
    required this.items,
    required this.createdAt,
    required this.status,
    this.punchInLat,
    this.punchInLng,
    this.punchOutLat,
    this.punchOutLng,
    this.punchInTime,
    this.punchOutTime,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop': shop.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'status': status,
        'punchInLat': punchInLat,
        'punchInLng': punchInLng,
        'punchOutLat': punchOutLat,
        'punchOutLng': punchOutLng,
        'punchInTime': punchInTime?.toIso8601String(),
        'punchOutTime': punchOutTime?.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        shop: Shop.fromJson(json['shop']),
        items: (json['items'] as List)
            .map((e) => OrderItem.fromJson(e))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        status: json['status'],
        punchInLat: json['punchInLat'],
        punchInLng: json['punchInLng'],
        punchOutLat: json['punchOutLat'],
        punchOutLng: json['punchOutLng'],
        punchInTime: json['punchInTime'] != null
            ? DateTime.parse(json['punchInTime'])
            : null,
        punchOutTime: json['punchOutTime'] != null
            ? DateTime.parse(json['punchOutTime'])
            : null,
      );
}
