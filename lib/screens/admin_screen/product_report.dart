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
import 'package:order_booking_app/screens/admin_screen/widgets/admin_retry_widgets.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

//  PROVIDER
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
const _blue       = Color(0xFF6C8EFF);
const _green      = Color(0xFF2ECC71);

// ─── NEW: order-type accent colours ───────────────────────────
const _soColor    = Color(0xFFE53935); // SO  → red  (same brand)
const _soLight    = Color(0xFFFFEBEA);
const _asmColor   = Color(0xFFE53935); // ASM → blue
const _asmLight   = Color(0xFFEEF0FF);

// ─────────────────────────────────────────────────────────────
//  ORDER TYPE ENUM  (NEW)
// ─────────────────────────────────────────────────────────────
enum _OrderType { so, asm }

extension _OrderTypeExt on _OrderType {
  String get label    => this == _OrderType.so ? 'SO'  : 'ASM';
  int    get typeCode => this == _OrderType.so ? 1     : 2;
  Color  get color    => this == _OrderType.so ? _soColor  : _asmColor;
  Color  get light    => this == _OrderType.so ? _soLight  : _asmLight;
  IconData get icon   => this == _OrderType.so
      ? Icons.shopping_cart_outlined
      : Icons.supervisor_account_outlined;
}

// ─────────────────────────────────────────────────────────────
//  DATE FILTER ENUM
// ─────────────────────────────────────────────────────────────
enum DateFilterType { today, monthly, yearly, custom }

extension DateFilterTypeExt on DateFilterType {
  String get label {
    switch (this) {
      case DateFilterType.today:   return 'Today';
      case DateFilterType.monthly: return 'This Month';
      case DateFilterType.yearly:  return 'This Year';
      case DateFilterType.custom:  return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case DateFilterType.today:   return Icons.today_rounded;
      case DateFilterType.monthly: return Icons.calendar_month_rounded;
      case DateFilterType.yearly:  return Icons.calendar_today_rounded;
      case DateFilterType.custom:  return Icons.date_range_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  AGGREGATION HELPERS  (unchanged)
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
  final List<_Agg> products;
  _RegionAgg(super.name, super.total, super.orders, this.employees, this.products);
}

String _orderKey(ProductData e) =>
    '${e.orderDate.toIso8601String()}|${e.emp_name ?? ''}|${e.regionName ?? ''}|${e.companyId ?? ''}';

int _uniqueOrderCount(List<ProductData> raw) =>
    raw.map(_orderKey).toSet().length;

List<_Agg> _aggregateProducts(List<ProductData> raw) {
  final map = <String, double>{};
  final orderKeys = <String, Set<String>>{};
  for (final e in raw) {
    final key = _orderKey(e);
    map[e.productName] = (map[e.productName] ?? 0) + (e.itemTotalPrice ?? 0);
    orderKeys.putIfAbsent(e.productName, () => <String>{}).add(key);
  }
  return map.entries
      .map((e) => _Agg(e.key, e.value, orderKeys[e.key]?.length ?? 0))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}

List<_EmpAgg> _aggregateEmployees(List<ProductData> raw) {
  final totals = <String, Map<String, double>>{};
  final counts = <String, Map<String, Set<String>>>{};
  for (final e in raw) {
    final emp  = e.emp_name ?? 'Unknown';
    final prod = e.productName;
    final key  = _orderKey(e);
    totals.putIfAbsent(emp, () => {})[prod] =
        (totals[emp]![prod] ?? 0) + (e.itemTotalPrice ?? 0);
    counts
        .putIfAbsent(emp, () => {})
        .putIfAbsent(prod, () => <String>{})
        .add(key);
  }
  return totals.entries.map((emp) {
    final prods = emp.value.entries
        .map((p) => _Agg(p.key, p.value, counts[emp.key]![p.key]?.length ?? 0))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    final t = prods.fold(0.0, (s, p) => s + p.total);
    final o = prods.fold(0, (s, p) => s + p.orders);
    return _EmpAgg(emp.key, t, o, prods);
  }).toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}

List<_RegionAgg> _aggregateRegions(List<ProductData> raw) {
  final totals     = <String, Map<String, Map<String, double>>>{};
  final counts     = <String, Map<String, Map<String, Set<String>>>>{};
  final prodTotals = <String, Map<String, double>>{};
  final prodCounts = <String, Map<String, Set<String>>>{};

  for (final e in raw) {
    final r   = e.regionName ?? 'Unknown';
    final emp = e.emp_name ?? 'Unknown';
    final prd = e.productName;
    final amt = e.itemTotalPrice ?? 0;
    final key = _orderKey(e);

    totals.putIfAbsent(r, () => {}).putIfAbsent(emp, () => {})[prd] =
        (totals[r]![emp]![prd] ?? 0) + amt;
    counts
        .putIfAbsent(r, () => {})
        .putIfAbsent(emp, () => {})
        .putIfAbsent(prd, () => <String>{})
        .add(key);

    prodTotals.putIfAbsent(r, () => {})[prd] =
        (prodTotals[r]![prd] ?? 0) + amt;
    prodCounts
        .putIfAbsent(r, () => {})
        .putIfAbsent(prd, () => <String>{})
        .add(key);
  }

  return totals.entries.map((r) {
    final emps = r.value.entries.map((emp) {
      final prods = emp.value.entries
          .map((p) => _Agg(p.key, p.value, counts[r.key]![emp.key]![p.key]?.length ?? 0))
          .toList()
        ..sort((a, b) => b.total.compareTo(a.total));
      final t = prods.fold(0.0, (s, p) => s + p.total);
      final o = prods.fold(0, (s, p) => s + p.orders);
      return _EmpAgg(emp.key, t, o, prods);
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final regionProds = (prodTotals[r.key] ?? {}).entries
        .map((p) => _Agg(p.key, p.value, prodCounts[r.key]![p.key]?.length ?? 0))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final t = emps.fold(0.0, (s, e) => s + e.total);
    final o = emps.fold(0, (s, e) => s + e.orders);
    return _RegionAgg(r.key, t, o, emps, regionProds);
  }).toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}

// ─────────────────────────────────────────────────────────────
//  ROW-LEVEL FILTERS
// ─────────────────────────────────────────────────────────────
List<ProductData> _keepProducts(List<ProductData> raw, Set<String> names) =>
    names.isEmpty ? [] : raw.where((e) => names.contains(e.productName)).toList();

List<ProductData> _keepEmployees(List<ProductData> raw, Set<String> names) =>
    names.isEmpty ? [] : raw.where((e) => names.contains(e.emp_name ?? 'Unknown')).toList();

List<ProductData> _keepRegions(List<ProductData> raw, Set<String> names) =>
    names.isEmpty ? [] : raw.where((e) => names.contains(e.regionName ?? 'Unknown')).toList();

// ─────────────────────────────────────────────────────────────
//  PDF GENERATOR  (reportLabel added to cover + headers)
// ─────────────────────────────────────────────────────────────
class _PdfGenerator {
  static final _ac  = PdfColor.fromHex('#E53935');
  static final _al  = PdfColor.fromHex('#FFEBEA');
  static final _gn  = PdfColor.fromHex('#2ECC71');
  static final _bl  = PdfColor.fromHex('#6C8EFF');
  static final _bll = PdfColor.fromHex('#EEF0FF');
  static final _or  = PdfColor.fromHex('#F59E0B');
  static final _td  = PdfColor.fromHex('#1A1A2E');
  static final _tg  = PdfColor.fromHex('#7A7A8A');
  static final _dl  = PdfColor.fromHex('#EEEEEE');
  static final _bgG = PdfColor.fromHex('#F4F6FA');

  static String _f(double v) {
    if (v >= 1e7) return '${(v / 1e7).toStringAsFixed(2)} Cr';
    if (v >= 1e5) return '${(v / 1e5).toStringAsFixed(2)} L';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)} K';
    return v.toStringAsFixed(0);
  }

  static Future<File> generate({
    required List<ProductData> allData,
    required String companyId,
    required DateTime? startDate,
    required DateTime? endDate,
    required bool includeProduct,
    required bool includeRegion,
    required bool includeEmployee,
    required Set<String>? selectedProducts,
    required Set<String>? selectedRegions,
    required Set<String>? selectedEmployees,
    required String reportLabel, // ← NEW  e.g. "SO Report" / "ASM Report"
  }) async {
    final productData  = includeProduct  ? (selectedProducts  != null ? _keepProducts(allData,  selectedProducts)  : allData) : <ProductData>[];
    final regionData   = includeRegion   ? (selectedRegions   != null ? _keepRegions(allData,   selectedRegions)   : allData) : <ProductData>[];
    final employeeData = includeEmployee ? (selectedEmployees != null ? _keepEmployees(allData, selectedEmployees)  : allData) : <ProductData>[];

    final products  = _aggregateProducts(productData);
    final regions   = _aggregateRegions(regionData);
    final employees = _aggregateEmployees(employeeData);

    final allProducts  = _aggregateProducts(allData);
    final allEmployees = _aggregateEmployees(allData);
    final grandTotal   = allProducts.fold(0.0, (s, p) => s + p.total);
    final dateStr      = _buildDateStr(startDate, endDate);

    final pdf = pw.Document();

    // ── PAGE 1: Cover / Summary ──────────────────────────────
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            height: 150,
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [_ac, PdfColor.fromHex('#C62828')],
                begin: pw.Alignment.topLeft, end: pw.Alignment.bottomRight,
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // ← report label badge
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    reportLabel,
                    style: pw.TextStyle(color: _ac, fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Text('Sales Report', style: pw.TextStyle(color: PdfColors.white, fontSize: 30, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Company: ${allData.isNotEmpty ? allData.first.companyName : ''}', style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                pw.SizedBox(height: 4),
                pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                if (dateStr.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('Period: $dateStr', style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                ],
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [
                  _kpi('Total Revenue', 'Rs. ${_f(grandTotal)}', _gn),
                  pw.SizedBox(width: 14),
                  _kpi('Total Orders', _uniqueOrderCount(allData).toString(), _ac),
                  pw.SizedBox(width: 14),
                  _kpi('Products', allProducts.length.toString(), _or),
                  pw.SizedBox(width: 14),
                  _kpi('Employees', allEmployees.length.toString(), _bl),
                ]),
                pw.SizedBox(height: 30),
                _sh('Report Index', _ac),
                pw.SizedBox(height: 12),
                _indexTable(
                  includeProduct:  includeProduct  && products.isNotEmpty,
                  includeRegion:   includeRegion   && regions.isNotEmpty,
                  includeEmployee: includeEmployee && employees.isNotEmpty,
                  selectedProducts:  selectedProducts,
                  selectedRegions:   selectedRegions,
                  selectedEmployees: selectedEmployees,
                ),
                pw.SizedBox(height: 30),
                _sh('Quick Summary', _tg),
                pw.SizedBox(height: 12),
                _summaryGrid(allProducts, allEmployees, grandTotal),
              ],
            ),
          ),
        ],
      ),
    ));

    // ── PAGE 2: Product Wise ─────────────────────────────────
    if (includeProduct && products.isNotEmpty) {
      final sTotal = products.fold(0.0, (s, p) => s + p.total);
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _hdr('[$reportLabel] Product Wise Report', dateStr, _ac),
        footer: (ctx) => _ftr(ctx, 'Product Wise'),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          if (selectedProducts != null && selectedProducts.isNotEmpty)
            _selBadge('Selected Products', selectedProducts.toList(), _ac),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            _kpi('Products', products.length.toString(), _ac),
            pw.SizedBox(width: 14),
            _kpi('Orders', _uniqueOrderCount(productData).toString(), _or),
            pw.SizedBox(width: 14),
            _kpi('Revenue', 'Rs. ${_f(sTotal)}', _gn),
          ]),
          pw.SizedBox(height: 20),
          _sh('Product Performance', _ac),
          pw.SizedBox(height: 10),
          _prodTable(products, sTotal),
        ],
      ));
    }

    // ── PAGE 3: Region Wise ──────────────────────────────────
    if (includeRegion && regions.isNotEmpty) {
      final sTotal = regions.fold(0.0, (s, r) => s + r.total);
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _hdr('[$reportLabel] Region Wise Report', dateStr, _ac),
        footer: (ctx) => _ftr(ctx, 'Region Wise'),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          if (selectedRegions != null && selectedRegions.isNotEmpty)
            _selBadge('Selected Regions', selectedRegions.toList(), _ac),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            _kpi('Regions', regions.length.toString(), _ac),
            pw.SizedBox(width: 14),
            _kpi('Orders', _uniqueOrderCount(regionData).toString(), _or),
            pw.SizedBox(width: 14),
            _kpi('Revenue', 'Rs. ${_f(sTotal)}', _gn),
          ]),
          pw.SizedBox(height: 20),
          _sh('Region Breakdown', _ac),
          pw.SizedBox(height: 10),
          _regTable(regions, sTotal),
          pw.SizedBox(height: 24),
          _sh('Region Detail (with Products)', _tg),
          pw.SizedBox(height: 10),
          ...regions.map((r) => _regBlock(r, sTotal)),
        ],
      ));
    }

    // ── PAGE 4: Employee Wise ────────────────────────────────
    if (includeEmployee && employees.isNotEmpty) {
      final sTotal = employees.fold(0.0, (s, e) => s + e.total);
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _hdr('[$reportLabel] Employee Wise Report', dateStr, _bl),
        footer: (ctx) => _ftr(ctx, 'Employee Wise'),
        build: (ctx) => [
          pw.SizedBox(height: 16),
          if (selectedEmployees != null && selectedEmployees.isNotEmpty)
            _selBadge('Selected Employees', selectedEmployees.toList(), _bl),
          pw.SizedBox(height: 12),
          pw.Row(children: [
            _kpi('Employees', employees.length.toString(), _bl),
            pw.SizedBox(width: 14),
            _kpi('Orders', _uniqueOrderCount(employeeData).toString(), _or),
            pw.SizedBox(width: 14),
            _kpi('Revenue', 'Rs. ${_f(sTotal)}', _gn),
          ]),
          pw.SizedBox(height: 20),
          _sh('Employee Summary', _bl),
          pw.SizedBox(height: 10),
          _empTable(employees),
          pw.SizedBox(height: 24),
          _sh('Employee Detail (with Products)', _tg),
          pw.SizedBox(height: 10),
          ...employees.map((e) => _empBlock(e)),
        ],
      ));
    }

    final dir  = await getTemporaryDirectory();
    final ts   = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    // ← type label in filename
    final typeSlug = reportLabel.replaceAll(' ', '_').toLowerCase();
    final file = File('${dir.path}/report_${typeSlug}_$ts.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── All the static helper widgets below are UNCHANGED ───────
  static pw.Widget _selBadge(String label, List<String> names, PdfColor color) =>
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 4),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#FFF5F5'),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: color, width: 0.5),
        ),
        child: pw.Wrap(
          spacing: 6, runSpacing: 4,
          children: [
            pw.Text('$label: ', style: pw.TextStyle(color: _tg, fontSize: 8)),
            ...names.map((n) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Text(n, style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
            )),
          ],
        ),
      );

  static pw.Widget _kpi(String label, String value, PdfColor color) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _dl),
        boxShadow: [pw.BoxShadow(color: PdfColor.fromHex('#1A000000'), blurRadius: 6, offset: const PdfPoint(0, 2))],
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(value, style: pw.TextStyle(color: color, fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Text(label, style: pw.TextStyle(color: _tg, fontSize: 9)),
      ]),
    ),
  );

  static pw.Widget _sh(String title, PdfColor color) => pw.Row(children: [
    pw.Container(width: 4, height: 18, color: color),
    pw.SizedBox(width: 8),
    pw.Text(title, style: pw.TextStyle(color: _td, fontSize: 13, fontWeight: pw.FontWeight.bold)),
  ]);

  static pw.Widget _hdr(String title, String dateStr, PdfColor color) => pw.Container(
    padding: const pw.EdgeInsets.fromLTRB(0, 0, 0, 10),
    decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: color, width: 2))),
    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Row(children: [
        pw.Container(width: 8, height: 24, decoration: pw.BoxDecoration(color: color, borderRadius: pw.BorderRadius.circular(4))),
        pw.SizedBox(width: 10),
        pw.Text(title, style: pw.TextStyle(color: _td, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ]),
      pw.Text(dateStr, style: pw.TextStyle(color: _tg, fontSize: 9)),
    ]),
  );

  static pw.Widget _ftr(pw.Context ctx, String section) => pw.Container(
    padding: const pw.EdgeInsets.only(top: 8),
    decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _dl))),
    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(section, style: pw.TextStyle(color: _tg, fontSize: 8)),
      pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: pw.TextStyle(color: _tg, fontSize: 8)),
    ]),
  );

  static pw.Widget _indexTable({
    required bool includeProduct,
    required bool includeRegion,
    required bool includeEmployee,
    required Set<String>? selectedProducts,
    required Set<String>? selectedRegions,
    required Set<String>? selectedEmployees,
  }) {
    int pn = 2;
    final rows = <Map<String, String>>[];
    if (includeProduct)  { final hint = selectedProducts  != null ? ' (${selectedProducts.length} selected)'  : ''; rows.add({'page': 'Page $pn', 'section': 'Product Wise Report$hint',  'desc': 'Products sorted by revenue'});         pn++; }
    if (includeRegion)   { final hint = selectedRegions   != null ? ' (${selectedRegions.length} selected)'   : ''; rows.add({'page': 'Page $pn', 'section': 'Region Wise Report$hint',   'desc': 'Region breakdown with products'});      pn++; }
    if (includeEmployee) { final hint = selectedEmployees != null ? ' (${selectedEmployees.length} selected)' : ''; rows.add({'page': 'Page $pn', 'section': 'Employee Wise Report$hint', 'desc': 'Employee performance'});                     }
    if (rows.isEmpty) return pw.Text('No sections selected.', style: pw.TextStyle(color: _tg, fontSize: 9));

    final h = pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold);
    return pw.Table(
      border: pw.TableBorder.all(color: _dl, width: 0.5),
      columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(3)},
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: _ac), children: [_c('Page', h), _c('Section', h), _c('Description', h)]),
        ...rows.asMap().entries.map((e) => pw.TableRow(
          decoration: pw.BoxDecoration(color: e.key % 2 == 0 ? PdfColors.white : _bgG),
          children: [
            _c(e.value['page']!, pw.TextStyle(color: _ac, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            _c(e.value['section']!, pw.TextStyle(color: _td, fontSize: 9)),
            _c(e.value['desc']!,    pw.TextStyle(color: _tg, fontSize: 9)),
          ],
        )),
      ],
    );
  }

  static pw.Widget _summaryGrid(List<_Agg> prods, List<_EmpAgg> emps, double grand) =>
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Top Products', style: pw.TextStyle(color: _td, fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...prods.take(3).toList().asMap().entries.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(children: [
              pw.Text('${e.key + 1}. ', style: pw.TextStyle(color: _ac, fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(e.value.name, style: pw.TextStyle(color: _td, fontSize: 9))),
              pw.Text('Rs. ${_f(e.value.total)}', style: pw.TextStyle(color: _gn, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ]),
          )),
        ])),
        pw.SizedBox(width: 20), pw.Container(width: 1, height: 80, color: _dl), pw.SizedBox(width: 20),
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Top Employees', style: pw.TextStyle(color: _td, fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ...emps.take(3).toList().asMap().entries.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(children: [
              pw.Text('${e.key + 1}. ', style: pw.TextStyle(color: _bl, fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(e.value.name, style: pw.TextStyle(color: _td, fontSize: 9))),
              pw.Text('Rs. ${_f(e.value.total)}', style: pw.TextStyle(color: _gn, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ]),
          )),
        ])),
      ]);

  static pw.Widget _prodTable(List<_Agg> items, double grand) {
    final h = pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final r = pw.TextStyle(color: _td, fontSize: 9);
    final g = pw.TextStyle(color: _tg, fontSize: 9);
    return pw.Table(
      border: pw.TableBorder.all(color: _dl, width: 0.5),
      columnWidths: {0: const pw.FlexColumnWidth(0.5), 1: const pw.FlexColumnWidth(3.5), 2: const pw.FlexColumnWidth(1.8), 3: const pw.FlexColumnWidth(1), 4: const pw.FlexColumnWidth(1.2)},
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: _ac), children: [_c('#', h), _c('Product Name', h), _c('Revenue', h, a: pw.TextAlign.right), _c('Orders', h, a: pw.TextAlign.center), _c('Share %', h, a: pw.TextAlign.right)]),
        ...items.asMap().entries.map((e) {
          final pct = grand > 0 ? e.value.total / grand * 100 : 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: e.key % 2 == 0 ? PdfColors.white : _bgG),
            children: [_c('${e.key + 1}', g, a: pw.TextAlign.center), _c(e.value.name, r), _c('Rs. ${_f(e.value.total)}', r, a: pw.TextAlign.right), _c(e.value.orders.toString(), r, a: pw.TextAlign.center), _c('${pct.toStringAsFixed(1)}%', g, a: pw.TextAlign.right)],
          );
        }),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F8F1')),
          children: [_c('', pw.TextStyle(fontSize: 9)), _c('TOTAL', pw.TextStyle(color: _td, fontSize: 9, fontWeight: pw.FontWeight.bold)), _c('Rs. ${_f(grand)}', pw.TextStyle(color: _gn, fontSize: 9, fontWeight: pw.FontWeight.bold), a: pw.TextAlign.right), _c(items.fold(0, (s, i) => s + i.orders).toString(), pw.TextStyle(color: _td, fontSize: 9, fontWeight: pw.FontWeight.bold), a: pw.TextAlign.center), _c('100%', pw.TextStyle(color: _tg, fontSize: 9), a: pw.TextAlign.right)],
        ),
      ],
    );
  }

  static pw.Widget _regTable(List<_RegionAgg> regions, double grand) {
    final h = pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final r = pw.TextStyle(color: _td, fontSize: 9);
    final g = pw.TextStyle(color: _tg, fontSize: 9);
    return pw.Table(
      border: pw.TableBorder.all(color: _dl, width: 0.5),
      columnWidths: {0: const pw.FlexColumnWidth(0.5), 1: const pw.FlexColumnWidth(2.5), 2: const pw.FlexColumnWidth(1.8), 3: const pw.FlexColumnWidth(1), 4: const pw.FlexColumnWidth(1), 5: const pw.FlexColumnWidth(1.2)},
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: _ac), children: [_c('#', h), _c('Region', h), _c('Revenue', h, a: pw.TextAlign.right), _c('Orders', h, a: pw.TextAlign.center), _c('Products', h, a: pw.TextAlign.center), _c('Share %', h, a: pw.TextAlign.right)]),
        ...regions.asMap().entries.map((e) {
          final pct = grand > 0 ? e.value.total / grand * 100 : 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: e.key % 2 == 0 ? PdfColors.white : _bgG),
            children: [_c('${e.key + 1}', g, a: pw.TextAlign.center), _c(e.value.name, r), _c('Rs. ${_f(e.value.total)}', r, a: pw.TextAlign.right), _c(e.value.orders.toString(), r, a: pw.TextAlign.center), _c(e.value.products.length.toString(), g, a: pw.TextAlign.center), _c('${pct.toStringAsFixed(1)}%', g, a: pw.TextAlign.right)],
          );
        }),
      ],
    );
  }

  static pw.Widget _regBlock(_RegionAgg r, double grand) {
    final pct = grand > 0 ? r.total / grand * 100 : 0;
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: _dl), borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(color: _al, borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(8), topRight: pw.Radius.circular(8))),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(r.name, style: pw.TextStyle(color: _td, fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.Text('Rs. ${_f(r.total)}  |  ${r.orders} orders  |  ${pct.toStringAsFixed(1)}%', style: pw.TextStyle(color: _ac, fontSize: 9)),
          ]),
        ),
        ...r.products.asMap().entries.map((entry) {
          final p = entry.value; final pp = r.total > 0 ? p.total / r.total * 100 : 0;
          return pw.Container(
            decoration: pw.BoxDecoration(color: entry.key % 2 == 0 ? PdfColors.white : _bgG, border: pw.Border(bottom: pw.BorderSide(color: _dl, width: 0.5))),
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: pw.Row(children: [
              pw.Container(width: 5, height: 5, decoration: pw.BoxDecoration(color: _ac, borderRadius: pw.BorderRadius.circular(3))),
              pw.SizedBox(width: 8),
              pw.Expanded(child: pw.Text(p.name, style: pw.TextStyle(color: _td, fontSize: 9))),
              pw.Text('${p.orders} orders', style: pw.TextStyle(color: _tg, fontSize: 8)),
              pw.SizedBox(width: 12),
              pw.Text('${pp.toStringAsFixed(1)}%', style: pw.TextStyle(color: _tg, fontSize: 8)),
              pw.SizedBox(width: 12),
              pw.Text('Rs. ${_f(p.total)}', style: pw.TextStyle(color: _ac, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ]),
          );
        }),
      ]),
    );
  }

  static pw.Widget _empTable(List<_EmpAgg> emps) {
    final h = pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final r = pw.TextStyle(color: _td, fontSize: 9);
    final g = pw.TextStyle(color: _tg, fontSize: 9);
    final grand = emps.fold(0.0, (s, e) => s + e.total);
    return pw.Table(
      border: pw.TableBorder.all(color: _dl, width: 0.5),
      columnWidths: {0: const pw.FlexColumnWidth(0.5), 1: const pw.FlexColumnWidth(2.5), 2: const pw.FlexColumnWidth(1.8), 3: const pw.FlexColumnWidth(1), 4: const pw.FlexColumnWidth(1), 5: const pw.FlexColumnWidth(1.2)},
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: _bl), children: [_c('#', h), _c('Employee', h), _c('Revenue', h, a: pw.TextAlign.right), _c('Orders', h, a: pw.TextAlign.center), _c('Products', h, a: pw.TextAlign.center), _c('Share %', h, a: pw.TextAlign.right)]),
        ...emps.asMap().entries.map((e) {
          final pct = grand > 0 ? e.value.total / grand * 100 : 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: e.key % 2 == 0 ? PdfColors.white : _bgG),
            children: [_c('${e.key + 1}', g, a: pw.TextAlign.center), _c(e.value.name, r), _c('Rs. ${_f(e.value.total)}', r, a: pw.TextAlign.right), _c(e.value.orders.toString(), r, a: pw.TextAlign.center), _c(e.value.products.length.toString(), g, a: pw.TextAlign.center), _c('${pct.toStringAsFixed(1)}%', g, a: pw.TextAlign.right)],
          );
        }),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F8F1')),
          children: [_c('', pw.TextStyle(fontSize: 9)), _c('TOTAL', pw.TextStyle(color: _td, fontSize: 9, fontWeight: pw.FontWeight.bold)), _c('Rs. ${_f(grand)}', pw.TextStyle(color: _gn, fontSize: 9, fontWeight: pw.FontWeight.bold), a: pw.TextAlign.right), _c(emps.fold(0, (s, e) => s + e.orders).toString(), pw.TextStyle(color: _td, fontSize: 9, fontWeight: pw.FontWeight.bold), a: pw.TextAlign.center), _c('', pw.TextStyle(fontSize: 9)), _c('100%', pw.TextStyle(color: _tg, fontSize: 9), a: pw.TextAlign.right)],
        ),
      ],
    );
  }

  static pw.Widget _empBlock(_EmpAgg emp) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    decoration: pw.BoxDecoration(border: pw.Border.all(color: _dl), borderRadius: pw.BorderRadius.circular(8)),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: pw.BoxDecoration(color: _bll, borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(8), topRight: pw.Radius.circular(8))),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Row(children: [
            pw.Container(width: 24, height: 24, decoration: pw.BoxDecoration(color: _bl, borderRadius: pw.BorderRadius.circular(12)), alignment: pw.Alignment.center,
              child: pw.Text(emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(width: 8),
            pw.Text(emp.name, style: pw.TextStyle(color: _td, fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.Text('Rs. ${_f(emp.total)}  |  ${emp.orders} orders  |  ${emp.products.length} products', style: pw.TextStyle(color: _bl, fontSize: 9)),
        ]),
      ),
      ...emp.products.asMap().entries.map((entry) {
        final p = entry.value; final pct = emp.total > 0 ? p.total / emp.total * 100 : 0;
        return pw.Container(
          decoration: pw.BoxDecoration(color: entry.key % 2 == 0 ? PdfColors.white : _bgG, border: pw.Border(bottom: pw.BorderSide(color: _dl, width: 0.5))),
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: pw.Row(children: [
            pw.Container(width: 5, height: 5, decoration: pw.BoxDecoration(color: _ac, borderRadius: pw.BorderRadius.circular(3))),
            pw.SizedBox(width: 8),
            pw.Expanded(child: pw.Text(p.name, style: pw.TextStyle(color: _td, fontSize: 9))),
            pw.Text('${p.orders} orders', style: pw.TextStyle(color: _tg, fontSize: 8)),
            pw.SizedBox(width: 12),
            pw.Text('${pct.toStringAsFixed(1)}%', style: pw.TextStyle(color: _tg, fontSize: 8)),
            pw.SizedBox(width: 12),
            pw.Text('Rs. ${_f(p.total)}', style: pw.TextStyle(color: _ac, fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ]),
        );
      }),
    ]),
  );

  static pw.Widget _c(String text, pw.TextStyle style, {pw.TextAlign a = pw.TextAlign.left}) =>
      pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5), child: pw.Text(text, style: style, textAlign: a));

  static String _buildDateStr(DateTime? start, DateTime? end) {
    if (start == null && end == null) return 'All time';
    final fmt = DateFormat('dd MMM yyyy');
    if (start != null && end != null) return '${fmt.format(start)} – ${fmt.format(end)}';
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

  DateFilterType _filterType = DateFilterType.today;
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _pdfLoading = false;

  // ── NEW: active order type ────────────────────────────────
  _OrderType _orderType = _OrderType.so;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportTabProvider.notifier).getProductReport(widget.companyId);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  DateTime? get _effectiveStart {
    final now = DateTime.now();
    switch (_filterType) {
      case DateFilterType.today:   return DateTime(now.year, now.month, now.day);
      case DateFilterType.monthly: return DateTime(now.year, now.month, 1);
      case DateFilterType.yearly:  return DateTime(now.year, 1, 1);
      case DateFilterType.custom:  return _customStart;
    }
  }

  DateTime? get _effectiveEnd {
    final now = DateTime.now();
    switch (_filterType) {
      case DateFilterType.today:   return DateTime(now.year, now.month, now.day);
      case DateFilterType.monthly: return DateTime(now.year, now.month + 1, 0);
      case DateFilterType.yearly:  return DateTime(now.year, 12, 31);
      case DateFilterType.custom:  return _customEnd;
    }
  }

  /// Apply BOTH date filter AND order-type filter.
  List<ProductData> _filter(List<ProductData> raw) {
    final start      = _effectiveStart;
    final end        = _effectiveEnd;
    final typeCode   = _orderType.typeCode; // ← NEW

    return raw.where((e) {
      // ── order-type gate ───────────────────────────────────
      if (e.type != typeCode) return false;            // ← NEW

      // ── date gate ────────────────────────────────────────
      final d = DateTime(e.orderDate.year, e.orderDate.month, e.orderDate.day);
      if (start != null && d.isBefore(start)) return false;
      if (end   != null && d.isAfter(end))    return false;

      return true;
    }).toList();
  }

  Future<void> _pickCustomDate({required bool isStart}) async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_customStart ?? now) : (_customEnd ?? now),
      firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _soColor, onPrimary: _white, surface: _white, onSurface: _textDark)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) { _customStart = picked; if (_customEnd != null && _customEnd!.isBefore(picked)) _customEnd = null; }
      else         { _customEnd   = picked; if (_customStart != null && picked.isBefore(_customStart!)) _customStart = null; }
    });
  }

  // ── download sheet (passes reportLabel to PDF generator) ──
  Future<void> _showDownloadSheet(List<ProductData> filtered) async {
    if (_pdfLoading) return;

    final allP = _aggregateProducts(filtered);
    final allR = _aggregateRegions(filtered);
    final allE = _aggregateEmployees(filtered);

    Set<String> selP = <String>{};
    Set<String> selR = <String>{};
    Set<String> selE = <String>{};

    int sheetTab = _tabCtrl.index;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
        const activeColor = _soColor; // ← keep SO colors even for ASM
        Color   tabClr(int i) => i == 2 ? _blue : activeColor;
        IconData tabIco(int i) { if (i == 0) return Icons.inventory_2_outlined; if (i == 1) return Icons.location_on_outlined; return Icons.person_outline_rounded; }
        String  tabLbl(int i) { if (i == 0) return 'Product'; if (i == 1) return 'Region'; return 'Employee'; }
        bool    tabAvail(int i) { if (i == 1) return allR.isNotEmpty; if (i == 2) return allE.isNotEmpty; return true; }
        bool    sectOn(int i) { if (i == 0) return selP.isNotEmpty; if (i == 1) return selR.isNotEmpty; return selE.isNotEmpty; }

        List<String> curNames() { if (sheetTab == 0) return allP.map((x) => x.name).toList(); if (sheetTab == 1) return allR.map((x) => x.name).toList(); return allE.map((x) => x.name).toList(); }
        Set<String>  curSel()   { if (sheetTab == 0) return selP; if (sheetTab == 1) return selR; return selE; }

        void toggleItem(String n) => ss(() { final s = curSel(); if (s.contains(n)) s.remove(n); else s.add(n); });
        void selAll()  => ss(() => curSel().addAll(curNames()));
        void selNone() => ss(() => curSel().clear());

        final names    = curNames();
        final selected = curSel();
        final anyOn    = selP.isNotEmpty || selR.isNotEmpty || selE.isNotEmpty;
        final totalSel = selP.length + selR.length + selE.length;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.80,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, ctrl) => Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: _divLine, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _orderType.light, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.picture_as_pdf_rounded, color: activeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('Download Report', style: TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      // ← type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(20)),
                        child: Text(_orderType.label, style: const TextStyle(color: _white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    Text('$totalSel item${totalSel == 1 ? '' : 's'} selected', style: const TextStyle(color: _textGrey, fontSize: 11)),
                  ])),
                  GestureDetector(
                    onTap: () => ss(() {
                      selP = Set.from(allP.map((x) => x.name));
                      selR = Set.from(allR.map((x) => x.name));
                      selE = Set.from(allE.map((x) => x.name));
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: _orderType.light, borderRadius: BorderRadius.circular(20)),
                      child: Text('All ✓', style: TextStyle(color: activeColor, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                Container(
                  height: 42,
                  decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: List.generate(3, (i) {
                    final isSel = sheetTab == i;
                    final avail = tabAvail(i);
                    return Expanded(child: GestureDetector(
                      onTap: avail ? () => ss(() => sheetTab = i) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: isSel ? tabClr(i) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(tabIco(i), size: 13, color: isSel ? _white : (avail ? _textGrey : _divLine)),
                          const SizedBox(width: 4),
                          Text(tabLbl(i), style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500, color: isSel ? _white : (avail ? _textGrey : _divLine))),
                          if (avail) ...[
                            const SizedBox(width: 4),
                            Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: sectOn(i) ? tabClr(i) : _divLine)),
                          ],
                        ]),
                      ),
                    ));
                  })),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  const Spacer(),
                  GestureDetector(onTap: selAll,  child: Text('All ✓',   style: TextStyle(color: tabClr(sheetTab), fontSize: 12, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 14),
                  GestureDetector(onTap: selNone, child: const Text('None ✗', style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w600))),
                ]),
              ]),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: _divLine),
            Expanded(
              child: names.isEmpty
                  ? const Center(child: Text('No data', style: TextStyle(color: _textGrey)))
                  : ListView.separated(
                      controller: ctrl,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      itemCount: names.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final name  = names[i];
                        final isSel = selected.contains(name);
                        double val = 0; int ords = 0;
                        if (sheetTab == 0)      { final a = allP.firstWhere((x) => x.name == name, orElse: () => _Agg('', 0, 0)); val = a.total; ords = a.orders; }
                        else if (sheetTab == 1) { final a = allR.firstWhere((x) => x.name == name, orElse: () => _RegionAgg('', 0, 0, [], [])); val = a.total; ords = a.orders; }
                        else                    { final a = allE.firstWhere((x) => x.name == name, orElse: () => _EmpAgg('', 0, 0, [])); val = a.total; ords = a.orders; }

                        return GestureDetector(
                          onTap: () => toggleItem(name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 130),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: isSel ? tabClr(sheetTab).withOpacity(0.06) : _bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSel ? tabClr(sheetTab).withOpacity(0.35) : _divLine),
                            ),
                            child: Row(children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(color: isSel ? tabClr(sheetTab).withOpacity(0.12) : _divLine.withOpacity(0.4), borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.center,
                                child: sheetTab == 2
                                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: isSel ? _blue : _textGrey, fontSize: 14, fontWeight: FontWeight.w800))
                                    : Icon(sheetTab == 0 ? Icons.shopping_bag_outlined : Icons.location_on_outlined, size: 16, color: isSel ? tabClr(sheetTab) : _textGrey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(name, style: TextStyle(color: isSel ? _textDark : _textGrey, fontSize: 13, fontWeight: FontWeight.w700)),
                                Text('$ords orders  •  ₹${_fmt(val)}', style: TextStyle(color: isSel ? _textGrey : _divLine, fontSize: 11)),
                              ])),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 130),
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  color: isSel ? tabClr(sheetTab) : _white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isSel ? tabClr(sheetTab) : _divLine, width: 1.5),
                                ),
                                child: isSel ? const Icon(Icons.check_rounded, size: 14, color: _white) : null,
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Column(children: [
                if (anyOn)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      if (selP.isNotEmpty) _miniStat('📦 Products',  '${selP.length}/${allP.length}', activeColor),
                      if (selR.isNotEmpty) _miniStat('📍 Regions',   '${selR.length}/${allR.length}', activeColor),
                      if (selE.isNotEmpty) _miniStat('👤 Employees', '${selE.length}/${allE.length}', _blue),
                    ]),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: anyOn ? activeColor : _textGrey,
                      foregroundColor: _white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: !anyOn ? null : () async {
                      final inclP = selP.isNotEmpty;
                      final inclR = selR.isNotEmpty;
                      final inclE = selE.isNotEmpty;
                      Navigator.of(ctx).pop();
                      await _generateAndShow(
                        filtered: filtered,
                        inclP: inclP, inclR: inclR, inclE: inclE,
                        selP: inclP && selP.length < allP.length ? selP : null,
                        selR: inclR && selR.length < allR.length ? selR : null,
                        selE: inclE && selE.length < allE.length ? selE : null,
                        allP: allP, allR: allR, allE: allE,
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(anyOn ? 'Generate PDF' : 'Select at least one item', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ]),
        );
      }),
    );
  }

  static Widget _miniStat(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: _textGrey, fontSize: 10)),
  ]);

  Future<void> _generateAndShow({
    required List<ProductData> filtered,
    required bool inclP, required bool inclR, required bool inclE,
    required Set<String>? selP, required Set<String>? selR, required Set<String>? selE,
    required List<_Agg> allP, required List<_RegionAgg> allR, required List<_EmpAgg> allE,
  }) async {
    setState(() => _pdfLoading = true);
    try {
      final file = await _PdfGenerator.generate(
        allData:   filtered,
        companyId: widget.companyId,
        startDate: _effectiveStart, endDate: _effectiveEnd,
        includeProduct:  inclP,
        includeRegion:   inclR,
        includeEmployee: inclE,
        selectedProducts:  selP,
        selectedRegions:   selR,
        selectedEmployees: selE,
        reportLabel: _orderType.label, // ← NEW
      );
      if (!mounted) return;

      const activeColor = _soColor;
      final badges = <_PageBadge>[];
      int pn = 1;
      badges.add(_PageBadge('Page $pn', 'Summary & Index', _green)); pn++;
      if (inclP) { badges.add(_PageBadge('Page $pn', 'Product Wise${selP  != null ? ' (${selP.length}/${allP.length})'  : ''}', activeColor)); pn++; }
      if (inclR) { badges.add(_PageBadge('Page $pn', 'Region Wise${selR   != null ? ' (${selR.length}/${allR.length})'   : ''}', activeColor)); pn++; }
      if (inclE) { badges.add(_PageBadge('Page $pn', 'Employee Wise${selE != null ? ' (${selE.length}/${allE.length})' : ''}',  _blue));        }

      await showModalBottomSheet(
        context: context,
        backgroundColor: _white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _PdfReadySheet(file: file, badges: badges, accentColor: activeColor),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please try again.'),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportTabProvider);
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // ── header accent follows active type ────────────────
        _Header(
          companyId:  widget.companyId,
          pdfLoading: _pdfLoading,
          orderType:  _orderType,          // ← NEW
          onDownload: () {
            final s = state.productReport;
            if (s == null) return;
            s.whenData((rawList) => _showDownloadSheet(_filter(rawList)));
          },
        ),
        // ── SO / ASM switcher ────────────────────────────────
        _OrderTypeBar(                     // ← NEW WIDGET
          selected: _orderType,
          onChanged: (t) => setState(() => _orderType = t),
        ),
        _DateFilterBar(
          filterType: _filterType, customStart: _customStart, customEnd: _customEnd,
          onTypeChanged: (t) => setState(() { _filterType = t; if (t != DateFilterType.custom) { _customStart = null; _customEnd = null; } }),
          onPickCustomStart: () => _pickCustomDate(isStart: true),
          onPickCustomEnd:   () => _pickCustomDate(isStart: false),
          effectiveStart: _effectiveStart, effectiveEnd: _effectiveEnd,
          accentColor: _soColor,   // keep SO colors even for ASM
        ),
        _TabBar(controller: _tabCtrl, accentColor: _soColor), // keep SO colors even for ASM
        Expanded(
          child: state.productReport == null
              ? _emptyView()
              : state.productReport!.when(
                  loading: () => _loadingView(),
                  error:   (e, _) => _errorView(),
                  data: (rawList) {
                    final filtered = _filter(rawList);
                    return TabBarView(controller: _tabCtrl, children: [
                      _ProductTab(data: filtered,  filterType: _filterType, accentColor: _soColor),
                      _RegionTab(data: filtered,   filterType: _filterType, accentColor: _soColor),
                      _EmployeeTab(data: filtered, filterType: _filterType, accentColor: _soColor),
                    ]);
                  },
                ),
        ),
      ]),
    );
  }

  Widget _loadingView() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const CircularProgressIndicator(color: _soColor, strokeWidth: 2.5), const SizedBox(height: 14),
    const Text('Loading report…', style: TextStyle(color: _textGrey, fontSize: 13)),
  ]));

  Widget _errorView() => AdminSomethingWentWrongRetry(
    onRetry: () => ref.read(reportTabProvider.notifier).getProductReport(widget.companyId),
  );

  Widget _emptyView() => const Center(child: Text('No data', style: TextStyle(color: _textGrey, fontSize: 14)));
}

// ─────────────────────────────────────────────────────────────
//  ORDER TYPE BAR  (NEW WIDGET)
// ─────────────────────────────────────────────────────────────
class _OrderTypeBar extends StatelessWidget {
  final _OrderType selected;
  final ValueChanged<_OrderType> onChanged;

  const _OrderTypeBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    height: 48,
    decoration: BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Row(children: _OrderType.values.map((t) {
      final isSel = selected == t;
      return Expanded(child: GestureDetector(
        onTap: () => onChanged(t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSel ? t.color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(t.icon, size: 15, color: isSel ? _white : _textGrey),
            const SizedBox(width: 6),
            Text(
              t.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                color: isSel ? _white : _textGrey,
              ),
            ),
            // little dot shows if data exists for this type (always shown, just for polish)
            const SizedBox(width: 5),
            if (!isSel)
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: t.color.withOpacity(0.4)),
              ),
          ]),
        ),
      ));
    }).toList()),
  );
}

// ─────────────────────────────────────────────────────────────
//  DATE FILTER BAR  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _DateFilterBar extends StatelessWidget {
  final DateFilterType filterType;
  final DateTime? customStart, customEnd, effectiveStart, effectiveEnd;
  final ValueChanged<DateFilterType> onTypeChanged;
  final VoidCallback onPickCustomStart, onPickCustomEnd;
  final Color accentColor; // ← NEW

  const _DateFilterBar({
    required this.filterType,
    required this.customStart,
    required this.customEnd,
    required this.effectiveStart,
    required this.effectiveEnd,
    required this.onTypeChanged,
    required this.onPickCustomStart,
    required this.onPickCustomEnd,
    this.accentColor = _red, // ← default keeps existing behaviour
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 12, offset: const Offset(0, 3))],
      border: filterType != DateFilterType.today ? Border.all(color: accentColor.withOpacity(0.25)) : null,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: DateFilterType.values.map((t) {
        final sel = filterType == t;
        return Expanded(child: GestureDetector(
          onTap: () => onTypeChanged(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: sel ? accentColor : _bg,
              borderRadius: BorderRadius.circular(10),
              border: sel ? null : Border.all(color: _divLine),
            ),
            child: Column(children: [
              Icon(t.icon, size: 14, color: sel ? _white : _textGrey),
              const SizedBox(height: 3),
              Text(t.label, style: TextStyle(fontSize: 10, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? _white : _textGrey), textAlign: TextAlign.center),
            ]),
          ),
        ));
      }).toList()),
      if (filterType == DateFilterType.custom) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _DatePill(label: 'From', value: customStart == null ? 'Select date' : DateFormat('dd MMM yyyy').format(customStart!), selected: customStart != null, onTap: onPickCustomStart, accentColor: accentColor)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_rounded, color: _textGrey.withOpacity(0.5), size: 16)),
          Expanded(child: _DatePill(label: 'To', value: customEnd == null ? 'Select date' : DateFormat('dd MMM yyyy').format(customEnd!), selected: customEnd != null, onTap: onPickCustomEnd, accentColor: accentColor)),
        ]),
      ],
      if (effectiveStart != null || effectiveEnd != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.filter_alt_rounded, color: accentColor, size: 13), const SizedBox(width: 5),
            Text(
              effectiveStart != null && effectiveEnd != null && effectiveStart == effectiveEnd
                  ? DateFormat('dd MMM yyyy').format(effectiveStart!)
                  : '${effectiveStart != null ? DateFormat('dd MMM').format(effectiveStart!) : '...'}  →  ${effectiveEnd != null ? DateFormat('dd MMM yyyy').format(effectiveEnd!) : '...'}',
              style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ],
    ]),
  );
}

// ─────────────────────────────────────────────────────────────
//  PDF READY SHEET  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _PdfReadySheet extends StatelessWidget {
  final File file;
  final List<_PageBadge> badges;
  final Color accentColor; // ← NEW
  const _PdfReadySheet({required this.file, required this.badges, this.accentColor = _red});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: _divLine, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.picture_as_pdf_rounded, color: accentColor, size: 36),
      ),
      const SizedBox(height: 14),
      const Text('Report Ready!', style: TextStyle(color: _textDark, fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
        child: Column(children: badges),
      ),
      Text(file.path.split('/').last, style: const TextStyle(color: _textGrey, fontSize: 11), textAlign: TextAlign.center),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor, foregroundColor: _white, elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () { Navigator.of(context).pop(); OpenFile.open(file.path); },
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: const Text('Open PDF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      )),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor, side: BorderSide(color: accentColor.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () { Navigator.of(context).pop(); share_plus.Share.shareXFiles([share_plus.XFile(file.path)], subject: 'Sales Report'); },
        icon: const Icon(Icons.share_rounded, size: 18),
        label: const Text('Share', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      )),
    ]),
  );
}

class _PageBadge extends StatelessWidget {
  final String page, label; final Color color;
  const _PageBadge(this.page, this.label, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(page, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: _textDark, fontSize: 11)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────
//  HEADER  (orderType param added)
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String companyId;
  final bool pdfLoading;
  final VoidCallback onDownload;
  final _OrderType orderType; // ← NEW

  const _Header({required this.companyId, required this.pdfLoading, required this.onDownload, required this.orderType});

  @override
  Widget build(BuildContext context) {
    // Gradient shifts between SO-red and ASM-blue
    final gradStart = _redDark;
    final gradEnd  = _redDark ;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [gradStart, gradEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16, bottom: 18),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _white, size: 18), onPressed: () => Navigator.of(context).maybePop(), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Reports', style: TextStyle(color: _white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            // active type badge in header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Text(orderType.label, style: const TextStyle(color: _white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const Text('Product • Region • Employee', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ])),
        GestureDetector(
          onTap: pdfLoading ? null : onDownload,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white30)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              pdfLoading
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: _white, strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf_rounded, color: _white, size: 16),
              const SizedBox(width: 6),
              Text(pdfLoading ? 'Generating…' : 'Download', style: const TextStyle(color: _white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DATE PILL  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _DatePill extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  const _DatePill({required this.label, required this.value, required this.selected, required this.onTap, this.accentColor = _red});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? accentColor.withOpacity(0.08) : _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? accentColor.withOpacity(0.4) : _divLine),
      ),
      child: Row(children: [
        Icon(Icons.calendar_today_rounded, color: selected ? accentColor : _textGrey, size: 13),
        const SizedBox(width: 7),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: selected ? accentColor : _textGrey, fontSize: 10, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: selected ? _textDark : _textGrey, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ])),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  TAB BAR  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  final Color accentColor; // ← NEW

  const _TabBar({required this.controller, this.accentColor = _red});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0), height: 44,
    decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 8, offset: const Offset(0, 2))]),
    child: TabBar(
      controller: controller,
      indicator: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(11)),
      indicatorSize: TabBarIndicatorSize.tab, indicatorPadding: const EdgeInsets.all(3),
      labelColor: _white, unselectedLabelColor: _textGrey,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory_2_outlined, size: 13), SizedBox(width: 5), Text('Product')])),
        Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.location_on_outlined, size: 13), SizedBox(width: 5), Text('Region')])),
        Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_outline_rounded, size: 13), SizedBox(width: 5), Text('Employee')])),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  TAB 1: PRODUCT WISE  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _ProductTab extends StatelessWidget {
  final List<ProductData> data;
  final DateFilterType filterType;
  final Color accentColor;
  const _ProductTab({required this.data, required this.filterType, this.accentColor = _red});

  @override
  Widget build(BuildContext context) {
    final items = _aggregateProducts(data);
    final grand = items.fold(0.0, (s, i) => s + i.total);
    if (items.isEmpty) return _noData(filterType);
    return Column(children: [
      _SummaryRow(items: [
        _SumItem(Icons.inventory_2_outlined, 'Products', items.length.toString(), accentColor),
        _SumItem(Icons.receipt_long_outlined, 'Orders', _uniqueOrderCount(data).toString(), _textGrey),
        _SumItem(Icons.currency_rupee_rounded, 'Total', '₹${_fmt(grand)}', _green),
      ]),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ProductCard(item: items[i], index: i, grand: grand, accentColor: accentColor),
      )),
    ]);
  }
}

class _ProductCard extends StatelessWidget {
  final _Agg item; final int index; final double grand;
  final Color accentColor;
  const _ProductCard({required this.item, required this.index, required this.grand, this.accentColor = _red});
  static const _rankColors = [Color(0xFFF59E0B), Color(0xFF94A3B8), Color(0xFFCD7F32)];

  @override
  Widget build(BuildContext context) {
    final pct = grand > 0 ? item.total / grand : 0.0;
    final isTop = index < 3;
    final rankColor = isTop ? _rankColors[index] : const Color(0xFF94A3B8);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 3))],
        border: isTop ? Border.all(color: rankColor.withOpacity(0.25)) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: rankColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: isTop
                ? Icon(_rankIcon(index), color: rankColor, size: 16)
                : Text('#${index + 1}', style: TextStyle(color: rankColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w700)),
            Text('${item.orders} orders', style: const TextStyle(color: _textGrey, fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFE8F8F1), borderRadius: BorderRadius.circular(10)),
            child: Text('₹${_fmt(item.total)}', style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct),
            duration: Duration(milliseconds: 600 + index * 40),
            curve: Curves.easeOut,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v, minHeight: 5, backgroundColor: _divLine,
              valueColor: AlwaysStoppedAnimation(isTop ? rankColor : accentColor),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text('${(pct * 100).toStringAsFixed(1)}% of total sales', style: const TextStyle(color: _textGrey, fontSize: 10)),
      ]),
    );
  }

  IconData _rankIcon(int r) { switch (r) { case 0: return Icons.emoji_events_rounded; case 1: return Icons.military_tech_rounded; default: return Icons.workspace_premium_rounded; } }
}

// ─────────────────────────────────────────────────────────────
//  TAB 2: REGION WISE  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _RegionTab extends StatelessWidget {
  final List<ProductData> data;
  final DateFilterType filterType;
  final Color accentColor;
  const _RegionTab({required this.data, required this.filterType, this.accentColor = _red});

  @override
  Widget build(BuildContext context) {
    final regions = _aggregateRegions(data);
    final grand   = regions.fold(0.0, (s, r) => s + r.total);
    if (regions.isEmpty) return _noData(filterType);
    return Column(children: [
      _SummaryRow(items: [
        _SumItem(Icons.map_outlined, 'Regions', regions.length.toString(), accentColor),
        _SumItem(Icons.receipt_long_outlined, 'Orders', _uniqueOrderCount(data).toString(), _textGrey),
        _SumItem(Icons.currency_rupee_rounded, 'Total', '₹${_fmt(grand)}', _green),
      ]),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: regions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _RegionProductCard(region: regions[i], grand: grand, accentColor: accentColor),
      )),
    ]);
  }
}

class _RegionProductCard extends StatefulWidget {
  final _RegionAgg region; final double grand;
  final Color accentColor;
  const _RegionProductCard({required this.region, required this.grand, this.accentColor = _red});
  @override State<_RegionProductCard> createState() => _RegionProductCardState();
}
class _RegionProductCardState extends State<_RegionProductCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final pct = widget.grand > 0 ? widget.region.total / widget.grand : 0.0;
    final ac  = widget.accentColor;
    return Container(
      decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        Material(color: Colors.transparent, child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: ac.withOpacity(0.10), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Icon(Icons.location_on_rounded, color: ac, size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.region.name, style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w700)),
                Text('${widget.region.products.length} products  •  ${widget.region.orders} orders', style: const TextStyle(color: _textGrey, fontSize: 11)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE8F8F1), borderRadius: BorderRadius.circular(10)), child: Text('₹${_fmt(widget.region.total)}', style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w800))),
              const SizedBox(width: 6),
              AnimatedRotation(turns: _expanded ? 0.5 : 0, duration: const Duration(milliseconds: 220), child: const Icon(Icons.keyboard_arrow_down_rounded, color: _textGrey, size: 20)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: pct), duration: const Duration(milliseconds: 650), curve: Curves.easeOut,
                builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 5, backgroundColor: _divLine, valueColor: AlwaysStoppedAnimation(ac)))),
            const SizedBox(height: 4),
            Text('${(pct * 100).toStringAsFixed(1)}% of total', style: const TextStyle(color: _textGrey, fontSize: 10)),
          ])),
        )),
        AnimatedSize(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut,
          child: _expanded
              ? Container(
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: _divLine))),
                  child: Column(children: widget.region.products.asMap().entries.map((e) => _ProductLeafRow(product: e.value, empTotal: widget.region.total, isLast: e.key == widget.region.products.length - 1, accentColor: ac)).toList()),
                )
              : const SizedBox.shrink()),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 3: EMPLOYEE WISE  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _EmployeeTab extends StatelessWidget {
  final List<ProductData> data;
  final DateFilterType filterType;
  final Color accentColor;
  const _EmployeeTab({required this.data, required this.filterType, this.accentColor = _red});

  @override
  Widget build(BuildContext context) {
    final emps  = _aggregateEmployees(data);
    final grand = emps.fold(0.0, (s, e) => s + e.total);
    if (emps.isEmpty) return _noData(filterType);
    return Column(children: [
      _SummaryRow(items: [
        _SumItem(Icons.people_outline_rounded, 'Employees', emps.length.toString(), accentColor),
        _SumItem(Icons.receipt_long_outlined, 'Orders', _uniqueOrderCount(data).toString(), _textGrey),
        _SumItem(Icons.currency_rupee_rounded, 'Total', '₹${_fmt(grand)}', _green),
      ]),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: emps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _EmpProductCard(emp: emps[i], grand: grand, accentColor: accentColor),
      )),
    ]);
  }
}

class _EmpProductCard extends StatefulWidget {
  final _EmpAgg emp; final double grand;
  final Color accentColor;
  const _EmpProductCard({required this.emp, required this.grand, this.accentColor = _red});
  @override State<_EmpProductCard> createState() => _EmpProductCardState();
}
class _EmpProductCardState extends State<_EmpProductCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final pct = widget.grand > 0 ? widget.emp.total / widget.grand : 0.0;
    final ac  = widget.accentColor;
    return Container(
      decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        Material(color: Colors.transparent, child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 18, backgroundColor: ac.withOpacity(0.13), child: Text(widget.emp.name.isNotEmpty ? widget.emp.name[0].toUpperCase() : '?', style: TextStyle(color: ac, fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.emp.name, style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w700)),
                Text('${widget.emp.products.length} products  •  ${widget.emp.orders} orders', style: const TextStyle(color: _textGrey, fontSize: 11)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE8F8F1), borderRadius: BorderRadius.circular(10)), child: Text('₹${_fmt(widget.emp.total)}', style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w800))),
              const SizedBox(width: 6),
              AnimatedRotation(turns: _expanded ? 0.5 : 0, duration: const Duration(milliseconds: 220), child: const Icon(Icons.keyboard_arrow_down_rounded, color: _textGrey, size: 20)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: pct), duration: const Duration(milliseconds: 650), curve: Curves.easeOut,
                builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 5, backgroundColor: _divLine, valueColor: AlwaysStoppedAnimation(ac)))),
            const SizedBox(height: 4),
            Text('${(pct * 100).toStringAsFixed(1)}% of total', style: const TextStyle(color: _textGrey, fontSize: 10)),
          ])),
        )),
        AnimatedSize(duration: const Duration(milliseconds: 280), curve: Curves.easeInOut,
          child: _expanded
              ? Container(
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: _divLine))),
                  child: Column(children: widget.emp.products.asMap().entries.map((e) => _ProductLeafRow(product: e.value, empTotal: widget.emp.total, isLast: e.key == widget.emp.products.length - 1, accentColor: ac)).toList()),
                )
              : const SizedBox.shrink()),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PRODUCT LEAF ROW  (accentColor param added)
// ─────────────────────────────────────────────────────────────
class _ProductLeafRow extends StatelessWidget {
  final _Agg product; final double empTotal; final bool isLast;
  final Color accentColor;
  const _ProductLeafRow({required this.product, required this.empTotal, this.isLast = false, this.accentColor = _red});

  @override
  Widget build(BuildContext context) {
    final pct = empTotal > 0 ? product.total / empTotal : 0.0;
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), child: Row(children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: accentColor.withOpacity(0.10), borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Icon(Icons.shopping_bag_outlined, color: accentColor, size: 14)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: const TextStyle(color: _textDark, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          ClipRRect(borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: pct), duration: const Duration(milliseconds: 500), curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 3, backgroundColor: _divLine, valueColor: AlwaysStoppedAnimation(accentColor)))),
          const SizedBox(height: 2),
          Text('${(pct * 100).toStringAsFixed(1)}%  •  ${product.orders} order${product.orders == 1 ? '' : 's'}', style: const TextStyle(color: _textGrey, fontSize: 10)),
        ])),
        const SizedBox(width: 8),
        Text('₹${_fmt(product.total)}', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w700)),
      ])),
      if (!isLast) const Divider(height: 1, color: _divLine, indent: 50),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
//  SUMMARY ROW  (unchanged)
// ─────────────────────────────────────────────────────────────
class _SumItem { final IconData icon; final String label, value; final Color color; const _SumItem(this.icon, this.label, this.value, this.color); }

class _SummaryRow extends StatelessWidget {
  final List<_SumItem> items;
  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 2),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(children: items.asMap().entries.expand((e) {
      final ws = <Widget>[Expanded(child: Column(children: [Icon(e.value.icon, color: e.value.color, size: 16), const SizedBox(height: 3), Text(e.value.value, style: TextStyle(color: e.value.color, fontSize: 13, fontWeight: FontWeight.w800)), Text(e.value.label, style: const TextStyle(color: _textGrey, fontSize: 10))]))];
      if (e.key < items.length - 1) ws.add(Container(width: 1, height: 32, color: _divLine));
      return ws;
    }).toList()),
  );
}

// ─────────────────────────────────────────────────────────────
//  NO DATA  (unchanged)
// ─────────────────────────────────────────────────────────────
Widget _noData(DateFilterType ft) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: _redLight, shape: BoxShape.circle), child: const Icon(Icons.search_off_rounded, color: _red, size: 36)),
  const SizedBox(height: 14),
  Text(
    ft == DateFilterType.today   ? 'No orders today'      :
    ft == DateFilterType.monthly ? 'No orders this month' :
    ft == DateFilterType.yearly  ? 'No orders this year'  : 'No data in selected range',
    style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w600),
  ),
  const SizedBox(height: 6),
  const Text('Try selecting a different date range', style: TextStyle(color: _textGrey, fontSize: 12)),
]));

// ─────────────────────────────────────────────────────────────
//  UTILITY  (unchanged)
// ─────────────────────────────────────────────────────────────
String _fmt(double v) {
  if (v >= 1e7) return '${(v / 1e7).toStringAsFixed(2)}Cr';
  if (v >= 1e5) return '${(v / 1e5).toStringAsFixed(2)}L';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
  return v.toStringAsFixed(0);
}
