import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

class AddEmployeeForm extends ConsumerStatefulWidget {
  final bool isEdit;
  final EmployeeLogin? employee;

  const AddEmployeeForm({
    super.key,
    this.isEdit = false,
    this.employee,
  });

  @override
  ConsumerState<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends ConsumerState<AddEmployeeForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController regionController;

  String name = '';
  String mobile = '';
  String address = '';
  String email = '';
  int? region;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.employee?.empName ?? '');
    mobileController =
        TextEditingController(text: widget.employee?.empMobile ?? '');
    emailController =
        TextEditingController(text: widget.employee?.empEmail ?? '');
    addressController =
        TextEditingController(text: widget.employee?.empAddress ?? '');
    regionController =
        TextEditingController(text: widget.employee?.regionId?.toString() ?? '');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    regionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Create updated/new Employee object
    final employeeToSave = widget.isEdit
        ? EmployeeLogin(
            empId: widget.employee!.empId, // important for update
            empName: name,
            empMobile: mobile,
            empEmail: email,
            empAddress: address,
            regionId: region ?? widget.employee!.regionId,
            roleId: widget.employee!.roleId,
          )
        : EmployeeLogin(
            empName: name,
            empMobile: mobile,
            empEmail: email,
            empAddress: address,
            regionId: region ?? 1,
            roleId: 2,
          );

    await ref
        .read(employeeloginViewModelProvider.notifier)
        .addEmployee(employeeToSave);

    final state = ref.read(employeeloginViewModelProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit
              ? "Employee updated successfully"
              : "Employee added successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.isEdit ? "Edit Employee" : "Add New Employee",
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF57C00),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      label: "Full Name",
                      controller: nameController,
                      icon: Icons.person_outline,
                      onSaved: (v) => name = v!,
                    ),
                    _field(
                      label: "Mobile Number",
                      controller: mobileController,
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone,
                      maxLength: 10,
                      formatter: FilteringTextInputFormatter.digitsOnly,
                      onSaved: (v) => mobile = v!,
                      counterText: '', // hides 0/10
                    ),
                    _field(
                      label: "Email Address",
                      controller: emailController,
                      icon: Icons.email_outlined,
                      keyboard: TextInputType.emailAddress,
                      onSaved: (v) => email = v!,
                    ),
                    _field(
                      label: "Address",
                      controller: addressController,
                      icon: Icons.home_outlined,
                      maxLines: 3,
                      onSaved: (v) => address = v!,
                    ),
                    _field(
                      label: "Region",
                      controller: regionController,
                      icon: Icons.location_on_outlined,
                      onSaved: (v) => region = int.tryParse(v ?? ''),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          widget.isEdit ? "Update Employee" : "Add Employee",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboard = TextInputType.text,
    TextInputFormatter? formatter,
    required Function(String?) onSaved,
    String? counterText, // optional to hide maxLength counter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: formatter != null ? [formatter] : null,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          counterText: counterText, // ✅ hide counter
        ),
      ),
    );
  }
}
