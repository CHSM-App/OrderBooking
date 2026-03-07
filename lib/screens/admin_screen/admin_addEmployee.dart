import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booking_app/domain/models/employee.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:order_booking_app/screens/admin_screen/employeelist_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Role context: 2 = SO, 3 = ASM.
  /// Defaults to 2 (SO) when adding a new employee.
  final int roleId;

  const AddEmployeeForm({
    super.key,
    this.isEdit = false,
    this.employee,
    this.roleId = 2,
  });

  @override
  ConsumerState<AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends ConsumerState<AddEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

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

  // ID Proof
  File? idProofFile;
  String? idProofFileName;
  String? idProofType; // 'image' or 'pdf' or 'other'

  // Existing ID Proof (from server when editing)
  String? existingIdProofUrl;
  bool hasExistingIdProof = false;

  // ── Role helpers ──────────────────────────────────────────────────────────
  /// The effective roleId: when editing, use the employee's existing roleId;
  /// when adding, use the passed-in roleId.
  int get _effectiveRoleId =>
      widget.isEdit ? (widget.employee?.roleId ?? widget.roleId) : widget.roleId;

  bool get _isSO => _effectiveRoleId == 2;

  /// Human-readable role label.
  String get _roleLabel => _isSO ? 'SO' : 'ASM';

  /// Full role name for display.
  String get _roleFullName =>
      _isSO ? 'Sales Officer' : 'Area Sales Manager';

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

    // Load existing ID proof if in edit mode
    if (widget.isEdit &&
        widget.employee?.idProof != null &&
        widget.employee!.idProof!.isNotEmpty) {
      existingIdProofUrl = widget.employee!.idProof;
      hasExistingIdProof = true;

      if (existingIdProofUrl!.toLowerCase().endsWith('.pdf')) {
        idProofType = 'pdf';
        idProofFileName = existingIdProofUrl!.split('/').last;
      } else if (existingIdProofUrl!.toLowerCase().contains('.jpg') ||
          existingIdProofUrl!.toLowerCase().contains('.jpeg') ||
          existingIdProofUrl!.toLowerCase().contains('.png')) {
        idProofType = 'image';
        idProofFileName = existingIdProofUrl!.split('/').last;
      } else {
        idProofType = 'other';
        idProofFileName = existingIdProofUrl!.split('/').last;
      }
    }

    Future.microtask(() {
      final companyId = ref.read(adminloginViewModelProvider).companyId;
      if (companyId != null && companyId.isNotEmpty) {
        ref
            .read(regionofflineViewModelProvider.notifier)
            .fetchRegionList(companyId);
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

  // ── Image / File Pickers ──────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          idProofFile = File(photo.path);
          idProofFileName = photo.name;
          idProofType = 'image';
        });
      }
    } catch (e) {
      _showErrorSnackBar("Failed to capture image: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          idProofFile = File(image.path);
          idProofFileName = image.name;
          idProofType = 'image';
        });
      }
    } catch (e) {
      _showErrorSnackBar("Failed to pick image: $e");
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          idProofFile = File(result.files.single.path!);
          idProofFileName = result.files.single.name;
          idProofType = 'pdf';
        });
      }
    } catch (e) {
      _showErrorSnackBar("Failed to pick PDF: $e");
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          idProofFile = File(result.files.single.path!);
          idProofFileName = result.files.single.name;
          final ext = result.files.single.extension?.toLowerCase() ?? '';
          if (['jpg', 'jpeg', 'png'].contains(ext)) {
            idProofType = 'image';
          } else if (ext == 'pdf') {
            idProofType = 'pdf';
          } else {
            idProofType = 'other';
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar("Failed to pick file: $e");
    }
  }

  // ── ID Proof Preview ──────────────────────────────────────────────────────

  void _showIdProofPreview() {
    if (idProofFile == null && !hasExistingIdProof) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: MinimalTheme.cardWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        idProofFileName ?? 'ID Proof',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: MinimalTheme.iconGray,
                    ),
                  ],
                ),
              ),
              if (idProofType == 'image')
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: idProofFile != null
                            ? Image.file(idProofFile!, fit: BoxFit.contain)
                            : Image.network(
                                existingIdProofUrl!,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: MinimalTheme.primaryOrange,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  padding: const EdgeInsets.all(32),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 48,
                                          color: MinimalTheme.errorRed),
                                      SizedBox(height: 16),
                                      Text('Failed to load image',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: MinimalTheme.errorRed)),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                )
              else if (idProofType == 'pdf')
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: MinimalTheme.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.picture_as_pdf,
                            size: 64, color: MinimalTheme.errorRed),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        idProofFileName ?? 'PDF Document',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text('PDF preview not available',
                          style: TextStyle(
                              fontSize: 12, color: MinimalTheme.textGray)),
                      if (hasExistingIdProof && existingIdProofUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.open_in_browser, size: 18),
                            label: const Text('Open in Browser'),
                            style: TextButton.styleFrom(
                              foregroundColor: MinimalTheme.primaryOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: MinimalTheme.iconGray.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.insert_drive_file,
                            size: 64, color: MinimalTheme.iconGray),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        idProofFileName ?? 'Document',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text('File preview not available',
                          style: TextStyle(
                              fontSize: 12, color: MinimalTheme.textGray)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showIdProofOptions();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MinimalTheme.primaryOrange,
                          side: const BorderSide(
                              color: MinimalTheme.primaryOrange),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Change File'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            idProofFile = null;
                            idProofFileName = null;
                            idProofType = null;
                            existingIdProofUrl = null;
                            hasExistingIdProof = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MinimalTheme.errorRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openIdProofViewer() async {
    if (idProofType == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImageViewerPage(
            title: idProofFileName ?? 'Image Preview',
            file: idProofFile,
            imageUrl: existingIdProofUrl,
          ),
        ),
      );
      return;
    }

    if (idProofType == 'pdf') {
      if (idProofFile != null) {
        final opened = await launchUrl(Uri.file(idProofFile!.path),
            mode: LaunchMode.externalApplication);
        if (!opened && mounted) _showErrorSnackBar('Unable to open PDF file');
        return;
      }
      if (existingIdProofUrl != null && existingIdProofUrl!.isNotEmpty) {
        final uri = Uri.tryParse(existingIdProofUrl!);
        if (uri == null) {
          if (mounted) _showErrorSnackBar('Invalid PDF URL');
          return;
        }
        final opened =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened && mounted) _showErrorSnackBar('Unable to open PDF link');
      }
      return;
    }

    _showIdProofPreview();
  }

  void _showIdProofOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: MinimalTheme.cardWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Upload ID Proof",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MinimalTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.camera_alt_outlined,
              title: "Camera",
              subtitle: "Take a photo",
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            _buildOptionTile(
              icon: Icons.photo_library_outlined,
              title: "Gallery",
              subtitle: "Choose from gallery",
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            _buildOptionTile(
              icon: Icons.picture_as_pdf_outlined,
              title: "PDF Document",
              subtitle: "Select PDF file",
              onTap: () {
                Navigator.pop(context);
                _pickPDF();
              },
            ),
            _buildOptionTile(
              icon: Icons.folder_outlined,
              title: "Files",
              subtitle: "Browse files",
              onTap: () {
                Navigator.pop(context);
                _pickFromFiles();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: MinimalTheme.primaryOrange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MinimalTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: MinimalTheme.textGray)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: MinimalTheme.iconGray),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MinimalTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> submitForm() async {
    final isConnected =
        await ref.read(networkServiceProvider).checkConnection();
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No internet connection!")),
      );
      return;
    }

    final state = ref.read(employeeloginViewModelProvider);
    if (state.isPhoneNoExists == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobile number already exists")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    name = _capitalizeFirst(name);
    mobile = mobileController.text.trim();

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
            roleId: _effectiveRoleId, // preserve original role on edit
          )
        : EmployeeLogin(
            empName: name,
            empMobile: mobile,
            empEmail: email,
            empAddress: address,
            regionId: selectedRegionId!,
            companyId: ref.read(adminloginViewModelProvider).companyId,
            adminId: ref.read(adminloginViewModelProvider).userId,
            roleId: _effectiveRoleId, // 2 = SO, 3 = ASM
          );

    try {
      final empId = await ref
          .read(employeeloginViewModelProvider.notifier)
          .addEmployee(employeeToSave);

      if (idProofFile != null) {
        await ref
            .read(employeeloginViewModelProvider.notifier)
            .uploadEmployeeIdProof(idProofFile!, empId);
      }

      await ref.read(employeeloginViewModelProvider.notifier).getEmployeeList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? "$_roleLabel updated successfully"
                : "$_roleLabel added successfully",
          ),
          backgroundColor: MinimalTheme.successGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: MinimalTheme.errorRed,
        ),
      );
    }
  }

  String _capitalizeFirst(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
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
          // e.g. "Add SO"  /  "Edit ASM"
          widget.isEdit ? "Edit $_roleLabel" : "Add $_roleLabel",
          style: const TextStyle(
            color: MinimalTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Subtle role chip in the app bar
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: MinimalTheme.primaryOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _roleLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MinimalTheme.primaryOrange,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Role info banner ─────────────────────────────────────────
              if (!widget.isEdit)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MinimalTheme.primaryOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MinimalTheme.primaryOrange.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MinimalTheme.primaryOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: MinimalTheme.primaryOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adding $_roleLabel',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: MinimalTheme.primaryOrange,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Role: $_roleFullName',
                              style: const TextStyle(
                                fontSize: 12,
                                color: MinimalTheme.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Form Fields ───────────────────────────────────────────────
              _buildField(
                label: "Full Name",
                controller: nameController,
                icon: Icons.person_outline,
                hint: "Enter $_roleLabel full name",
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
                bottomPadding: 6,
                onChanged: (value) {
                  if (value.length == 10) {
                    ref
                        .read(employeeloginViewModelProvider.notifier)
                        .checkMobileExists(
                          value,
                          companyId,
                          widget.employee?.empId ?? 0,
                        );
                  } else {
                    ref
                        .read(employeeloginViewModelProvider.notifier)
                        .setNull();
                  }
                },
                errorText: null,
                onSaved: (v) => mobile = v?.trim() ?? '',
              ),
              if (employeeState.isPhoneNoExists == true &&
                  employeeState.mobileNoStatus == false)
                const Padding(
                  padding: EdgeInsets.only(top: 2, left: 12),
                  child: Text(
                    'Mobile number already exists and active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: MinimalTheme.errorRed,
                    ),
                  ),
                ),
              if (employeeState.isPhoneNoExists == true &&
                  employeeState.mobileNoStatus == true)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 12),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: MinimalTheme.errorRed,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Mobile number exists in history. ',
                        ),
                        TextSpan(
                          text: 'Enable user',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminEmployeesPage(
                                      activeStatus: 1),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
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

              // ── Region Dropdown ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Consumer(
                  builder: (context, ref, _) {
                    final regionState =
                        ref.watch(regionofflineViewModelProvider);

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
                                Text("Loading regions...",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: MinimalTheme.textGray)),
                              ],
                            ),
                          ),
                          error: (e, _) => Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: MinimalTheme.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      MinimalTheme.errorRed.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: MinimalTheme.errorRed, size: 18),
                                SizedBox(width: 12),
                                Text("Failed to load regions",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: MinimalTheme.errorRed)),
                              ],
                            ),
                          ),
                          data: (regions) {
                            if (regions.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      MinimalTheme.errorRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: MinimalTheme.errorRed
                                          .withOpacity(0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: MinimalTheme.errorRed,
                                        size: 18),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "No region available. Please add a region first.",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: MinimalTheme.errorRed),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
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
                                initialValue: selectedRegionId,
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
                                onChanged: (value) =>
                                    setState(() => selectedRegionId = value),
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

              // ── ID Proof Upload ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ID Proof",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: MinimalTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    (idProofFile == null && !hasExistingIdProof)
                        ? InkWell(
                            onTap: _showIdProofOptions,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: MinimalTheme.cardWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  style: BorderStyle.solid,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: MinimalTheme.primaryOrange
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.cloud_upload_outlined,
                                      color: MinimalTheme.primaryOrange,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Upload $_roleLabel ID Proof",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: MinimalTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Camera, Gallery, PDF or Files",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: MinimalTheme.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: _openIdProofViewer,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: MinimalTheme.cardWhite,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  if (idProofType == 'image')
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: idProofFile != null
                                          ? Image.file(idProofFile!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover)
                                          : Image.network(
                                              existingIdProofUrl!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: MinimalTheme
                                                      .successGreen
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.image,
                                                    color: MinimalTheme
                                                        .successGreen,
                                                    size: 24),
                                              ),
                                            ),
                                    )
                                  else
                                    Container(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: MinimalTheme.successGreen
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        idProofType == 'pdf'
                                            ? Icons.picture_as_pdf
                                            : Icons.insert_drive_file,
                                        color: MinimalTheme.successGreen,
                                        size: 24,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          idProofFileName ?? 'File uploaded',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: MinimalTheme.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          "Tap to view",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: MinimalTheme.primaryOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        idProofFile = null;
                                        idProofFileName = null;
                                        idProofType = null;
                                        existingIdProofUrl = null;
                                        hasExistingIdProof = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close,
                                        color: MinimalTheme.errorRed,
                                        size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Submit Button ─────────────────────────────────────────────
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
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // e.g.  "Update SO"  /  "Add ASM"
                  child: Text(
                    widget.isEdit
                        ? "Update $_roleLabel"
                        : "Add $_roleLabel",
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
    double bottomPadding = 16,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
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
                prefixIcon: Icon(icon, color: MinimalTheme.iconGray, size: 20),
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

// ── Image Viewer ─────────────────────────────────────────────────────────────

class _ImageViewerPage extends StatelessWidget {
  final String title;
  final File? file;
  final String? imageUrl;

  const _ImageViewerPage({
    required this.title,
    this.file,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (file != null) {
      body = InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(child: Image.file(file!, fit: BoxFit.contain)),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      body = InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text('Failed to load image',
                  style: TextStyle(color: MinimalTheme.errorRed)),
            ),
          ),
        ),
      );
    } else {
      body = const Center(
        child: Text('Image not available',
            style: TextStyle(color: MinimalTheme.textGray)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Colors.black,
      body: SafeArea(child: body),
    );
  }
}