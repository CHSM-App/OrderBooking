import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:order_booking_app/domain/models/orders.dart';
class OrderPrintPreviewPage extends StatefulWidget {
  final Order order;
  final int orderNumber;

  const OrderPrintPreviewPage({
    super.key,
    required this.order,
    required this.orderNumber,
  });

  @override
  State<OrderPrintPreviewPage> createState() => _OrderPrintPreviewPageState();
}

class _OrderPrintPreviewPageState extends State<OrderPrintPreviewPage> {
  Uint8List? _cachedPdfBytes;
  late pw.Font _regularFont;
  late pw.Font _boldFont;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    // Load fonts ONCE
    _regularFont = await PdfGoogleFonts.nunitoRegular();
    _boldFont = await PdfGoogleFonts.nunitoBold();

    // Build PDF ONCE and cache the bytes
    _cachedPdfBytes = await _buildPdf(PdfPageFormat.a4);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: _regularFont,
          bold: _boldFont,
        ),
        build: (context) => [
          pw.Text(
            'Order #${widget.orderNumber}',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Shop: ${widget.order.shopNamep ?? "-"}'),
          pw.Text('Shop Owner Name: ${widget.order.ownerName ?? "-"}'),
          pw.Text('Shop Owner Phone: ${widget.order.mobileNo ?? "-"}'),
          pw.Text('Address: ${widget.order.address ?? "-"}'),
          pw.Text('Order taken by: ${widget.order.empName ?? "-"}'),
          pw.Text('Order Date/Time: ${widget.order.orderDate}'),
          pw.Text('Total items: ${widget.order.items.length}'),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Product', 'Qty', 'Unit', 'Price', 'Total'],
            data: widget.order.items.map((item) => [
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
              'Total: ${widget.order.totalPrice.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Preview')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              canDebug: false,
              // Return cached bytes directly — no rebuilding
              build: (_) async => _cachedPdfBytes!,
            ),
    );
  }
}

class MultiOrderPrintPreviewPage extends StatefulWidget {
  final List<Order> orders;
  final List<int> orderNumbers;

  const MultiOrderPrintPreviewPage({
    super.key,
    required this.orders,
    required this.orderNumbers,
  });

  @override
  State<MultiOrderPrintPreviewPage> createState() =>
      _MultiOrderPrintPreviewPageState();
}

class _MultiOrderPrintPreviewPageState
    extends State<MultiOrderPrintPreviewPage> {
  Uint8List? _cachedPdfBytes;
  late pw.Font _regularFont;
  late pw.Font _boldFont;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    _regularFont = await PdfGoogleFonts.nunitoRegular();
    _boldFont = await PdfGoogleFonts.nunitoBold();

    _cachedPdfBytes = await _buildPdf(PdfPageFormat.a4);

    if (mounted) setState(() => _isLoading = false);
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: _regularFont,
          bold: _boldFont,
        ),
        build: (context) {
          final widgets = <pw.Widget>[];
          for (int i = 0; i < widget.orders.length; i++) {
            final order = widget.orders[i];
            final orderNumber =
                i < widget.orderNumbers.length ? widget.orderNumbers[i] : 0;

            widgets.addAll([
              pw.Text(
                'Order #$orderNumber',
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Shop: ${order.shopNamep ?? "-"}'),
              pw.Text('Shop Owner Name: ${order.ownerName ?? "-"}'),
              pw.Text('Shop Owner Phone: ${order.mobileNo ?? "-"}'),
              pw.Text('Address: ${order.address ?? "-"}'),
              pw.Text('Order taken by: ${order.empName ?? "-"}'),
              pw.Text('Order Date/Time: ${order.orderDate}'),
              pw.Text('Total items: ${order.items.length}'),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Product', 'Qty', 'Unit', 'Price', 'Total'],
                data: order.items
                    .map((item) => [
                          item.productName ?? item.productId.toString(),
                          item.quantity.toString(),
                          item.productUnit,
                          item.price.toStringAsFixed(2),
                          item.totalPrice.toStringAsFixed(2),
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: ${order.totalPrice.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ]);

            if (i != widget.orders.length - 1) {
              widgets.add(pw.NewPage());
            }
          }
          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Preview')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              canDebug: false,
              build: (_) async => _cachedPdfBytes!,
            ),
    );
  }
}
