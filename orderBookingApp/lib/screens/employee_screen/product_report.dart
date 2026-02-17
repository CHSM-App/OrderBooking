import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:order_booking_app/domain/models/product_data.dart';
import 'package:order_booking_app/presentation/providers/usecase_provider.dart';
import 'package:order_booking_app/presentation/viewmodels/product_viewmodel.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

// ─────────────────────────────────────────────────────────────
//  PROVIDER
// ─────────────────────────────────────────────────────────────
final reportTabProvider =
    StateNotifierProvider<ProductViewModel, ProductState>(
  (ref) => ProductViewModel(ref.read(productUsecaseProvider)),
);

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
const _red        = Color(0xFFE53935);
const _redLight   = Color(0xFFFFEBEA);
const _redDark    = Color(0xFFC62828);
const _bg         = Color(0xFFF4F6FA);
const _white      = Color(0xFFFFFFFF);
const _textDark   = Color(0xFF1A1A2E);
const _textGrey   = Color(0xFF7A7A8A);
const _divLine    = Color(0xFFEEEEF2);
const _cardShadow = Color(0x14000000);

// ─────────────────────────────────────────────────────────────
//  AGGREGATION HELPERS
// ─────────────────────────────────────────────────────────────
class _Agg {
  final String name;
  double total;
  int orders;
  _Agg(this.name, this.total, this.orders);
}

class _EmpAgg extends _Agg {
  final List<_Agg> products;
  _EmpAgg(super.name, super.total, super.orders, this.products);
}

class _RegionAgg extends _Agg {
  final List<_EmpAgg> employees;
  final List<_Agg> products; // direct region → product aggregation
  _RegionAgg(super.name, super.total, super.orders, this.employees, this.products);
}

List<_Agg> _aggregateProducts(List<ProductData> raw) {
  final map = <String, double>{};
  final cnt = <String, int>{};
  for (final e in raw) {
    map[e.productName] = (map[e.productName] ?? 0) + (e.itemTotalPrice ?? 0);
    cnt[e.productName] = (cnt[e.productName] ?? 0) + 1;
  }
  return map.entries
      .map((e) => _Agg(e.key, e.value, cnt[e.key] ?? 0))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}

List<_EmpAgg> _aggregateEmployees(List<ProductData> raw) {
  final totals = <String, Map<String, double>>{};
  final counts = <String, Map<String, int>>{};
  for (final e in raw) {
    final emp  = e.emp_name ?? 'Unknown';
    final prod = e.productName;
    totals.putIfAbsent(emp, () => {})[prod] =
        (totals[emp]![prod] ?? 0) + (e.itemTotalPrice ?? 0);
    counts.putIfAbsent(emp, () => {})[prod] =
        (counts[emp]![prod] ?? 0) + 1;
  }
  return totals.entries.map((emp) {
    final prods = emp.value.entries
        .map((p) => _Agg(p.key, p.value, counts[emp.key]![p.key] ?? 0))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    final t = prods.fold(0.0, (s, p) => s + p.total);
    final o = prods.fold(0, (s, p) => s + p.orders);
    return _EmpAgg(emp.key, t, o, prods);
  }).toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}

List<_RegionAgg> _aggregateRegions(List<ProductData> raw) {
  final totals    = <String, Map<String, Map<String, double>>>{};
  final counts    = <String, Map<String, Map<String, int>>>{};
  final prodTotals = <String, Map<String, double>>{};
  final prodCounts = <String, Map<String, int>>{};

  for (final e in raw) {
    final r   = e.regionName ?? 'Unknown';
    final emp = e.emp_name ?? 'Unknown';
    final prd = e.productName;
    final amt = e.itemTotalPrice ?? 0;

    totals.putIfAbsent(r, () => {}).putIfAbsent(emp, () => {})[prd] =
        (totals[r]![emp]![prd] ?? 0) + amt;
    counts.putIfAbsent(r, () => {}).putIfAbsent(emp, () => {})[prd] =
        (counts[r]![emp]![prd] ?? 0) + 1;

    prodTotals.putIfAbsent(r, () => {})[prd] =
        (prodTotals[r]![prd] ?? 0) + amt;
    prodCounts.putIfAbsent(r, () => {})[prd] =
        (prodCounts[r]![prd] ?? 0) + 1;
  }

  return totals.entries.map((r) {
    final emps = r.value.entries.map((emp) {
      final prods = emp.value.entries
          .map((p) =>
              _Agg(p.key, p.value, counts[r.key]![emp.key]![p.key] ?? 0))
          .toList()
        ..sort((a, b) => b.total.compareTo(a.total));
      final t = prods.fold(0.0, (s, p) => s + p.total);
      final o = prods.fold(0, (s, p) => s + p.orders);
      return _EmpAgg(emp.key, t, o, prods);
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final regionProds = (prodTotals[r.key] ?? {}).entries
        .map((p) => _Agg(p.key, p.value, prodCounts[r.key]![p.key] ?? 0))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final t = emps.fold(0.0, (s, e) => s + e.total);
    final o = emps.fold(0, (s, e) => s + e.orders);
    return _RegionAgg(r.key, t, o, emps, regionProds);
  }).toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}

// ─────────────────────────────────────────────────────────────
//  PDF GENERATOR  ← UPDATED: separate pages per section
// ─────────────────────────────────────────────────────────────
class _PdfGenerator {
  static final _accentColor = PdfColor.fromHex('#E53935');
  static final _accentLight = PdfColor.fromHex('#FFEBEA');
  static final _green       = PdfColor.fromHex('#2ECC71');
  static final _blue        = PdfColor.fromHex('#6C8EFF');
  static final _blueLight   = PdfColor.fromHex('#EEF0FF');
  static final _orange      = PdfColor.fromHex('#F59E0B');
  static final _textDarkPdf = PdfColor.fromHex('#1A1A2E');
  static final _textGreyPdf = PdfColor.fromHex('#7A7A8A');
  static final _divLinePdf  = PdfColor.fromHex('#EEEEEE');
  static final _bgGrey      = PdfColor.fromHex('#F4F6FA');

  static String _fmtPdf(double v) {
    if (v >= 1e7) return '${(v / 1e7).toStringAsFixed(2)} Cr';
    if (v >= 1e5) return '${(v / 1e5).toStringAsFixed(2)} L';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)} K';
    return v.toStringAsFixed(0);
  }

  static Future<File> generate({
    required List<ProductData> data,
    required String companyId,
    required DateTime? startDate,
    required DateTime? endDate,
    required int activeTabIndex,
  }) async {
    final pdf = pw.Document();

    final products  = _aggregateProducts(data);
    final employees = _aggregateEmployees(data);
    final regions   = _aggregateRegions(data);

    final grandTotal  = products.fold(0.0, (s, p) => s + p.total);
    final totalOrders = data.length;
    final dateStr     = _buildDateStr(startDate, endDate);

    // ══════════════════════════════════════════════════════════
    //  PAGE 1 — Cover / Summary
    // ══════════════════════════════════════════════════════════
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Red gradient header
            pw.Container(
              height: 150,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [_accentColor, PdfColor.fromHex('#C62828')],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 40, vertical: 30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Sales Report',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Company: ${data.first.companyName}',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                  ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                    'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                  ),
                  if (dateStr.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text('Period: $dateStr',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  ],
                ],
              ),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // KPI row
                  pw.Row(
                    children: [
                      _kpiBox('Total Revenue', 'Rs. ${_fmtPdf(grandTotal)}', _green),
                      pw.SizedBox(width: 14),
                      _kpiBox('Total Orders', totalOrders.toString(), _accentColor),
                      pw.SizedBox(width: 14),
                      _kpiBox('Products', products.length.toString(), _orange),
                      pw.SizedBox(width: 14),
                      _kpiBox('Employees', employees.length.toString(), _blue),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  // Table of contents / index
                  _sectionHeader('Report Index', _accentColor),
                  pw.SizedBox(height: 12),
                  _indexTable(regions.isNotEmpty, employees.isNotEmpty),

                  pw.SizedBox(height: 30),

                  // Mini summary stats
                  _sectionHeader('Quick Summary', _textGreyPdf),
                  pw.SizedBox(height: 12),
                  _summaryGrid(products, employees, regions, grandTotal),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // ══════════════════════════════════════════════════════════
    //  PAGE 2 — Product Wise 
    // ══════════════════════════════════════════════════════════
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _multiPageHeader(
          'Product Wise Report',
          dateStr,
          _accentColor,
          Icons.inventory_2_outlined,
        ),
        footer: (ctx) => _pageFooter(ctx, 'Product Wise'),
        build: (ctx) => [
          pw.SizedBox(height: 16),

          // Product KPIs
          pw.Row(
            children: [
              _kpiBox('Total Products', products.length.toString(), _accentColor),
              pw.SizedBox(width: 14),
              _kpiBox('Total Orders', totalOrders.toString(), _orange),
              pw.SizedBox(width: 14),
              _kpiBox('Total Revenue', 'Rs. ${_fmtPdf(grandTotal)}', _green),
            ],
          ),
          pw.SizedBox(height: 20),

          _sectionHeader('Product Performance', _accentColor),
          pw.SizedBox(height: 10),

          // Full product table
          _productTableFull(products, grandTotal),
        ],
      ),
    );

    // ══════════════════════════════════════════════════════════
    //  PAGE 3 — Region Wise
    // ══════════════════════════════════════════════════════════
    if (regions.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (ctx) => _multiPageHeader(
            'Region Wise Report',
            dateStr,
            _accentColor,
            Icons.location_on_outlined,
          ),
          footer: (ctx) => _pageFooter(ctx, 'Region Wise'),
          build: (ctx) => [
            pw.SizedBox(height: 16),

            // Region KPIs
            pw.Row(
              children: [
                _kpiBox('Total Regions', regions.length.toString(), _accentColor),
                pw.SizedBox(width: 14),
                _kpiBox('Total Orders', totalOrders.toString(), _orange),
                pw.SizedBox(width: 14),
                _kpiBox('Total Revenue', 'Rs. ${_fmtPdf(grandTotal)}', _green),
              ],
            ),
            pw.SizedBox(height: 20),

            _sectionHeader('Region Breakdown', _accentColor),
            pw.SizedBox(height: 10),

            // Region summary table
            _regionSummaryTable(regions, grandTotal),
            pw.SizedBox(height: 24),

            _sectionHeader('Region Detail (with Products)', _textGreyPdf),
            pw.SizedBox(height: 10),

            // Detailed region blocks
            ...regions.map((r) => _regionDetailBlock(r, grandTotal)),
          ],
        ),
      );
    }

    // ══════════════════════════════════════════════════════════
    //  PAGE 4 — Employee Wise 
    // ══════════════════════════════════════════════════════════
    if (employees.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (ctx) => _multiPageHeader(
            'Employee Wise Report',
            dateStr,
            _blue,
            Icons.person_outline,
          ),
          footer: (ctx) => _pageFooter(ctx, 'Employee Wise'),
          build: (ctx) => [
            pw.SizedBox(height: 16),

            // Employee KPIs
            pw.Row(
              children: [
                _kpiBox('Total Employees', employees.length.toString(), _blue),
                pw.SizedBox(width: 14),
                _kpiBox('Total Orders', totalOrders.toString(), _orange),
                pw.SizedBox(width: 14),
                _kpiBox('Total Revenue', 'Rs. ${_fmtPdf(grandTotal)}', _green),
              ],
            ),
            pw.SizedBox(height: 20),

            _sectionHeader('Employee Summary', _blue),
            pw.SizedBox(height: 10),

            // Employee summary table
            _employeeTableFull(employees),
            pw.SizedBox(height: 24),

            _sectionHeader('Employee Detail (with Products)', _textGreyPdf),
            pw.SizedBox(height: 10),

            // Detailed employee blocks
            ...employees.map((e) => _employeeDetailBlock(e)),
          ],
        ),
      );
    }

    // ── Save ──────────────────────────────────────────────────
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ────────────────────────────────────────────────────────────
  //  SHARED WIDGETS
  // ────────────────────────────────────────────────────────────

  /// KPI Box
  static pw.Widget _kpiBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: PdfColor.fromHex('#EEEEEE')),
          boxShadow: [
            pw.BoxShadow(
                color: PdfColor.fromHex('#1A000000'),
                blurRadius: 6,
                offset: const PdfPoint(0, 2)),
          ],
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    color: color, fontSize: 15, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 3),
            pw.Text(label,
                style: pw.TextStyle(color: _textGreyPdf, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  /// Section header with left border
  static pw.Widget _sectionHeader(String title, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(width: 4, height: 18, color: color),
        pw.SizedBox(width: 8),
        pw.Text(title,
            style: pw.TextStyle(
                color: _textDarkPdf,
                fontSize: 13,
                fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  /// MultiPage header (appears on every page of that section)
  static pw.Widget _multiPageHeader(
      String title, String dateStr, PdfColor color, IconData _) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 24,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(title,
                  style: pw.TextStyle(
                      color: _textDarkPdf,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Text(dateStr,
              style: pw.TextStyle(color: _textGreyPdf, fontSize: 9)),
        ],
      ),
    );
  }

  /// Footer with page number
  static pw.Widget _pageFooter(pw.Context ctx, String section) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            top: pw.BorderSide(color: PdfColor.fromHex('#EEEEEE'))),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(section,
              style: pw.TextStyle(color: _textGreyPdf, fontSize: 8)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(color: _textGreyPdf, fontSize: 8)),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  PAGE 1 — Index Table & Summary Grid
  // ────────────────────────────────────────────────────────────
  static pw.Widget _indexTable(bool hasRegions, bool hasEmployees) {
    final rows = <Map<String, String>>[
      {'page': 'Page 2', 'section': 'Product Wise Report', 'desc': 'All products sorted by revenue'},
      if (hasRegions)
        {'page': 'Page 3', 'section': 'Region Wise Report', 'desc': 'Region breakdown with employee details'},
      if (hasEmployees)
        {'page': hasRegions ? 'Page 4' : 'Page 3', 'section': 'Employee Wise Report', 'desc': 'Employee performance with product breakdown'},
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _divLinePdf, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(3.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _accentColor),
          children: [
            _cell('Page', pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            _cell('Section', pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            _cell('Description', pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        ...rows.asMap().entries.map((e) => pw.TableRow(
          decoration: pw.BoxDecoration(
              color: e.key % 2 == 0 ? PdfColors.white : _bgGrey),
          children: [
            _cell(e.value['page']!, pw.TextStyle(color: _accentColor, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            _cell(e.value['section']!, pw.TextStyle(color: _textDarkPdf, fontSize: 9)),
            _cell(e.value['desc']!, pw.TextStyle(color: _textGreyPdf, fontSize: 9)),
          ],
        )),
      ],
    );
  }

  static pw.Widget _summaryGrid(
    List<_Agg> products,
    List<_EmpAgg> employees,
    List<_RegionAgg> regions,
    double grandTotal,
  ) {
    // Top 3 products
    final top3 = products.take(3).toList();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Top Products',
                  style: pw.TextStyle(
                      color: _textDarkPdf,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...top3.asMap().entries.map((e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      children: [
                        pw.Text('${e.key + 1}. ',
                            style: pw.TextStyle(
                                color: _accentColor, fontSize: 9,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Expanded(
                          child: pw.Text(e.value.name,
                              style: pw.TextStyle(
                                  color: _textDarkPdf, fontSize: 9)),
                        ),
                        pw.Text('Rs. ${_fmtPdf(e.value.total)}',
                            style: pw.TextStyle(
                                color: _green, fontSize: 9,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Container(width: 1, height: 80, color: _divLinePdf),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Top Employees',
                  style: pw.TextStyle(
                      color: _textDarkPdf,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              ...employees.take(3).toList().asMap().entries.map((e) =>
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      children: [
                        pw.Text('${e.key + 1}. ',
                            style: pw.TextStyle(
                                color: _blue, fontSize: 9,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Expanded(
                          child: pw.Text(e.value.name,
                              style: pw.TextStyle(
                                  color: _textDarkPdf, fontSize: 9)),
                        ),
                        pw.Text('Rs. ${_fmtPdf(e.value.total)}',
                            style: pw.TextStyle(
                                color: _green, fontSize: 9,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  //  PAGE 2 — Full Product Table
  // ────────────────────────────────────────────────────────────
  static pw.Widget _productTableFull(List<_Agg> items, double grand) {
    final headerStyle = pw.TextStyle(
        color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final rowStyle = pw.TextStyle(color: _textDarkPdf, fontSize: 9);
    final greyStyle = pw.TextStyle(color: _textGreyPdf, fontSize: 9);

    return pw.Table(
      border: pw.TableBorder.all(color: _divLinePdf, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(3.5),
        2: const pw.FlexColumnWidth(1.8),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _accentColor),
          children: [
            _cell('#', headerStyle),
            _cell('Product Name', headerStyle),
            _cell('Revenue', headerStyle, align: pw.TextAlign.right),
            _cell('Orders', headerStyle, align: pw.TextAlign.center),
            _cell('Share %', headerStyle, align: pw.TextAlign.right),
          ],
        ),
        ...items.asMap().entries.map((e) {
          final isEven = e.key % 2 == 0;
          final pct = grand > 0 ? e.value.total / grand * 100 : 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: isEven ? PdfColors.white : _bgGrey),
            children: [
              _cell('${e.key + 1}', greyStyle, align: pw.TextAlign.center),
              _cell(e.value.name, rowStyle),
              _cell('Rs. ${_fmtPdf(e.value.total)}', rowStyle,
                  align: pw.TextAlign.right),
              _cell(e.value.orders.toString(), rowStyle,
                  align: pw.TextAlign.center),
              _cell('${pct.toStringAsFixed(1)}%', greyStyle,
                  align: pw.TextAlign.right),
            ],
          );
        }),
        // Total row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F8F1')),
          children: [
            _cell('', pw.TextStyle(fontSize: 9)),
            _cell('TOTAL', pw.TextStyle(
                color: _textDarkPdf, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            _cell('Rs. ${_fmtPdf(grand)}', pw.TextStyle(
                color: _green, fontSize: 9, fontWeight: pw.FontWeight.bold),
                align: pw.TextAlign.right),
            _cell(items.fold(0, (s, i) => s + i.orders).toString(),
                pw.TextStyle(color: _textDarkPdf, fontSize: 9, fontWeight: pw.FontWeight.bold),
                align: pw.TextAlign.center),
            _cell('100%', pw.TextStyle(
                color: _textGreyPdf, fontSize: 9), align: pw.TextAlign.right),
          ],
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  //  PAGE 3 — Region Summary Table + Detail Blocks
  // ────────────────────────────────────────────────────────────
  static pw.Widget _regionSummaryTable(
      List<_RegionAgg> regions, double grand) {
    final headerStyle = pw.TextStyle(
        color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final rowStyle = pw.TextStyle(color: _textDarkPdf, fontSize: 9);
    final greyStyle = pw.TextStyle(color: _textGreyPdf, fontSize: 9);

    return pw.Table(
      border: pw.TableBorder.all(color: _divLinePdf, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.8),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _accentColor),
          children: [
            _cell('#', headerStyle),
            _cell('Region', headerStyle),
            _cell('Revenue', headerStyle, align: pw.TextAlign.right),
            _cell('Orders', headerStyle, align: pw.TextAlign.center),
            _cell('Products', headerStyle, align: pw.TextAlign.center),
            _cell('Share %', headerStyle, align: pw.TextAlign.right),
          ],
        ),
        ...regions.asMap().entries.map((e) {
          final isEven = e.key % 2 == 0;
          final pct = grand > 0 ? e.value.total / grand * 100 : 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: isEven ? PdfColors.white : _bgGrey),
            children: [
              _cell('${e.key + 1}', greyStyle, align: pw.TextAlign.center),
              _cell(e.value.name, rowStyle),
              _cell('Rs. ${_fmtPdf(e.value.total)}', rowStyle,
                  align: pw.TextAlign.right),
              _cell(e.value.orders.toString(), rowStyle,
                  align: pw.TextAlign.center),
              _cell(e.value.products.length.toString(), greyStyle,
                  align: pw.TextAlign.center),
              _cell('${pct.toStringAsFixed(1)}%', greyStyle,
                  align: pw.TextAlign.right),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _regionDetailBlock(_RegionAgg r, double grand) {
    final pct = grand > 0 ? r.total / grand * 100 : 0;
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divLinePdf),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Region header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _accentLight,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(r.name,
                    style: pw.TextStyle(
                        color: _textDarkPdf,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  'Rs. ${_fmtPdf(r.total)}  |  ${r.orders} orders  |  ${pct.toStringAsFixed(1)}%',
                  style: pw.TextStyle(color: _accentColor, fontSize: 9),
                ),
              ],
            ),
          ),
          // Product rows (same style as employee detail block)
          ...r.products.asMap().entries.map((entry) {
            final p = entry.value;
            final prodPct = r.total > 0 ? p.total / r.total * 100 : 0;
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: entry.key % 2 == 0 ? PdfColors.white : _bgGrey,
                border: pw.Border(
                    bottom: pw.BorderSide(color: _divLinePdf, width: 0.5)),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 5,
                    height: 5,
                    decoration: pw.BoxDecoration(
                      color: _accentColor,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(p.name,
                        style: pw.TextStyle(color: _textDarkPdf, fontSize: 9)),
                  ),
                  pw.Text('${p.orders} orders',
                      style: pw.TextStyle(color: _textGreyPdf, fontSize: 8)),
                  pw.SizedBox(width: 12),
                  pw.Text('${prodPct.toStringAsFixed(1)}%',
                      style: pw.TextStyle(color: _textGreyPdf, fontSize: 8)),
                  pw.SizedBox(width: 12),
                  pw.Text('Rs. ${_fmtPdf(p.total)}',
                      style: pw.TextStyle(
                          color: _accentColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  PAGE 4 — Employee Summary Table + Detail Blocks
  // ────────────────────────────────────────────────────────────
  static pw.Widget _employeeTableFull(List<_EmpAgg> emps) {
    final headerStyle = pw.TextStyle(
        color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final rowStyle = pw.TextStyle(color: _textDarkPdf, fontSize: 9);
    final greyStyle = pw.TextStyle(color: _textGreyPdf, fontSize: 9);

    final grand = emps.fold(0.0, (s, e) => s + e.total);

    return pw.Table(
      border: pw.TableBorder.all(color: _divLinePdf, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.8),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _blue),
          children: [
            _cell('#', headerStyle),
            _cell('Employee', headerStyle),
            _cell('Revenue', headerStyle, align: pw.TextAlign.right),
            _cell('Orders', headerStyle, align: pw.TextAlign.center),
            _cell('Products', headerStyle, align: pw.TextAlign.center),
            _cell('Share %', headerStyle, align: pw.TextAlign.right),
          ],
        ),
        ...emps.asMap().entries.map((e) {
          final isEven = e.key % 2 == 0;
          final pct = grand > 0 ? e.value.total / grand * 100 : 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: isEven ? PdfColors.white : _bgGrey),
            children: [
              _cell('${e.key + 1}', greyStyle, align: pw.TextAlign.center),
              _cell(e.value.name, rowStyle),
              _cell('Rs. ${_fmtPdf(e.value.total)}', rowStyle,
                  align: pw.TextAlign.right),
              _cell(e.value.orders.toString(), rowStyle,
                  align: pw.TextAlign.center),
              _cell(e.value.products.length.toString(), greyStyle,
                  align: pw.TextAlign.center),
              _cell('${pct.toStringAsFixed(1)}%', greyStyle,
                  align: pw.TextAlign.right),
            ],
          );
        }),
        // Total row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F8F1')),
          children: [
            _cell('', pw.TextStyle(fontSize: 9)),
            _cell('TOTAL', pw.TextStyle(
                color: _textDarkPdf, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            _cell('Rs. ${_fmtPdf(grand)}', pw.TextStyle(
                color: _green, fontSize: 9, fontWeight: pw.FontWeight.bold),
                align: pw.TextAlign.right),
            _cell(emps.fold(0, (s, e) => s + e.orders).toString(),
                pw.TextStyle(color: _textDarkPdf, fontSize: 9, fontWeight: pw.FontWeight.bold),
                align: pw.TextAlign.center),
            _cell('', pw.TextStyle(fontSize: 9)),
            _cell('100%', pw.TextStyle(
                color: _textGreyPdf, fontSize: 9), align: pw.TextAlign.right),
          ],
        ),
      ],
    );
  }

  static pw.Widget _employeeDetailBlock(_EmpAgg emp) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _divLinePdf),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Employee header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _blueLight,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 24,
                      height: 24,
                      decoration: pw.BoxDecoration(
                        color: _blue,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                          emp.name.isNotEmpty
                              ? emp.name[0].toUpperCase()
                              : '?',
                          style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(emp.name,
                        style: pw.TextStyle(
                            color: _textDarkPdf,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Text(
                  'Rs. ${_fmtPdf(emp.total)}  |  ${emp.orders} orders  |  ${emp.products.length} products',
                  style: pw.TextStyle(color: _blue, fontSize: 9),
                ),
              ],
            ),
          ),
          // Product rows
          ...emp.products.asMap().entries.map((entry) {
            final p = entry.value;
            final pct = emp.total > 0 ? p.total / emp.total * 100 : 0;
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: entry.key % 2 == 0 ? PdfColors.white : _bgGrey,
                border: pw.Border(
                    bottom: pw.BorderSide(color: _divLinePdf, width: 0.5)),
              ),
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 5,
                    height: 5,
                    decoration: pw.BoxDecoration(
                      color: _accentColor,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(p.name,
                        style:
                            pw.TextStyle(color: _textDarkPdf, fontSize: 9)),
                  ),
                  pw.Text('${p.orders} orders',
                      style: pw.TextStyle(color: _textGreyPdf, fontSize: 8)),
                  pw.SizedBox(width: 12),
                  pw.Text('${pct.toStringAsFixed(1)}%',
                      style: pw.TextStyle(color: _textGreyPdf, fontSize: 8)),
                  pw.SizedBox(width: 12),
                  pw.Text('Rs. ${_fmtPdf(p.total)}',
                      style: pw.TextStyle(
                          color: _accentColor,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Table cell helper ──────────────────────────────────────
  static pw.Widget _cell(String text, pw.TextStyle style,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text, style: style, textAlign: align),
    );
  }

  static String _buildDateStr(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'All time';
    final fmt = DateFormat('dd MMM yyyy');
    if (start != null && end != null) {
      return '${fmt.format(start)} – ${fmt.format(end)}';
    }
    if (start != null) return 'From ${fmt.format(start)}';
    return 'Up to ${fmt.format(end!)}';
  }
}

// ─────────────────────────────────────────────────────────────
//  MAIN REPORT PAGE
// ─────────────────────────────────────────────────────────────
class ReportPage extends ConsumerStatefulWidget {
  final String companyId;
  const ReportPage({super.key, required this.companyId});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _pdfLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(reportTabProvider.notifier)
          .getProductReport(widget.companyId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<ProductData> _filter(List<ProductData> raw) {
    if (_startDate == null && _endDate == null) return raw;
    return raw.where((e) {
      final d = DateTime(
          e.orderDate.year, e.orderDate.month, e.orderDate.day);
      if (_startDate != null && d.isBefore(_startDate!)) return false;
      if (_endDate != null && d.isAfter(_endDate!)) return false;
      return true;
    }).toList();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _red,
            onPrimary: _white,
            surface: _white,
            onSurface: _textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = null;
        }
      }
    });
  }

  void _clearFilter() => setState(() {
        _startDate = null;
        _endDate = null;
      });

  String _fmt(DateTime? d) =>
      d == null ? 'Select date' : DateFormat('dd MMM yyyy').format(d);

  Future<void> _downloadPdf(List<ProductData> filtered) async {
    if (_pdfLoading) return;
    setState(() => _pdfLoading = true);

    try {
      final file = await _PdfGenerator.generate(
        data: filtered,
        companyId: widget.companyId,
        startDate: _startDate,
        endDate: _endDate,
        activeTabIndex: _tabCtrl.index,
      );

      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        backgroundColor: _white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _PdfBottomSheet(file: file),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportTabProvider);
    final hasFilter = _startDate != null || _endDate != null;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _Header(
            companyId: widget.companyId,
            pdfLoading: _pdfLoading,
            onDownload: () {
              final s = state.productReport;
              if (s == null) return;
              s.whenData((rawList) => _downloadPdf(_filter(rawList)));
            },
          ),
          _DateFilterCard(
            startDate: _startDate,
            endDate: _endDate,
            hasFilter: hasFilter,
            fmtStart: _fmt(_startDate),
            fmtEnd: _fmt(_endDate),
            onPickStart: () => _pickDate(isStart: true),
            onPickEnd: () => _pickDate(isStart: false),
            onClear: _clearFilter,
          ),
          _TabBar(controller: _tabCtrl),
          Expanded(
            child: state.productReport == null
                ? _emptyView()
                : state.productReport!.when(
                    loading: () => _loadingView(),
                    error: (e, _) => _errorView(e.toString()),
                    data: (rawList) {
                      final filtered = _filter(rawList);
                      return TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _ProductTab(
                              data: filtered,
                              hasFilter: hasFilter,
                              onClear: _clearFilter),
                          _RegionTab(
                              data: filtered,
                              hasFilter: hasFilter,
                              onClear: _clearFilter),
                          _EmployeeTab(
                              data: filtered,
                              hasFilter: hasFilter,
                              onClear: _clearFilter),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _loadingView() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _red, strokeWidth: 2.5),
            SizedBox(height: 14),
            Text('Loading report…',
                style: TextStyle(color: _textGrey, fontSize: 13)),
          ],
        ),
      );

  Widget _errorView(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                    color: _redLight, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded,
                    color: _red, size: 34),
              ),
              const SizedBox(height: 14),
              const Text('Something went wrong',
                  style: TextStyle(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textGrey, fontSize: 12)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: _white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () => ref
                    .read(reportTabProvider.notifier)
                    .getProductReport(widget.companyId),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );

  Widget _emptyView() => const Center(
        child: Text('No data',
            style: TextStyle(color: _textGrey, fontSize: 14)));
}

// ─────────────────────────────────────────────────────────────
//  PDF DOWNLOAD BOTTOM SHEET
// ─────────────────────────────────────────────────────────────
class _PdfBottomSheet extends StatelessWidget {
  final File file;
  const _PdfBottomSheet({required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _divLine,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _redLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded,
                color: _red, size: 36),
          ),
          const SizedBox(height: 14),
          const Text('Report Ready!',
              style: TextStyle(
                  color: _textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),

          // Show page structure info
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                _PageBadge('Page 1', 'Summary & Index', Color(0xFF2ECC71)),
                _PageBadge('Page 2', 'Product Wise', _red),
                _PageBadge('Page 3', 'Region Wise', _red),
                _PageBadge('Page 4', 'Employee Wise', Color(0xFF6C8EFF)),
              ],
            ),
          ),

          Text(
            file.path.split('/').last,
            style: const TextStyle(color: _textGrey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: _white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(file.path);
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open PDF',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _red,
                side: BorderSide(color: _red.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                share_plus.Share.shareXFiles(
                    [share_plus.XFile(file.path)],
                    subject: 'Sales Report');
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// Small page badge widget for bottom sheet
class _PageBadge extends StatelessWidget {
  final String page;
  final String label;
  final Color color;
  const _PageBadge(this.page, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(page,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Text(label,
              style:
                  const TextStyle(color: _textDark, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  RED HEADER
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String companyId;
  final bool pdfLoading;
  final VoidCallback onDownload;

  const _Header({
    required this.companyId,
    required this.pdfLoading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_red, _redDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 18,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _white, size: 18),
              onPressed: () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reports',
                      style: TextStyle(
                          color: _white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  Text('Product • Region • Employee',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            GestureDetector(
              onTap: pdfLoading ? null : onDownload,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    pdfLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: _white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded,
                            color: _white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      pdfLoading ? 'Generating…' : 'Download',
                      style: const TextStyle(
                          color: _white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────
//  DATE FILTER CARD
// ─────────────────────────────────────────────────────────────
class _DateFilterCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool hasFilter;
  final String fmtStart;
  final String fmtEnd;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onClear;

  const _DateFilterCard({
    required this.startDate,
    required this.endDate,
    required this.hasFilter,
    required this.fmtStart,
    required this.fmtEnd,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _cardShadow,
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
          border:
              hasFilter ? Border.all(color: _red.withOpacity(0.3)) : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _redLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.date_range_rounded,
                      color: _red, size: 14),
                ),
                const SizedBox(width: 8),
                const Text('Date Filter',
                    style: TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                if (hasFilter) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _redLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Clear',
                          style: TextStyle(
                              color: _red,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DatePill(
                    label: 'From',
                    value: fmtStart,
                    selected: startDate != null,
                    onTap: onPickStart,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: _textGrey.withOpacity(0.5), size: 16),
                ),
                Expanded(
                  child: _DatePill(
                    label: 'To',
                    value: fmtEnd,
                    selected: endDate != null,
                    onTap: onPickEnd,
                  ),
                ),
              ],
            ),
            if (hasFilter) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _redLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.filter_alt_rounded,
                        color: _red, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      '$fmtStart  →  $fmtEnd',
                      style: const TextStyle(
                          color: _red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}

class _DatePill extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _DatePill(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? _redLight : _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? _red.withOpacity(0.4) : _divLine),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: selected ? _red : _textGrey, size: 13),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: selected ? _red : _textGrey,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                    Text(value,
                        style: TextStyle(
                            color: selected ? _textDark : _textGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
//  TAB BAR
// ─────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        height: 44,
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(11),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(3),
          labelColor: _white,
          unselectedLabelColor: _textGrey,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 13),
                  SizedBox(width: 5),
                  Text('Product'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 13),
                  SizedBox(width: 5),
                  Text('Region'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline_rounded, size: 13),
                  SizedBox(width: 5),
                  Text('Employee'),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────
//  TAB 1: PRODUCT WISE
// ─────────────────────────────────────────────────────────────
class _ProductTab extends StatelessWidget {
  final List<ProductData> data;
  final bool hasFilter;
  final VoidCallback onClear;
  const _ProductTab(
      {required this.data,
      required this.hasFilter,
      required this.onClear});

  @override
  Widget build(BuildContext context) {
    final items = _aggregateProducts(data);
    final grand = items.fold(0.0, (s, i) => s + i.total);

    if (items.isEmpty) return _noData(hasFilter, onClear);

    return Column(
      children: [
        _SummaryRow(
          items: [
            _SumItem(Icons.inventory_2_outlined, 'Products',
                items.length.toString(), _red),
            _SumItem(Icons.receipt_long_outlined, 'Orders',
                data.length.toString(), _textGrey),
            _SumItem(Icons.currency_rupee_rounded, 'Total',
                '₹${_fmt(grand)}', const Color(0xFF2ECC71)),
          ],
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ProductCard(
              item: items[i],
              index: i,
              grand: grand,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _Agg item;
  final int index;
  final double grand;
  const _ProductCard(
      {required this.item, required this.index, required this.grand});

  static const _rankColors = [
    Color(0xFFF59E0B),
    Color(0xFF94A3B8),
    Color(0xFFCD7F32),
  ];

  @override
  Widget build(BuildContext context) {
    final pct   = grand > 0 ? item.total / grand : 0.0;
    final isTop = index < 3;
    final rankColor =
        isTop ? _rankColors[index] : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: _cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
        border: isTop
            ? Border.all(color: rankColor.withOpacity(0.25))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: isTop
                    ? Icon(_rankIcon(index), color: rankColor, size: 16)
                    : Text('#${index + 1}',
                        style: TextStyle(
                            color: rankColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            color: _textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('${item.orders} orders',
                        style: const TextStyle(
                            color: _textGrey, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '₹${_fmt(item.total)}',
                  style: const TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: 13,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: Duration(milliseconds: 600 + index * 40),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 5,
                backgroundColor: _divLine,
                valueColor:
                    AlwaysStoppedAnimation(isTop ? rankColor : _red),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${(pct * 100).toStringAsFixed(1)}% of total sales',
            style: const TextStyle(color: _textGrey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  IconData _rankIcon(int r) {
    switch (r) {
      case 0:
        return Icons.emoji_events_rounded;
      case 1:
        return Icons.military_tech_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 2: REGION WISE
// ─────────────────────────────────────────────────────────────
class _RegionTab extends StatelessWidget {
  final List<ProductData> data;
  final bool hasFilter;
  final VoidCallback onClear;
  const _RegionTab(
      {required this.data,
      required this.hasFilter,
      required this.onClear});

  @override
  Widget build(BuildContext context) {
    final regions = _aggregateRegions(data);
    final grand   = regions.fold(0.0, (s, r) => s + r.total);

    if (regions.isEmpty) return _noData(hasFilter, onClear);

    return Column(
      children: [
        _SummaryRow(items: [
          _SumItem(Icons.map_outlined, 'Regions',
              regions.length.toString(), _red),
          _SumItem(Icons.receipt_long_outlined, 'Orders',
              data.length.toString(), _textGrey),
          _SumItem(Icons.currency_rupee_rounded, 'Total',
              '₹${_fmt(grand)}', const Color(0xFF2ECC71)),
        ]),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: regions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _RegionProductCard(
              region: regions[i],
              grand: grand,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  REGION → PRODUCT CARD  (tap to expand products)
// ─────────────────────────────────────────────────────────────
class _RegionProductCard extends StatefulWidget {
  final _RegionAgg region;
  final double grand;
  const _RegionProductCard({required this.region, required this.grand});

  @override
  State<_RegionProductCard> createState() => _RegionProductCardState();
}

class _RegionProductCardState extends State<_RegionProductCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final pct = widget.grand > 0 ? widget.region.total / widget.grand : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          // ── Region header (tappable) ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _redLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.location_on_rounded,
                              color: _red, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.region.name,
                                  style: const TextStyle(
                                      color: _textDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${widget.region.products.length} products  •  ${widget.region.orders} orders',
                                style: const TextStyle(
                                    color: _textGrey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '₹${_fmt(widget.region.total)}',
                            style: const TextStyle(
                                color: Color(0xFF2ECC71),
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: _textGrey, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOut,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 5,
                          backgroundColor: _divLine,
                          valueColor: const AlwaysStoppedAnimation(_red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}% of total',
                      style: const TextStyle(color: _textGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Products list (animated expand) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: _expanded
                ? Container(
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: _divLine))),
                    child: Column(
                      children: widget.region.products
                          .asMap()
                          .entries
                          .map((e) => _ProductLeafRow(
                                product: e.value,
                                empTotal: widget.region.total,
                                isLast:
                                    e.key == widget.region.products.length - 1,
                              ))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 3: EMPLOYEE WISE
// ─────────────────────────────────────────────────────────────
class _EmployeeTab extends StatelessWidget {
  final List<ProductData> data;
  final bool hasFilter;
  final VoidCallback onClear;
  const _EmployeeTab(
      {required this.data,
      required this.hasFilter,
      required this.onClear});

  @override
  Widget build(BuildContext context) {
    final emps  = _aggregateEmployees(data);
    final grand = emps.fold(0.0, (s, e) => s + e.total);

    if (emps.isEmpty) return _noData(hasFilter, onClear);

    return Column(
      children: [
        _SummaryRow(items: [
          _SumItem(Icons.people_outline_rounded, 'Employees',
              emps.length.toString(), _red),
          _SumItem(Icons.receipt_long_outlined, 'Orders',
              data.length.toString(), _textGrey),
          _SumItem(Icons.currency_rupee_rounded, 'Total',
              '₹${_fmt(grand)}', const Color(0xFF2ECC71)),
        ]),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: emps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _EmpProductCard(
              emp: emps[i],
              grand: grand,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EMPLOYEE → PRODUCT CARD  (tap to expand products)
// ─────────────────────────────────────────────────────────────
class _EmpProductCard extends StatefulWidget {
  final _EmpAgg emp;
  final double grand;
  const _EmpProductCard({required this.emp, required this.grand});

  @override
  State<_EmpProductCard> createState() => _EmpProductCardState();
}

class _EmpProductCardState extends State<_EmpProductCard> {
  bool _expanded = false;

  static const _blue = Color(0xFF6C8EFF);
  static const _blueLight = Color(0xFFEEF0FF);

  @override
  Widget build(BuildContext context) {
    final pct = widget.grand > 0 ? widget.emp.total / widget.grand : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          // ── Employee header (tappable) ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: _blue.withOpacity(0.13),
                          child: Text(
                            widget.emp.name.isNotEmpty
                                ? widget.emp.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: _blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.emp.name,
                                  style: const TextStyle(
                                      color: _textDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${widget.emp.products.length} products  •  ${widget.emp.orders} orders',
                                style: const TextStyle(
                                    color: _textGrey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '₹${_fmt(widget.emp.total)}',
                            style: const TextStyle(
                                color: Color(0xFF2ECC71),
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: _textGrey, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOut,
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v,
                          minHeight: 5,
                          backgroundColor: _divLine,
                          valueColor: const AlwaysStoppedAnimation(_blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}% of total',
                      style: const TextStyle(color: _textGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Products list (animated expand) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: _expanded
                ? Container(
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: _divLine))),
                    child: Column(
                      children: widget.emp.products
                          .asMap()
                          .entries
                          .map((e) => _ProductLeafRow(
                                product: e.value,
                                empTotal: widget.emp.total,
                                isLast:
                                    e.key == widget.emp.products.length - 1,
                              ))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PRODUCT LEAF ROW
// ─────────────────────────────────────────────────────────────
class _ProductLeafRow extends StatelessWidget {
  final _Agg product;
  final double empTotal;
  final bool isLast;

  const _ProductLeafRow({
    required this.product,
    required this.empTotal,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = empTotal > 0 ? product.total / empTotal : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _redLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.shopping_bag_outlined,
                    color: _red, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            color: _textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration:
                            const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (_, v, __) =>
                            LinearProgressIndicator(
                          value: v,
                          minHeight: 3,
                          backgroundColor: _divLine,
                          valueColor:
                              const AlwaysStoppedAnimation(_red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}%  •  '
                      '${product.orders} order${product.orders == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: _textGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('₹${_fmt(product.total)}',
                  style: const TextStyle(
                      color: _red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, color: _divLine, indent: 50),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SUMMARY ROW
// ─────────────────────────────────────────────────────────────
class _SumItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SumItem(this.icon, this.label, this.value, this.color);
}

class _SummaryRow extends StatelessWidget {
  final List<_SumItem> items;
  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 2),
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: items.asMap().entries.expand((e) {
            final widgets = <Widget>[
              Expanded(
                child: Column(
                  children: [
                    Icon(e.value.icon,
                        color: e.value.color, size: 16),
                    const SizedBox(height: 3),
                    Text(e.value.value,
                        style: TextStyle(
                            color: e.value.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                    Text(e.value.label,
                        style: const TextStyle(
                            color: _textGrey, fontSize: 10)),
                  ],
                ),
              ),
            ];
            if (e.key < items.length - 1) {
              widgets.add(
                  Container(width: 1, height: 32, color: _divLine));
            }
            return widgets;
          }).toList(),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
//  NO DATA / EMPTY STATE
// ─────────────────────────────────────────────────────────────
Widget _noData(bool hasFilter, VoidCallback onClear) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: _redLight, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded,
                color: _red, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            hasFilter ? 'No data in this date range' : 'No data found',
            style: const TextStyle(
                color: _textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          if (hasFilter) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onClear,
              child: const Text('Clear filter',
                  style: TextStyle(
                      color: _red,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: _red)),
            ),
          ],
        ],
      ),
    );

// ─────────────────────────────────────────────────────────────
//  UTILITY
// ─────────────────────────────────────────────────────────────
String _fmt(double v) {
  if (v >= 1e7) return '${(v / 1e7).toStringAsFixed(2)}Cr';
  if (v >= 1e5) return '${(v / 1e5).toStringAsFixed(2)}L';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
  return v.toStringAsFixed(0);
}