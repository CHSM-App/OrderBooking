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
    // regionController =
    //     TextEditingController(text: widget.employee?.regionId?.toString() ?? '');

    selectedRegionId = widget.employee?.regionId;

    // Future.microtask(() {
    //   ref
    //       .read(regionViewModelProvider.notifier)
    //       .getRegionList(
    //         ref.read(adminloginViewModelProvider).companyId ?? '',
    //       ); // companyId
    // });

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
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.isEdit ? "Edit Employee" : "Add New Employee",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
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
                    // _field(
                    //   label: "Mobile Number",
                    //   controller: mobileController,
                    //   icon: Icons.phone_outlined,
                    //   keyboard: TextInputType.phone,
                    //   maxLength: 10,
                    //   formatter: FilteringTextInputFormatter.digitsOnly,
                    //   onSaved: (v) => mobile = v!,
                    //   counterText: '', // hides 0/10
                    // ),
                    _field(
                      label: "Mobile Number",
                      controller: mobileController,
                      icon: Icons.phone_outlined,
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
                          // reset error while typing
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

                    // _field(
                    //   label: "Region",
                    //   controller: regionController,
                    //   icon: Icons.location_on_outlined,
                    //   onSaved: (v) => region = int.tryParse(v ?? ''),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final regionState = ref.watch(
                            regionofflineViewModelProvider,
                          );

                          return regionState.regionList.when(
                            loading: () => const Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (e, _) =>
                                const Text("Failed to load regions"),
                            data: (regions) {
                              return DropdownButtonFormField<int>(
                                value: selectedRegionId,
                                decoration: InputDecoration(
                                  labelText: "Region",
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: regions.map((r) {
                                  return DropdownMenuItem<int>(
                                    value: r.regionId,
                                    child: Text(r.regionName ?? ''),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedRegionId = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? "Please select region"
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      // child: ElevatedButton(
                      //   onPressed: submitForm,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: const Color(0xFFF57C00),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      //   child: Text(
                      //     widget.isEdit ? "Update Employee" : "Add Employee",
                      //     style: const TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                      child: ElevatedButton(
                        onPressed: employeeState.isPhoneNoExists == true
                            ? null // disable button
                            : submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.isEdit ? "Update Employee" : "Add Employee",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    ValueChanged<String>? onChanged, // ✅ ADD
    String? errorText,
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
        onChanged: onChanged,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        onSaved: onSaved,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          counterText: counterText, // ✅ hide counter
          errorText: errorText,
        ),
      ),
    );
  }
}
