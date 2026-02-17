import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:order_booking_app/domain/models/product_data.dart';
import 'package:order_booking_app/presentation/providers/usecase_provider.dart';
import 'package:order_booking_app/presentation/viewmodels/product_viewmodel.dart';

// ─────────────────────────────────────────────
//  Provider (wire up to your existing provider)
// ─────────────────────────────────────────────
final productViewModelProvider =
    StateNotifierProvider<ProductViewModel, ProductState>(
  (ref) => ProductViewModel(ref.read(productUsecaseProvider)),
);

// ─────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────
class ProductReportPage extends ConsumerStatefulWidget {
  final String companyId;
  const ProductReportPage({super.key, required this.companyId});

  @override
  ConsumerState<ProductReportPage> createState() => _ProductReportPageState();
}

class _ProductReportPageState extends ConsumerState<ProductReportPage>
    with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ── colour tokens ──────────────────────────
  static const _bg = Color(0xFF0F1117);
  static const _surface = Color(0xFF1A1D27);
  static const _card = Color(0xFF22263A);
  static const _accent = Color(0xFF6C8EFF);
  static const _accentSoft = Color(0xFF2E3A6E);
  static const _green = Color(0xFF4ECBA0);
  static const _textPrimary = Color(0xFFF0F2FF);
  static const _textSecondary = Color(0xFF8891B0);
  static const _divider = Color(0xFF2A2F46);

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productViewModelProvider.notifier).getProductReport(widget.companyId);
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────
  List<_AggregatedProduct> _aggregate(List<ProductData> raw) {
    final filtered = raw.where((p) {
      if (_startDate == null && _endDate == null) return true;
      final d = DateTime(p.orderDate.year, p.orderDate.month, p.orderDate.day);
      if (_startDate != null && d.isBefore(_startDate!)) return false;
      if (_endDate != null && d.isAfter(_endDate!)) return false;
      return true;
    }).toList();

    final map = <String, double>{};
    for (final p in filtered) {
      map[p.productName] = (map[p.productName] ?? 0) + (p.itemTotalPrice ?? 0);
    }

    final result = map.entries
        .map((e) => _AggregatedProduct(name: e.key, total: e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return result;
  }

  double _grandTotal(List<_AggregatedProduct> items) =>
      items.fold(0, (sum, i) => sum + i.total);

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            onPrimary: _textPrimary,
            surface: _surface,
            onSurface: _textPrimary,
          ),
          dialogBackgroundColor: _surface,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
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
  }

  void _clearFilter() => setState(() {
        _startDate = null;
        _endDate = null;
      });

  String _fmt(DateTime? d) =>
      d == null ? 'Select' : DateFormat('dd MMM yyyy').format(d);

  // ── build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: state.productReport == null
            ? _emptyState()
            : state.productReport!.when(
                loading: () => _loadingView(),
                error: (e, _) => _errorView(e.toString()),
                data: (rawList) {
                  final aggregated = _aggregate(rawList);
                  final grand = _grandTotal(aggregated);
                  return _buildBody(aggregated, grand, rawList.length);
                },
              ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPrimary, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Product Report',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'Sales aggregated by product',
              style: TextStyle(color: _textSecondary, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: _textSecondary),
            onPressed: () => ref
                .read(productViewModelProvider.notifier)
                .getProductReport(widget.companyId),
          ),
          const SizedBox(width: 4),
        ],
      );

  Widget _buildBody(
      List<_AggregatedProduct> items, double grand, int rawCount) {
    final hasFilter = _startDate != null || _endDate != null;
    return Column(
      children: [
        _filterPanel(hasFilter),
        if (hasFilter) _activeFilterChip(),
        _summaryBar(items.length, grand, rawCount),
        const SizedBox(height: 4),
        Expanded(
          child: items.isEmpty
              ? _noResultsState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
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

  Widget _filterPanel(bool hasFilter) => Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFilter ? _accent.withOpacity(0.5) : _divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, color: _accent, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'DATE FILTER',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'From',
                    value: _fmt(_startDate),
                    selected: _startDate != null,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: 20,
                    height: 1.5,
                    color: _textSecondary.withOpacity(0.4),
                  ),
                ),
                Expanded(
                  child: _DateButton(
                    label: 'To',
                    value: _fmt(_endDate),
                    selected: _endDate != null,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _activeFilterChip() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: _accent, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    '${_fmt(_startDate)}  →  ${_fmt(_endDate)}',
                    style: const TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _clearFilter,
                    child: const Icon(Icons.close_rounded,
                        color: _accent, size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _summaryBar(int productCount, double grand, int rawCount) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _green.withOpacity(0.12),
              _accent.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _green.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            _SummaryItem(
              icon: Icons.inventory_2_outlined,
              label: 'Products',
              value: productCount.toString(),
              color: _accent,
            ),
            _vDivider(),
            _SummaryItem(
              icon: Icons.receipt_long_outlined,
              label: 'Orders',
              value: rawCount.toString(),
              color: _textSecondary,
            ),
            _vDivider(),
            _SummaryItem(
              icon: Icons.currency_rupee_rounded,
              label: 'Grand Total',
              value: '₹${_formatAmount(grand)}',
              color: _green,
            ),
          ],
        ),
      );

  Widget _vDivider() => Container(
      width: 1, height: 36, color: _divider, margin: const EdgeInsets.symmetric(horizontal: 12));

  // ── states ─────────────────────────────────
  Widget _loadingView() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _accent,
                backgroundColor: _accentSoft,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Loading report…',
                style: TextStyle(color: _textSecondary, fontSize: 13)),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle),
                child:
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Something went wrong',
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textSecondary, fontSize: 12)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _accentSoft,
                    foregroundColor: _accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () => ref
                    .read(productViewModelProvider.notifier)
                    .getProductReport(widget.companyId),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );

  Widget _emptyState() => const Center(
        child: Text('No data', style: TextStyle(color: _textSecondary)),
      );

  Widget _noResultsState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                color: _textSecondary.withOpacity(0.4), size: 56),
            const SizedBox(height: 14),
            const Text('No products in this date range',
                style: TextStyle(color: _textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _clearFilter,
              child: const Text('Clear filter',
                  style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: _accent)),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
//  Product Card
// ─────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final _AggregatedProduct item;
  final int index;
  final double grand;
  const _ProductCard(
      {required this.item, required this.index, required this.grand});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;

  static const _card = Color(0xFF22263A);
  static const _accent = Color(0xFF6C8EFF);
  static const _green = Color(0xFF4ECBA0);
  static const _textPrimary = Color(0xFFF0F2FF);
  static const _textSecondary = Color(0xFF8891B0);
  static const _divider = Color(0xFF2A2F46);

  // rank colours
  static const _rankColors = [
    Color(0xFFFFD86E),
    Color(0xFFB0B8C8),
    Color(0xFFCE9554),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _slide = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.index * 55),
        () => mounted ? _ctrl.forward() : null);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.grand > 0 ? widget.item.total / widget.grand : 0.0;
    final rank = widget.index;
    final rankColor = rank < _rankColors.length ? _rankColors[rank] : _textSecondary;
    final isTop = rank < 3;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _slide.value),
        child: Opacity(opacity: _fade.value, child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTop ? rankColor.withOpacity(0.25) : _divider,
          ),
          boxShadow: [
            if (isTop)
              BoxShadow(
                color: rankColor.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: isTop
                      ? Icon(_rankIcon(rank), color: rankColor, size: 16)
                      : Text(
                          '#${rank + 1}',
                          style: TextStyle(
                              color: rankColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Price chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withOpacity(0.25)),
                  ),
                  child: Text(
                    '₹${_formatAmount(widget.item.total)}',
                    style: const TextStyle(
                      color: _green,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct),
                duration: Duration(milliseconds: 600 + widget.index * 40),
                curve: Curves.easeOut,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 5,
                  backgroundColor: _divider,
                  valueColor: AlwaysStoppedAnimation(
                    isTop ? rankColor : _accent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(pct * 100).toStringAsFixed(1)}% of total sales',
              style: const TextStyle(color: _textSecondary, fontSize: 11),
            ),
          ],
        ),
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

// ─────────────────────────────────────────────
//  Small reusable widgets
// ─────────────────────────────────────────────
class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _DateButton(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  static const _accent = Color(0xFF6C8EFF);
  static const _accentSoft = Color(0xFF2E3A6E);
  static const _textPrimary = Color(0xFFF0F2FF);
  static const _textSecondary = Color(0xFF8891B0);
  static const _divider = Color(0xFF2A2F46);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _accent.withOpacity(0.6) : _divider,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                color: selected ? _accent : _textSecondary, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: selected ? _accent : _textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          color: selected ? _textPrimary : _textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _SummaryItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  static const _textSecondary = Color(0xFF8891B0);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(color: _textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data model (local)
// ─────────────────────────────────────────────
class _AggregatedProduct {
  final String name;
  final double total;
  const _AggregatedProduct({required this.name, required this.total});
}

// ─────────────────────────────────────────────
//  Utility
// ─────────────────────────────────────────────
String _formatAmount(double v) {
  if (v >= 1e7) return '${(v / 1e7).toStringAsFixed(2)}Cr';
  if (v >= 1e5) return '${(v / 1e5).toStringAsFixed(2)}L';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
  return v.toStringAsFixed(2);
}