import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/login_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

class MinimalTheme {
  static const primaryOrange = Color(0xFFFF8C42);
  static const backgroundGray = Color(0xFFF5F5F5);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF2D2D2D);
  static const textGray = Color(0xFF6B7280);
  static const iconGray = Color(0xFF9CA3AF);
  static const successGreen = Color(0xFF10B981);
  static const errorRed = Color(0xFFEF4444);
}

class AddAdminPage extends ConsumerStatefulWidget {
  final AdminLogin? admin;

  const AddAdminPage({super.key, this.admin});

  @override
  ConsumerState<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends ConsumerState<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();

    // If admin object received → Edit Mode
    if (widget.admin != null) {
      isEdit = true;

      _nameController.text = widget.admin!.adminName ?? '';
      _mobileController.text = widget.admin!.mobileNo ?? '';
      _emailController.text = widget.admin!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  final body = AdminLogin(
    adminId: isEdit ? widget.admin!.adminId : 0,
    adminName: _nameController.text,
    mobileNo: _mobileController.text,
    email: _emailController.text,
    companyId: ref.read(adminloginViewModelProvider).companyId,
    role_id: 1,
    isSuperadmin: false,
  );

  final result = await ref
      .read(adminloginViewModelProvider.notifier)
      .addUpdateAdmin(body); 

  if (!mounted) return;

  final message = result["message"];
  final success = result["success"] == 1;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          success ? MinimalTheme.successGreen : MinimalTheme.errorRed,
    ),
  );

  if (success) {
    await ref
        .read(adminloginViewModelProvider.notifier)
        .fetchAdmins(
          ref.read(adminloginViewModelProvider).companyId ?? '',
        );

    Navigator.pop(context);
  }
}
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminloginViewModelProvider);

    return Scaffold(
      backgroundColor: MinimalTheme.backgroundGray,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Admin" : "Add Admin"),
        backgroundColor: MinimalTheme.cardWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 12),

              /// Mobile
              TextFormField(
                controller: _mobileController,
                enabled: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: "Mobile"),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter mobile";
                  }
                  if (v.length < 10) {
                    return "Invalid mobile";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              /// Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter email";
                  }
                  if (!v.contains("@")) {
                    return "Invalid email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              /// Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdit ? "Update Admin" : "Add Admin"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}