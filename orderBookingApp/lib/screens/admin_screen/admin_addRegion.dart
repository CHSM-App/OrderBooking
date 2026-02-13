
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:uuid/uuid.dart';

class AddRegionPage extends ConsumerStatefulWidget {
  final Region? region; // Optional for edit

  const AddRegionPage({Key? key, this.region}) : super(key: key);
  @override
  ConsumerState<AddRegionPage> createState() => _AddRegionPageState();
}

class _AddRegionPageState extends ConsumerState<AddRegionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController regionController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

@override
void initState() {
  super.initState();

  regionController.text = widget.region?.regionName ?? '';
  pincodeController.text = widget.region?.pincode ?? '';
  districtController.text = widget.region?.district ?? '';
  stateController.text = widget.region?.state ?? '';

  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
  );

  _slideAnimation =
      Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ),
  );

  _animationController.forward();
}

  @override
  void dispose() {
    regionController.dispose();
    pincodeController.dispose();
    districtController.dispose();
    stateController.dispose();
    _animationController.dispose();
    super.dispose();
  }


  Future<void> submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  final companyId = ref.read(adminloginViewModelProvider).companyId;
  final notifier = ref.read(regionofflineViewModelProvider.notifier);

  // Create region object
  final region = Region(
    localId: widget.region?.localId ?? Uuid().v4(),
    regionId: widget.region?.regionId, // Use existing id for edit
    companyId: companyId,
    regionName: regionController.text.trim(),
    pincode: pincodeController.text.trim(),
    district: districtController.text.trim(),
    state: stateController.text.trim(),
    createdBy: 1,
  );

  try {
    // Add or update
    final response = await notifier.addRegion(region);

    // Show API message (from your Node.js update/insert API)
    _showSnackBar(
      response['message'] ?? 'Operation completed',
      isError: response['status'] == 0,
    );

    // Refresh list
    await notifier.fetchRegionList(companyId ?? "");

    if (!mounted) return;

    Navigator.pop(context);
  } catch (e) {
    _showSnackBar(
      "Something went wrong: $e",
      isError: true,
    );
  }
}


  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFFB8C00) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regionState = ref.watch(regionofflineViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Region",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Create a new geographical region",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A5568), Color(0xFF4A5568)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4A5568).withOpacity(0.1),
                          const Color(0xFF8B5CF6).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A5568), Color(0xFF4A5568)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_location_alt_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Region Information",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Enter location details below",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Form Fields
                  _buildModernField(
                    label: "Region Name",
                    controller: regionController,
                    icon: Icons.location_on_outlined,
                    hint: "Enter region name",
                    validator: (value) => value == null || value.isEmpty
                        ? "Region name is required"
                        : null,
                  ),

                  _buildModernField(
                    label: "Pincode",
                    controller: pincodeController,
                    icon: Icons.pin_drop_outlined,
                    hint: "6-digit postal code",
                    keyboard: TextInputType.number,
                    maxLength: 6,
                    validator: (value) => value == null || value.length != 6
                        ? "Enter valid 6-digit pincode"
                        : null,
                  ),

                  _buildModernField(
                    label: "District",
                    controller: districtController,
                    icon: Icons.location_city_outlined,
                    hint: "Enter district name",
                    validator: (value) => value == null || value.isEmpty
                        ? "District is required"
                        : null,
                  ),

                  _buildModernField(
                    label: "State",
                    controller: stateController,
                    icon: Icons.map_outlined,
                    hint: "Enter state name",
                    validator: (value) =>
                        value == null || value.isEmpty ? "State is required" : null,
                  ),

                  const SizedBox(height: 8),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: regionState.isLoading ? null : submitForm,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: regionState.isLoading
                              ? null
                              : const LinearGradient(
                                  colors: [Color(0xFF4A5568), Color(0xFF4A5568)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: regionState.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Submit Region",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey[300]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              maxLength: maxLength,
              validator: validator,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  icon,
                  color: Colors.grey[600],
                  size: 22,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE53935),
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE53935),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                counterText: maxLength != null ? '' : null,
                errorStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}