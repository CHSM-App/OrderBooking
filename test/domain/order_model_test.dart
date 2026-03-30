import 'package:flutter_test/flutter_test.dart';
import 'package:order_booking_app/domain/models/order_item.dart';
import 'package:order_booking_app/domain/models/orders.dart';

void main() {
  test('OrderItem totalPrice is derived from price * quantity', () {
    final item = OrderItem(
      productId: 10,
      subItemId: 4,
      productUnit: 'kg',
      price: 12.5,
      quantity: 3,
      totalPrice: 999, // should be ignored
    );

    expect(item.totalPrice, 37.5);
  });

  test('Order.fromJson normalizes legacy keys and fills product_unit', () {
    final order = Order.fromJson({
      'orderId': 123,
      'employeeId': 7,
      'shopId': 9,
      'shopName': 'Corner Shop',
      'employee_name': 'Jamie',
      'shop_address': '1 Market St',
      'orderDate': '2026-03-12',
      'totalPrice': 99.0,
      'companyId': 'ACME',
      'ownerName': 'Sam',
      'regionName': 'West',
      'mobileNo': '555-0000',
      'isDelivered': 1,
      'deliveredOn': '2026-03-12',
      'type': 2,
      'items': [
        {
          'product_id': 1,
          'sub_item_id': 2,
          'price': 10.0,
          'quantity': 2,
          // product_unit intentionally missing
        },
      ],
    });

    expect(order.serverOrderId, 123);
    expect(order.employeeId, 7);
    expect(order.shopId, 9);
    expect(order.shopNamep, 'Corner Shop');
    expect(order.empName, 'Jamie');
    expect(order.address, '1 Market St');
    expect(order.totalPrice, 99.0);
    expect(order.items.single.productUnit, '');
  });
}
