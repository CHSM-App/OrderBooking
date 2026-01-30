import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/region.dart';

import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

class AddRegionPage extends ConsumerStatefulWidget {
  const AddRegionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddRegionPage> createState() => _AddRegionPageState();
}

class _AddRegionPageState extends ConsumerState<AddRegionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController regionController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  @override
  void dispose() {
    regionController.dispose();
    pincodeController.dispose();
    districtController.dispose();
    stateController.dispose();
    super.dispose();
  }

  // Future<void> submitForm() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final region = Region(
  //     regionName: regionController.text.trim(),
  //     pincode: pincodeController.text.trim(),
  //     district: districtController.text.trim(),
  //     state: stateController.text.trim(),
  //     createdBy: 1, // TODO: replace with logged-in admin ID
  //   );

  //   await ref.read(regionViewModelProvider.notifier).addRegion(region);

  //   final state = ref.read(regionViewModelProvider);

  //   if (state.error != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(state.error!),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text("Region added successfully"),
  //       backgroundColor: Colors.green,
  //     ),
  //   );

  //   Navigator.pop(context);
  // }
Future<void> submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  final region = Region(
    regionName: regionController.text.trim(),
    pincode: pincodeController.text.trim(),
    district: districtController.text.trim(),
    state: stateController.text.trim(),
    createdBy: 1, // Replace with actual admin ID
  );

  final notifier = ref.read(regionofflineViewModelProvider.notifier);
  await notifier.addRegion(region);

  final state = ref.read(regionViewModelProvider);

  if (state is AsyncError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Saved locally, but sync failed: ${state.error}",
        ),
        backgroundColor: Colors.orange,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Region saved successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    final regionState = ref.watch(regionViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Add New Region",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF6F00),
        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Region Name"),
                    TextFormField(
                      controller: regionController,
                      decoration: _buildInputDecoration(
                        hint: "Enter region name",
                        icon: Icons.location_on_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter region name" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Pincode"),
                    TextFormField(
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(
                        hint: "Enter 6-digit pincode",
                        icon: Icons.pin_drop_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.length != 6
                              ? "Enter valid 6-digit pincode"
                              : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("District"),
                    TextFormField(
                      controller: districtController,
                      decoration: _buildInputDecoration(
                        hint: "Enter district name",
                        icon: Icons.location_city_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter district" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("State"),
                    TextFormField(
                      controller: stateController,
                      decoration: _buildInputDecoration(
                        hint: "Enter state name",
                        icon: Icons.map_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter state" : null,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            regionState.isLoading ? null : submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6F00),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: regionState.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    "Submit Region",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color:  const Color.fromARGB(255, 37, 121, 180)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color:  const Color.fromARGB(255, 37, 121, 180),
            width: 2,
          ),
        ),
      );
}
