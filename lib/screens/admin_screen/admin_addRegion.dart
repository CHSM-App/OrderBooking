import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

// ── Brand tokens ──────────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFFE8720C);
const _kPrimaryLight  = Color(0xFFFFF3E8);
const _kSurface       = Color(0xFFFFFFFF);
const _kBackground    = Color(0xFFF5F5F5);
const _kTextPrimary   = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF6B6B6B);
const _kDivider       = Color(0xFFEEEEEE);
const _kRed           = Color(0xFFDC2626);

class AddRegionPage extends ConsumerStatefulWidget {
  final Region? region;

  const AddRegionPage({Key? key, this.region}) : super(key: key);

  @override
  ConsumerState<AddRegionPage> createState() => _AddRegionPageState();
}

class _AddRegionPageState extends ConsumerState<AddRegionPage> {
  final _formKey       = GlobalKey<FormState>();
  final _regionCtrl    = TextEditingController();
  final _pincodeCtrl   = TextEditingController();
  final _districtCtrl  = TextEditingController();
  final _stateCtrl     = TextEditingController();

  bool get _isEdit => widget.region != null;

  @override
  void initState() {
    super.initState();
    _regionCtrl.text   = widget.region?.regionName ?? '';
    _pincodeCtrl.text  = widget.region?.pincode    ?? '';
    _districtCtrl.text = widget.region?.district   ?? '';
    _stateCtrl.text    = widget.region?.state      ?? '';
  }

  @override
  void dispose() {
    _regionCtrl.dispose();
    _pincodeCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final companyId = ref.read(adminloginViewModelProvider).companyId;
    final notifier  = ref.read(regionofflineViewModelProvider.notifier);

    final region = Region(
      localId:    widget.region?.localId ?? const Uuid().v4(),
      regionId:   widget.region?.regionId,
      companyId:  companyId,
      regionName: _capitalizeFirst(_regionCtrl.text),
      pincode:    _pincodeCtrl.text.trim(),
      district:   _capitalizeFirst(_districtCtrl.text),
      state:      _capitalizeFirst(_stateCtrl.text),
      createdBy:  1,
    );

    try {
      final response = await notifier.addRegion(region);
      _snack(
        response['message'] ?? 'Operation completed',
        isError: response['status'] == 0,
      );
      await notifier.fetchRegionList(companyId ?? '');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Something went wrong: $e', isError: true);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
      backgroundColor:
          isError ? _kRed : const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ── Input decoration ───────────────────────────────────────────────────────
  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontSize: 14,
            color: _kTextSecondary,
            fontWeight: FontWeight.w400),
        prefixIcon:
            Icon(icon, size: 20, color: _kTextSecondary),
        filled: true,
        fillColor: _kBackground,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kDivider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kDivider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _kPrimary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kRed)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _kRed, width: 1.5)),
        errorStyle:
            const TextStyle(fontSize: 12, color: _kRed),
        counterText: '',
      );

  String _capitalizeFirst(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(regionofflineViewModelProvider).isLoading;

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Region' : 'Add Region',
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kDivider),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section card ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _kPrimaryLight,
                              borderRadius:
                                  BorderRadius.circular(9),
                            ),
                            child: const Icon(
                                Icons.add_location_alt_outlined,
                                size: 17,
                                color: _kPrimary),
                          ),
                          const SizedBox(width: 10),
                          const Text('Region Information',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kTextPrimary)),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: _kDivider),

                    // Fields
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          // Region Name
                          _FieldLabel(
                              label: 'Region Name',
                              icon: Icons.location_on_outlined),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _regionCtrl,
                            style: const TextStyle(
                                fontSize: 14,
                                color: _kTextPrimary),
                            decoration: _dec(
                                'Enter region name',
                                Icons.location_on_outlined),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Region name is required'
                                    : null,
                          ),
                          const SizedBox(height: 14),

                          // Pincode
                          _FieldLabel(
                              label: 'Pincode',
                              icon: Icons.pin_drop_outlined),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pincodeCtrl,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(
                                fontSize: 14,
                                color: _kTextPrimary),
                            decoration: _dec(
                                '6-digit postal code',
                                Icons.pin_drop_outlined),
                            validator: (v) =>
                                (v == null || v.length != 6)
                                    ? 'Enter valid 6-digit pincode'
                                    : null,
                          ),
                          const SizedBox(height: 14),

                          // District
                          _FieldLabel(
                              label: 'District',
                              icon: Icons.location_city_outlined),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _districtCtrl,
                            style: const TextStyle(
                                fontSize: 14,
                                color: _kTextPrimary),
                            decoration: _dec('Enter district name',
                                Icons.location_city_outlined),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'District is required'
                                    : null,
                          ),
                          const SizedBox(height: 14),

                          // State
                          _FieldLabel(
                              label: 'State',
                              icon: Icons.map_outlined),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _stateCtrl,
                            style: const TextStyle(
                                fontSize: 14,
                                color: _kTextPrimary),
                            decoration: _dec(
                                'Enter state name',
                                Icons.map_outlined),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'State is required'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Submit button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20),
                  label: Text(
                    _isEdit ? 'Update Region' : 'Submit Region',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _kPrimary.withOpacity(0.55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small field label ─────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FieldLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: _kTextSecondary),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary)),
      ],
    );
  }
}
