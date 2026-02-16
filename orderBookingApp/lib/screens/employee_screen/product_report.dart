
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/domain/models/product_data.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

class ProductReportPage extends ConsumerStatefulWidget {
  final String companyId;
  const ProductReportPage({super.key, required this.companyId});

  @override
  ConsumerState<ProductReportPage> createState() => _ProductReportPageState();
}

class _ProductReportPageState extends ConsumerState<ProductReportPage> {
  String _selectedFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    Future(() {
      ref.read(productViewModelProvider.notifier).getProductReport(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);
    final products = state.productReport?.value ?? [];
    // Apply local filtering
    final filteredProducts = _applyFilter(products.cast<ProductData>());
    return Scaffold(
      appBar: AppBar(title: const Text('Product-wise Report')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildFilterSection(),
                    ),
                    Expanded(child: _buildProductList(filteredProducts)),
                  ],
                ),
    );
  }

  /// Local filtering based on selected filter
  List<ProductData> _applyFilter(List<ProductData> products) {
    final now = DateTime.now();
    List<ProductData> filtered = [];

    for (var product in products) {
      final dates = product.orderDates.map((d) => d.toLocal()).toList();
      List<DateTime> filteredDates = [];

      switch (_selectedFilter) {
        case 'today':
          filteredDates = dates
              .where((d) =>
                  d.year == now.year && d.month == now.month && d.day == now.day)
              .toList();
          break;
        case 'monthly':
          filteredDates =
              dates.where((d) => d.year == now.year && d.month == now.month).toList();
          break;
        case 'yearly':
          filteredDates = dates.where((d) => d.year == now.year).toList();
          break;
        case 'custom':
          if (_startDate != null && _endDate != null) {
            final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
            final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
            filteredDates = dates.where((d) => !d.isBefore(start) && !d.isAfter(end)).toList();
          }
          break;
        case 'all':
        default:
          filteredDates = dates;
      }

      if (filteredDates.isNotEmpty) {
        final filteredSales = (product.totalSales / dates.length) * filteredDates.length;
        filtered.add(ProductData(
          productName: product.productName,
          totalSales: filteredSales,
          orderDates: filteredDates,
        ));
      }
    }

    filtered.sort((a, b) => b.totalSales.compareTo(a.totalSales));
    return filtered;
  }

  /// Product list with expandable order dates
  Widget _buildProductList(List<ProductData> products) {
    if (products.isEmpty) return const Center(child: Text('No products found'));

    final totalSales = products.fold<double>(0, (sum, e) => sum + e.totalSales);

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final percentage = totalSales > 0
            ? (product.totalSales / totalSales * 100)
            : 0.0;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            title:
                Text('${product.productName} - ₹${product.totalSales.toStringAsFixed(2)}'),
            subtitle: Text('${product.orderDates.length} orders (${percentage.toStringAsFixed(1)}%)'),
            children: product.orderDates
                .map((d) => ListTile(
                      leading: const Icon(Icons.calendar_today, size: 16),
                      title: Text(DateFormat('dd/MM/yyyy').format(d)),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  /// Filter chips UI
  Widget _buildFilterSection() {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip('All', 'all'),
        _buildFilterChip('Today', 'today'),
        _buildFilterChip('Month', 'monthly'),
        _buildFilterChip('Year', 'yearly'),
        _buildCustomDateChip(),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  /// Custom date picker chip
  Widget _buildCustomDateChip() {
    final label = (_selectedFilter == 'custom' && _startDate != null && _endDate != null)
        ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
        : 'Custom';

    return ActionChip(
      label: Text(label),
      onPressed: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          setState(() {
            _startDate = picked.start;
            _endDate = picked.end;
            _selectedFilter = 'custom';
          });
        }
      },
    );
  }
}
