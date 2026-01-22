import 'package:flutter/material.dart';

class AddRegionPage extends StatefulWidget {
  const AddRegionPage({Key? key}) : super(key: key);

  @override
  State<AddRegionPage> createState() => _AddRegionPageState();
}

class _AddRegionPageState extends State<AddRegionPage> {
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

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final regionName = regionController.text;
      final pincode = pincodeController.text;
      final district = districtController.text;
      final state = stateController.text;

      // TODO: API call / Save logic
      debugPrint("Region: $regionName");
      debugPrint("Pincode: $pincode");
      debugPrint("District: $district");
      debugPrint("State: $state");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Region added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Add New Region",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
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
                      // Region Name
                      _buildLabel("Region Name"),
                      TextFormField(
                        controller: regionController,
                        decoration: _buildInputDecoration(
                          hint: "Enter region name",
                          icon: Icons.location_on_outlined,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Enter region name"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Pincode
                      _buildLabel("Pincode"),
                      TextFormField(
                        controller: pincodeController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          hint: "Enter 6-digit pincode",
                          icon: Icons.pin_drop_outlined,
                        ),
                        validator: (value) => value == null || value.length != 6
                            ? "Enter valid 6-digit pincode"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // District
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

                      // State
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

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 22),
                              SizedBox(width: 8),
                              Text(
                                "Submit Region",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
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
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3), size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      );
}