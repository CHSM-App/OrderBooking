import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:order_booking_app/domain/models/orders.dart';

class OrderPrintPreviewPage extends StatelessWidget {
  final Order order;
  final int orderNumber;

  const OrderPrintPreviewPage({
    super.key,
    required this.order,
    required this.orderNumber,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Preview'),
      ),
      body: PdfPreview(
        build: (PdfPageFormat format) async {
          final pdf = pw.Document();

          pdf.addPage(
            pw.MultiPage(
              pageFormat: format,
              margin: const pw.EdgeInsets.all(24),
              build: (context) => [
                

                pw.Text(
                  'Order #$orderNumber',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Shop: ${order.shopNamep ?? "-"}'),
                pw.Text('Address: ${order.address ?? "-"}'),
                pw.Text('Order taken by: ${order.empName ?? "-"}'),
                pw.Text('Order Date/Time: ${order.orderDate}'),
                pw.Text('Total items: ${order.items.length.toString()}'),

                pw.SizedBox(height: 16),

                pw.Table.fromTextArray(
                  headers: ['Product', 'Qty', 'Unit', 'Price', 'Total'],
                  data: order.items.map((item) => [
                    item.productName ?? item.productId.toString(),
                    item.quantity.toString(),
                    item.productUnit,
                    item.price.toStringAsFixed(2),
                    item.totalPrice.toStringAsFixed(2),
                  ]).toList(),
                ),

                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total: ${order.totalPrice.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );

          return pdf.save();
        },
      ),
    );
  }
}
