import 'package:flutter/material.dart';


class AddEmployeeForm extends StatefulWidget {
  const AddEmployeeForm({super.key});

  @override
  State<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String mobile = '';
  String address = '';
  String email = '';
  String? region;
  // PlatformFile? idProof;

  final List<String> regions = [
    "Sindhudurg",
    "Ratnagiri",
    "Kolhapur",
    "Goa",
    "Pune"
  ];

  Future<void> pickIDProof() async {
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf'],
    // );
    // if (result != null) {
    //   setState(() {
    //     idProof = result.files.first;
    //   });
    // }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      if (region == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please enter a region"),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
      // if (idProof == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: const Text("Please select ID proof PDF"),
      //       backgroundColor: Colors.orange[700],
      //       behavior: SnackBarBehavior.floating,
      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //     ),
      //   );
      //   return;
      // }

      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text("Employee $name added successfully!"),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          "Add New Employee",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header decoration
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: const Column(
                children: [
                  Icon(
                    Icons.person_add_rounded,
                    size: 60,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Employee Information",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            // Form container
            Padding(
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
                      // Name
                      _buildLabel("Full Name"),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          hint: "Enter employee name",
                          icon: Icons.person_outline,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter name" : null,
                        onSaved: (val) => name = val!,
                      ),
                      const SizedBox(height: 20),

                      // Mobile
                      _buildLabel("Mobile Number"),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          hint: "Enter mobile number",
                          icon: Icons.phone_outlined,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter mobile number" : null,
                        onSaved: (val) => mobile = val!,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildLabel("Email Address"),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          hint: "Enter email address",
                          icon: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter email" : null,
                        onSaved: (val) => email = val!,
                      ),
                      const SizedBox(height: 20),

                      // Address
                      _buildLabel("Address"),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          hint: "Enter complete address",
                          icon: Icons.home_outlined,
                        ),
                        maxLines: 3,
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter address" : null,
                        onSaved: (val) => address = val!,
                      ),
                      const SizedBox(height: 20),

                      // Region
                      _buildLabel("Region"),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          hint: "Enter region to assign",
                          icon: Icons.location_on_outlined,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter region to assign" : null,
                        onSaved: (val) => region = val!,
                      ),
                      const SizedBox(height: 20),

                      // ID Proof
                      _buildLabel("ID Proof (PDF)"),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          // border: Border.all(
                          //   color: idProof != null
                          //       ? const Color(0xFF2196F3)
                          //       : Colors.grey[300]!,
                          //   width: 1.5,
                          // ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // child: Icon(
                              //   idProof != null
                              //       ? Icons.picture_as_pdf
                              //       : Icons.upload_file_outlined,
                              //   color: const Color(0xFF2196F3),
                              //   size: 28,
                              // ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // children: [
                                //   Text(
                                //     idProof != null
                                //         ? idProof!.name
                                //         : "No file selected",
                                //     style: TextStyle(
                                //       fontSize: 14,
                                //       fontWeight: idProof != null
                                //           ? FontWeight.w500
                                //           : FontWeight.normal,
                                //       color: idProof != null
                                //           ? Colors.black87
                                //           : Colors.grey[600],
                                //     ),
                                //     overflow: TextOverflow.ellipsis,
                                //   ),
                                //   if (idProof != null)
                                //     Text(
                                //       "${(idProof!.size / 1024).toStringAsFixed(1)} KB",
                                //       style: TextStyle(
                                //         fontSize: 12,
                                //         color: Colors.grey[600],
                                //       ),
                                //     ),
                                // ],
                              ),
                            ),
                            TextButton(
                              onPressed: pickIDProof,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF2196F3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                // idProof != null ? "Change" : "Browse",
                                  // style: const TextStyle(
                                  // fontWeight: FontWeight.w600,
                                // ),
                                  "Browse"
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

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
                                "Add Employee",
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
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF2196F3),
        size: 22,
      ),
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
        borderSide: const BorderSide(
          color: Color(0xFF2196F3),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }
}