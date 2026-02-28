import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booking_app/domain/models/shop_details.dart';
import 'package:order_booking_app/presentation/providers/viewModel_provider.dart';
import 'package:safe_device/safe_device.dart';
import 'package:uuid/uuid.dart';

class AddShopTheme {
  static const primaryPink = Color(0xFFE8720C);
  static const backgroundGray = Color(0xFFF5F5F5);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF1E1E1E);
  static const textGray = Color(0xFF6B7280);

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryPink.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

class AddShopScreen extends ConsumerStatefulWidget {
  final ShopDetails? initialShop;

  const AddShopScreen({Key? key, this.initialShop}) : super(key: key);

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // ✅ Only store the selected regionId, not the Region object
  int? _selectedRegionId;
  bool _isSaving = false;
  bool _showOtpField = false;
  bool _otpSent = false;

  File? _selfieFile;
  String? _selfieFileName;
  String? _existingSelfiePath;
  bool _existingSelfieFileAvailable = false;

  @override
  void initState() {
    super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _retrieveLostData();
  });
    // Load regions when screen opens
    Future.microtask(() {
      ref.read(regionofflineViewModelProvider.notifier).fetchRegionList(
            ref.read(adminloginViewModelProvider).companyId ?? '',
          );
    });

    if (widget.initialShop != null) {
      final shop = widget.initialShop!;


      _shopNameController.text = shop.shopName ?? '';
      _addressController.text = shop.address ?? '';
      _ownerNameController.text = shop.ownerName ?? '';
      _phoneController.text = shop.mobileNo ?? '';
      // ✅ Store only the ID, resolve the object from the list later
      _selectedRegionId = shop.regionId;
      _existingSelfiePath = shop.shopSelfie;
      if (_existingSelfiePath != null) {
        _existingSelfieFileAvailable =
            File(_existingSelfiePath!).existsSync();
        if (!_existingSelfieFileAvailable) {
          _existingSelfiePath = null;
        }
      }
    }
  }

  void _saveShop() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final isSecure = await _validateDeviceSecurity();
    if (!isSecure) {
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    final position = await _getCurrentLocation();
    final latitude = position?.latitude ?? widget.initialShop?.latitude;
    final longitude = position?.longitude ?? widget.initialShop?.longitude;
    if (latitude == null || longitude == null) {
      if (mounted) {
        _showErrorSnackbar('Location is required to save the shop.');
      }
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    final selfiePath = _selfieFile?.path ?? _existingSelfiePath;
    if (selfiePath == null || selfiePath.isEmpty) {
      if (mounted) {
        _showErrorSnackbar('Shop selfie is required to save the shop.');
      }
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    final shopName = _capitalizeFirst(_shopNameController.text);
    final ownerName = _capitalizeFirst(_ownerNameController.text);
    final shop = ShopDetails(
      localId: const Uuid().v4(),
      shopName: shopName,
      address: _addressController.text,
      regionId: ref.read(adminloginViewModelProvider).regionId!, // ✅ Use the stored regionId
      ownerName: ownerName,
      mobileNo: _phoneController.text,
      shopId: widget.initialShop?.shopId ?? 0,
      createdBy: ref.read(adminloginViewModelProvider).userId,
      updatedAt: DateTime.now(),
      companyId: ref.read(adminloginViewModelProvider).companyId ?? "",
      latitude: latitude,
      longitude: longitude,
      shopSelfie: selfiePath,
    );

    try {
      if (widget.initialShop == null) {
        await ref.read(shopViewModelProvider.notifier).addShop(shop);
      } else {
        // await ref.read(shopViewModelProvider.notifier).updateShop(shop);
      }
      final state = ref.read(shopViewModelProvider);
      if (!mounted) return;

      if (state.error == null) {
        _showSuccessDialog(
          title: widget.initialShop == null ? 'Shop Added' : 'Shop Updated',
          subtitle: widget.initialShop == null
              ? 'Saved successfully'
              : 'Updated successfully',
        );
        await Future.delayed(const Duration(milliseconds: 1800));
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop(); // close dialog
        Navigator.pop(context, true); // return to shops page
      } else {
        _showErrorSnackbar(state.error!);
      }

      await ref.read(shopViewModelProvider.notifier).getEmpShopList(
            ref.read(adminloginViewModelProvider).companyId ?? "",
            ref.read(adminloginViewModelProvider).regionId ?? 0,
          );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final open = await _simpleDialog(
        icon: Icons.location_off_outlined,
        iconColor: AddShopTheme.primaryPink,
        title: 'Location Disabled',
        body: 'Please enable location services to save this shop.',
        confirmLabel: 'Enable',
      );
      if (open) {
        await Geolocator.openLocationSettings();
        await Future.delayed(const Duration(seconds: 1));
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return null;
      } else {
        return null;
      }
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        if (mounted) {
          await _simpleDialog(
            icon: Icons.location_disabled_outlined,
            iconColor: Colors.red,
            title: 'Permission Denied',
            body: 'Location permission is required to save the shop.',
            confirmLabel: 'OK',
            cancelLabel: null,
          );
        }
        return null;
      }
    }

    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        final open = await _simpleDialog(
          icon: Icons.block_outlined,
          iconColor: Colors.red,
          title: 'Permission Required',
          body:
              'Location permission was permanently denied. Enable it in app settings.',
          confirmLabel: 'Settings',
        );
        if (open) await Geolocator.openAppSettings();
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw Exception('GPS signal weak. Please move to open area.');
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
          'Unable to fetch GPS location. Go outside and try again.',
        );
      }
      return null;
    }
  }

  Future<bool> _simpleDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String confirmLabel,
    String? cancelLabel = 'Cancel',
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            title: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                color: AddShopTheme.textGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              if (cancelLabel != null)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(color: AddShopTheme.textGray),
                  ),
                ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AddShopTheme.primaryPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessDialog({
    required String title,
    required String subtitle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SuccessDialog(
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  String _capitalizeFirst(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AddShopTheme.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _validateDeviceSecurity() async {
    bool isJailBroken = await SafeDevice.isJailBroken;
    bool isRealDevice = await SafeDevice.isRealDevice;
    bool isMockLocation = await SafeDevice.isMockLocation;

    if (isJailBroken) {
      _showErrorSnackbar("Rooted device detected. Punch in blocked.");
      return false;
    }

    if (!isRealDevice) {
      _showErrorSnackbar("Emulator detected. Punch in blocked.");
      return false;
    }

    if (isMockLocation) {
      _showErrorSnackbar("Mock location detected. Disable fake GPS.");
      return false;
    }

    return true;
  }

  Future<void> _retrieveLostData() async {
  try {
    final LostDataResponse response = await _imagePicker.retrieveLostData();
    if (response.isEmpty) return;

    if (response.file != null) {
      final file = File(response.file!.path);
      if (await file.exists() && mounted) {
        setState(() {
          _selfieFile = file;
          _selfieFileName = response.file!.name;
        });
      }
    } else if (response.exception != null) {
      if (mounted) {
        _showErrorSnackbar('Failed to recover photo: ${response.exception!.code}');
      }
    }
  } catch (e) {
    // Silently ignore — no lost data
  }
}

// ✅ UPDATED camera method with better error handling
Future<void> _pickSelfieFromCamera() async {
  try {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo != null && mounted) {
      final file = File(photo.path);
      if (await file.exists()) {
        setState(() {
          _selfieFile = file;
          _selfieFileName = photo.name;
        });
      } else {
        // ✅ File not found — likely process death occurred, retrieveLostData will handle it
        if (mounted) _showErrorSnackbar("Photo not found. Trying to recover...");
        await _retrieveLostData();
      }
    }
  } on PlatformException catch (e) {
    if (mounted) _showErrorSnackbar("Camera error: ${e.message ?? e.code}");
  } catch (e) {
    if (mounted) _showErrorSnackbar("Failed to capture selfie: $e");
  }
}
  void _openSelfieViewer() {
    final File? file = _selfieFile ??
        (_existingSelfiePath != null ? File(_existingSelfiePath!) : null);
    if (file == null || !file.existsSync()) {
      _showErrorSnackbar('Selfie not available');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewerPage(
          title: _selfieFileName ?? 'Shop Selfie',
          file: file,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regionState = ref.watch(regionofflineViewModelProvider).regionList;
    final shopState = ref.watch(shopViewModelProvider);

    return Scaffold(
      backgroundColor: AddShopTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.initialShop == null ? "Add New Shop" : "Update Shop",
          style: TextStyle(
              color: AddShopTheme.textDark, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: regionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildCard(
                      title: "Shop Information",
                      children: [
                        _buildTextField(
                            controller: _shopNameController,
                            label: "Shop Name"),
                        const SizedBox(height: 14),
                        _buildTextField(
                            controller: _addressController,
                            label: "Address",
                            maxLines: 3),
                        const SizedBox(height: 14),

                        /// ✅ FIXED REGION DROPDOWN
                        /* regionState.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Text(
                            'Failed to load regions: $e',
                            style: const TextStyle(color: Colors.red),
                          ),
                          data: (regions) {
                            // ✅ Resolve the Region object from the SAME list
                            // that will be used for items — guarantees same instance
                            Region? selectedRegion;
                            if (_selectedRegionId != null) {
                              try {
                                selectedRegion = regions.firstWhere(
                                  (r) => r.regionId == _selectedRegionId,
                                );
                              } catch (_) {
                                selectedRegion = null;
                              }
                            }

                            return DropdownButtonFormField<Region>(
                              initialValue: selectedRegion, // ✅ Same instance as item
                              decoration: InputDecoration(
                                labelText: 'Region Name',
                                prefixIcon:
                                    const Icon(Icons.map_outlined),
                                filled: true,
                                fillColor: AddShopTheme.backgroundGray,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AddShopTheme.primaryPink,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              items: regions
                                  .map(
                                    (region) => DropdownMenuItem<Region>(
                                      value: region,
                                      child: Text(region.regionName ?? ''),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  // ✅ Store only the ID, not the object
                                  _selectedRegionId = value?.regionId;
                                });

                              },
                              validator: (value) =>
                                  value == null ? "Region is required" : null,
                            );
                          },
                        ), */
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildCard(
                      title: "Owner Information",
                      children: [
                        _buildTextField(
                            controller: _ownerNameController,
                            label: "Owner Name"),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showOtpField = true;
                                _otpSent = true;
                              });
                              _showErrorSnackbar('OTP sent (demo)');
                            },
                            icon: const Icon(Icons.sms_outlined, size: 16),
                            label: const Text(
                              "Send OTP",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AddShopTheme.primaryPink,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ),
                        if (_showOtpField) ...[
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _otpController,
                            label: "Enter OTP",
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                          if (_otpSent)
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "OTP sent",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AddShopTheme.textGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 30),

                    _buildCard(
                      title: "Shop Selfie",
                      children: [
                        (_selfieFile == null && !_existingSelfieFileAvailable)
                            ? InkWell(
                                onTap: _pickSelfieFromCamera,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AddShopTheme.cardWhite,
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
                                          color: AddShopTheme.primaryPink
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: AddShopTheme.primaryPink,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Add Shop Selfie",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AddShopTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Camera",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AddShopTheme.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: _openSelfieViewer,
                                onLongPress: _pickSelfieFromCamera,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AddShopTheme.cardWhite,
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
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _selfieFile != null
                                            ? Image.file(
                                                _selfieFile!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(_existingSelfiePath!),
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selfieFileName ??
                                                  (_existingSelfieFileAvailable
                                                      ? 'Saved selfie'
                                                      : 'Selfie captured'),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AddShopTheme.textDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              "Tap to view, long-press to change",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AddShopTheme.primaryPink,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _selfieFile = null;
                                            _selfieFileName = null;
                                            _existingSelfiePath = null;
                                            _existingSelfieFileAvailable = false;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_isSaving || shopState.isLoading) ? null : _saveShop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AddShopTheme.primaryPink,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: (_isSaving || shopState.isLoading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save Shop",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AddShopTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AddShopTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...children
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: label == "Phone Number"
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        if (label == "Phone Number" && value.length < 10) {
          return "Enter valid phone number";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AddShopTheme.backgroundGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AddShopTheme.primaryPink,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AddShopTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AddShopTheme.primaryPink.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AddShopTheme.primaryPink,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AddShopTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AddShopTheme.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewerPage extends StatelessWidget {
  final String title;
  final File file;

  const _ImageViewerPage({
    required this.title,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.file(file, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
