import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';


class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _regionController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _saveShop() async {
    if (!_formKey.currentState!.validate()) return;

    final shop = ShopDetails(
      shopName: _shopNameController.text,
      address: _addressController.text,
      regionId: int.tryParse(_regionController.text),
      ownerName: _ownerNameController.text,
      mobileNo: _phoneController.text,
      // latitude: 19.0760,
      // longitude: 72.8777,
    );

    await ref.read(shopViewModelProvider.notifier).addShop(shop);

    final state = ref.read(shopViewModelProvider);

    if (state.error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shop added successfully")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add New Shop")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildField("Shop Name", _shopNameController),
            _buildField("Address", _addressController, maxLines: 3),
            _buildField("Region", _regionController),
            _buildField("Owner Name", _ownerNameController),
            _buildField("Phone", _phoneController,
                keyboardType: TextInputType.phone),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: state.isLoading ? null : _saveShop,
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add Shop"),
            ),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _regionController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
