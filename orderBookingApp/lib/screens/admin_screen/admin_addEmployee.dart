
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/presentation/providers/network_provider.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';

class AddEmployeeForm extends ConsumerStatefulWidget {
  final bool isEdit;
  final EmployeeLogin? employee;

  const AddEmployeeForm({super.key, this.isEdit = false, this.employee});

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

  int? selectedRegionId;

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
      } else {
        debugPrint("❌ companyId is null – region API not called");
      }
    });

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
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

 Future<void> submitForm() async {
  final isConnected = await ref.read(networkServiceProvider).checkConnection();
  if (!isConnected) {
    // Ensure the global banner reflects the latest status.
    ref.invalidate(networkStatusProvider);
    
    // Show a bottom banner for no connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.wifi_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text("No internet connection!"),
          ],
        ),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  final state = ref.read(employeeloginViewModelProvider);
  if (state.isPhoneNoExists == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mobile number already exists"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

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
      SnackBar(content: Text(state.error!), backgroundColor: Colors.blue),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEdit
              ? "Employee updated successfully"
              : "Employee added successfully",
        ),
        backgroundColor: Colors.green,
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
            Text(
              widget.isEdit ? "Edit Employee" : "Add Employee",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.isEdit ? "Update employee details" : "Create new team member",
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
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
                          const Color(0xFF6366F1).withOpacity(0.1),
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
                             colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isEdit ? "Modify Details" : "Employee Information",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Fill in the required information below",
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
                    label: "Full Name",
                    controller: nameController,
                    icon: Icons.person_outline_rounded,
                    hint: "Enter full name",
                    onSaved: (v) => name = v!,
                  ),

                  _buildModernField(
                    label: "Mobile Number",
                    controller: mobileController,
                    icon: Icons.phone_android_rounded,
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

                  _buildModernField(
                    label: "Email Address",
                    controller: emailController,
                    icon: Icons.email_outlined,
                    hint: "example@company.com",
                    keyboard: TextInputType.emailAddress,
                    onSaved: (v) => email = v!,
                  ),

                  _buildModernField(
                    label: "Address",
                    controller: addressController,
                    icon: Icons.location_on_outlined,
                    hint: "Enter complete address",
                    maxLines: 3,
                    onSaved: (v) => address = v!,
                  ),

                  // Region Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final regionState = ref.watch(
                          regionofflineViewModelProvider,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Region",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            regionState.regionList.when(
                              loading: () => Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text("Loading regions..."),
                                  ],
                                ),
                              ),
                              error: (e, _) => Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[700]),
                                    const SizedBox(width: 12),
                                    const Text("Failed to load regions"),
                                  ],
                                ),
                              ),
                              data: (regions) {
                                return Container(
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
                                  child: DropdownButtonFormField<int>(
                                    value: selectedRegionId,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.grey[600],
                                        size: 22,
                                      ),
                                      hintText: "Select region",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 15,
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
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    items: regions.map((r) {
                                      return DropdownMenuItem<int>(
                                        value: r.regionId,
                                        child: Text(
                                          r.regionName ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
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
                                    dropdownColor: Colors.white,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.grey[600],
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
                    height: 56,
                    child: ElevatedButton(
                      onPressed: employeeState.isPhoneNoExists == true
                          ? null
                          : submitForm,
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
                          gradient: employeeState.isPhoneNoExists == true
                              ? null
                              : const LinearGradient(
                                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isEdit ? Icons.check_circle_outline : Icons.add_circle_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                widget.isEdit ? "Update Employee" : "Add Employee",
                                style: const TextStyle(
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
                color: errorText != null 
                    ? const Color(0xFFE53935) 
                    : Colors.grey[300]!,
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
              maxLines: maxLines,
              maxLength: maxLength,
              inputFormatters: formatter != null ? [formatter] : null,
              onChanged: onChanged,
              validator: (v) {
                if (v == null || v.isEmpty) return "This field is required";
                if (keyboard == TextInputType.emailAddress) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                    return "Please enter a valid email";
                  }
                }
                return null;
              },
              onSaved: onSaved,
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
                counterText: counterText,
                errorText: errorText,
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