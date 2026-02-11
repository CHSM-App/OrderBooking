import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

// Minimal Theme Colors
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

class AddEmployeeForm extends ConsumerStatefulWidget {
  final bool isEdit;
  final EmployeeLogin? employee;

  const AddEmployeeForm({super.key, this.isEdit = false, this.employee});

  @override
  ConsumerState<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends ConsumerState<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  int? selectedRegionId;

  String name = '';
  String mobile = '';
  String address = '';
  String email = '';
  int? region;

  @override
  void initState() {
    super.initState();

    selectedRegionId = widget.employee?.regionId;

    nameController = TextEditingController(
      text: widget.employee?.empName ?? '',
    );
    mobileController = TextEditingController(
      text: widget.employee?.empMobile ?? '',
    );
    emailController = TextEditingController(
      text: widget.employee?.empEmail ?? '',
    );
    addressController = TextEditingController(
      text: widget.employee?.empAddress ?? '',
    );

    selectedRegionId = widget.employee?.regionId;

    Future.microtask(() {
      final companyId = ref.read(adminloginViewModelProvider).companyId;

      if (companyId != null && companyId.isNotEmpty) {
        ref
            .read(regionofflineViewModelProvider.notifier)
            .fetchRegions(companyId);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    final isConnected = await ref.read(networkServiceProvider).checkConnection();
    if (!isConnected) {
      ref.invalidate(networkStatusProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text("No internet connection!"),
            ],
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final state = ref.read(employeeloginViewModelProvider);
    if (state.isPhoneNoExists == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mobile number already exists"),
          backgroundColor: MinimalTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final employeeToSave = widget.isEdit
        ? EmployeeLogin(
            empId: widget.employee!.empId,
            empName: name,
            empMobile: mobile,
            empEmail: email,
            empAddress: address,
            companyId: ref.read(adminloginViewModelProvider).companyId,
            adminId: ref.read(adminloginViewModelProvider).userId,
            regionId: selectedRegionId!,
            roleId: widget.employee!.roleId,
          )
        : EmployeeLogin(
            empName: name,
            empMobile: mobile,
            empEmail: email,
            empAddress: address,
            regionId: selectedRegionId!,
            companyId: ref.read(adminloginViewModelProvider).companyId,
            adminId: ref.read(adminloginViewModelProvider).userId,
            roleId: 2,
          );

    await ref
        .read(employeeloginViewModelProvider.notifier)
        .addEmployee(employeeToSave);

    await ref
        .read(employeeloginViewModelProvider.notifier)
        .getEmployeeList(ref.read(adminloginViewModelProvider).companyId ?? '');

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: MinimalTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? "Employee updated successfully"
                : "Employee added successfully",
          ),
          backgroundColor: MinimalTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeloginViewModelProvider);
    final companyId = ref.read(adminloginViewModelProvider).companyId ?? '';

    return Scaffold(
      backgroundColor: MinimalTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: MinimalTheme.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MinimalTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? "Edit Employee" : "Add Employee",
          style: const TextStyle(
            color: MinimalTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Fields
              _buildField(
                label: "Full Name",
                controller: nameController,
                icon: Icons.person_outline,
                hint: "Enter full name",
                onSaved: (v) => name = v!,
              ),

              _buildField(
                label: "Mobile Number",
                controller: mobileController,
                icon: Icons.phone_outlined,
                hint: "10 digit mobile number",
                keyboard: TextInputType.phone,
                maxLength: 10,
                formatter: FilteringTextInputFormatter.digitsOnly,
                counterText: '',
                onChanged: (value) {
                  if (value.length == 10) {
                    ref
                        .read(employeeloginViewModelProvider.notifier)
                        .checkMobileExists(value, companyId);
                  } else {
                    ref
                        .read(employeeloginViewModelProvider.notifier)
                        // ignore: invalid_use_of_protected_member
                        .state = employeeState.copyWith(
                      isPhoneNoExists: null,
                    );
                  }
                },
                errorText: employeeState.isPhoneNoExists == true
                    ? 'Mobile number already exists'
                    : null,
                onSaved: (v) => mobile = v!,
              ),

              _buildField(
                label: "Email Address",
                controller: emailController,
                icon: Icons.email_outlined,
                hint: "example@company.com",
                keyboard: TextInputType.emailAddress,
                onSaved: (v) => email = v!,
              ),

              _buildField(
                label: "Address",
                controller: addressController,
                icon: Icons.location_on_outlined,
                hint: "Enter complete address",
                maxLines: 3,
                onSaved: (v) => address = v!,
              ),

              // Region Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Consumer(
                  builder: (context, ref, _) {
                    final regionState = ref.watch(
                      regionofflineViewModelProvider,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Region",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: MinimalTheme.textGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        regionState.regionList.when(
                          loading: () => Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: MinimalTheme.cardWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: MinimalTheme.primaryOrange,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Loading regions...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: MinimalTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          error: (e, _) => Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: MinimalTheme.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: MinimalTheme.errorRed.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: MinimalTheme.errorRed,
                                  size: 18,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Failed to load regions",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: MinimalTheme.errorRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          data: (regions) {
                            return Container(
                              decoration: BoxDecoration(
                                color: MinimalTheme.cardWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<int>(
                                value: selectedRegionId,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    color: MinimalTheme.iconGray,
                                    size: 20,
                                  ),
                                  hintText: "Select region",
                                  hintStyle: const TextStyle(
                                    color: MinimalTheme.textGray,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: MinimalTheme.primaryOrange,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: MinimalTheme.errorRed,
                                      width: 1.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: MinimalTheme.cardWhite,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                items: regions.map((r) {
                                  return DropdownMenuItem<int>(
                                    value: r.regionId,
                                    child: Text(
                                      r.regionName ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: MinimalTheme.textDark,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedRegionId = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? "Please select a region"
                                    : null,
                                dropdownColor: MinimalTheme.cardWhite,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: MinimalTheme.iconGray,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: employeeState.isPhoneNoExists == true
                      ? null
                      : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MinimalTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(
                    widget.isEdit ? "Update Employee" : "Add Employee",
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboard = TextInputType.text,
    TextInputFormatter? formatter,
    required Function(String?) onSaved,
    ValueChanged<String>? onChanged,
    String? errorText,
    String? counterText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MinimalTheme.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: MinimalTheme.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? MinimalTheme.errorRed
                    : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              maxLines: maxLines,
              maxLength: maxLength,
              inputFormatters: formatter != null ? [formatter] : null,
              onChanged: onChanged,
              validator: (v) {
                if (v == null || v.isEmpty) return "This field is required";
                if (keyboard == TextInputType.emailAddress) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(v)) {
                    return "Please enter a valid email";
                  }
                }
                return null;
              },
              onSaved: onSaved,
              style: const TextStyle(
                fontSize: 14,
                color: MinimalTheme.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: MinimalTheme.textGray,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  icon,
                  color: MinimalTheme.iconGray,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: MinimalTheme.primaryOrange,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: MinimalTheme.errorRed,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: MinimalTheme.errorRed,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: MinimalTheme.cardWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                counterText: counterText,
                errorText: errorText,
                errorStyle: const TextStyle(
                  fontSize: 11,
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