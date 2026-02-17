import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable(explicitToJson: true)
class Product {
  // ===== SERVER FIELDS =====
  @JsonKey(name: 'product_id')
  final int? productId;

  @JsonKey(name: 'product_name')
  final String? productName;

  @JsonKey(name: 'product_type')
  final String? productType;

  @JsonKey(name: 'created_by')
  final int? createdBy;

  @JsonKey(name: 'company_id')
  final String? companyId;

  @JsonKey(name: 'subtypes')
  final List<ProductSubType>? subtypes;

  // ===== OPTIONAL SERVER FIELDS =====
  @JsonKey(name: 'employee_id')
  final int? employeeId;

  @JsonKey(name: 'admin_id')
  final int? adminId;

  @JsonKey(name: 'total_price')
  final double? totalPrice;


  @JsonKey(name: 'item_total_price')
  final double? itemTotalPrice;

  final String? productUnit;
  final int? shopId;
  
  @JsonKey(name: 'order_date')
  final DateTime? orderDate;

  
  final double totalSales;
  final List<DateTime> orderDates;

  // ===== LOCAL DB ONLY =====
  @JsonKey(ignore: true)
  final String? localId; // local UUID

  @JsonKey(ignore: true)
  final bool isSynced;

  @JsonKey(ignore: true)
  final DateTime? updatedAt;

  Product({
    this.orderDate,
    this.itemTotalPrice,
    this.productId,
    this.productName,
    this.productType,
    this.createdBy,
    this.companyId,
    this.subtypes,
    this.employeeId,
    this.adminId,
    this.totalPrice,
    this.productUnit,
    this.shopId,
    this.localId,
    this.isSynced = false,
    this.updatedAt,
    this.totalSales = 0,
    this.orderDates = const [],
      
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    int? productId,
    String? productName,
    String? productType,
    int? createdBy,
    String? companyId,
    List<ProductSubType>? subtypes,
    int? employeeId,
    int? adminId,
    double? totalPrice,
    String? productUnit,
    int? shopId,
    String? localId,
    bool? isSynced,
    DateTime? updatedAt,
    DateTime? orderDate,
    double? itemTotalPrice
  }) {
    return Product(
      itemTotalPrice : itemTotalPrice ?? this.itemTotalPrice,
      orderDate: orderDate ?? this.orderDate,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      createdBy: createdBy ?? this.createdBy,
      companyId: companyId ?? this.companyId,
      subtypes: subtypes ?? this.subtypes,
      employeeId: employeeId ?? this.employeeId,
      adminId: adminId ?? this.adminId,
      totalPrice: totalPrice ?? this.totalPrice,
      productUnit: productUnit ?? this.productUnit,
      shopId: shopId ?? this.shopId,
      localId: localId ?? this.localId,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ProductSubType {
  // ===== SERVER FIELDS =====
  @JsonKey(name: 'sub_item_id')
  final int? subItemId;

  @JsonKey(name: 'measuring_unit')
  final String? measuringUnit;

  @JsonKey(name: 'available_unit')
  final double? availableUnit;

  @JsonKey(name: 'price')
  final double? price;

  // ===== LOCAL / UI ONLY =====
  @JsonKey(ignore: true)
  final int? total;

  @JsonKey(ignore: true)
  final String? localId; // local UUID

  @JsonKey(ignore: true)
  final String? productLocalId; // links to Product.localId for offline sync

  @JsonKey(ignore: true)
  final bool isSynced;

  ProductSubType({
    this.subItemId,
    this.measuringUnit,
    this.availableUnit,
    this.price,
    this.total,
    this.localId,
    this.productLocalId,
    this.isSynced = false,
  });

  factory ProductSubType.fromJson(Map<String, dynamic> json) =>
      _$ProductSubTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSubTypeToJson(this);

  ProductSubType copyWith({
    int? subItemId,
    String? measuringUnit,
    double? availableUnit,
    double? price,
    int? total,
    String? localId,
    String? productLocalId,
    bool? isSynced,
  }) {
    return ProductSubType(
      subItemId: subItemId ?? this.subItemId,
      measuringUnit: measuringUnit ?? this.measuringUnit,
      availableUnit: availableUnit ?? this.availableUnit,
      price: price ?? this.price,
      total: total ?? this.total,
      localId: localId ?? this.localId,
      productLocalId: productLocalId ?? this.productLocalId,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
