import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  String productName = '';
  String? productType;
  String? measuringUnit;

  TextEditingController unitController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  final List<String> productTypes = [
    "Beverage",
    "Grocery",
    "Ice Cream",
    "Bakery",
    "Snacks",
  ];

  final List<String> units = [
    "Kilogram",
    "Liter",
    "Piece",
    "Pack",
  ];

  // List to store added entries
  List<Map<String, String>> addedItems = [];

  void addItem() {
    if (unitController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both unit and price"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      addedItems.add({
        "productName": productName,
        "productType": productType ?? '',
        "measuringUnit": measuringUnit ?? '',
        "availableUnit": unitController.text,
        "price": priceController.text,
      });
      unitController.clear();
      priceController.clear();
    });
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      if (addedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least one unit and price"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    unitController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
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
                  Icon(Icons.add_box_rounded, size: 60, color: Colors.white70),
                  SizedBox(height: 8),
                  Text(
                    "Product Information",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),

            // Form
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
                      // Product Name
                      _buildLabel("Product Name"),
                      TextFormField(
                        initialValue: productName,
                        decoration: _buildInputDecoration(
                          hint: "Enter product name",
                          icon: Icons.inventory_2_outlined,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Enter product name" : null,
                        onSaved: (val) => productName = val!,
                        onChanged: (val) => productName = val,
                      ),
                      const SizedBox(height: 16),

                      // Product Type
                      _buildLabel("Product Type"),
                      DropdownButtonFormField2<String>(
                        decoration: _buildDropdownDecoration(icon: Icons.category_outlined),
                        items: productTypes
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        value: productType,
                        onChanged: (val) {
                          setState(() {
                            productType = val;
                          });
                        },
                        validator: (val) =>
                            val == null || val.isEmpty ? "Select product type" : null,
                      ),
                      const SizedBox(height: 16),

                      // Measuring Unit
                      _buildLabel("Measuring Unit"),
                      DropdownButtonFormField2<String>(
                        decoration: _buildDropdownDecoration(icon: Icons.straighten_outlined),
                        items: units
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                        value: measuringUnit,
                        onChanged: (val) {
                          setState(() {
                            measuringUnit = val;
                          });
                        },
                        validator: (val) =>
                            val == null || val.isEmpty ? "Select measuring unit" : null,
                      ),
                      const SizedBox(height: 16),

                      // Available Unit and Price (side by side)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Available Unit"),
                                TextFormField(
                                  controller: unitController,
                                  decoration: _buildInputDecoration(
                                    hint: "Enter unit value",
                                    icon: Icons.straighten_outlined,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Price"),
                                TextFormField(
                                  controller: priceController,
                                  decoration: _buildInputDecoration(
                                    hint: "Enter price (₹)",
                                    icon: Icons.price_change_outlined,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Add Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: addItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Add Unit & Price"),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Display list of added entries
                      if (addedItems.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Added Items",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: addedItems.length,
                              itemBuilder: (context, index) {
                                final item = addedItems[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    title: Text("${item['productName']} (${item['productType']})"),
                                    subtitle: Text(
                                        "Unit: ${item['availableUnit']} ${item['measuringUnit']} • Price: ₹${item['price']}"),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          addedItems.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),
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
                                "Submit Product",
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
      );

  InputDecoration _buildDropdownDecoration({required IconData icon}) =>
      InputDecoration(
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
      );
}
