// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class EditProfilePage extends StatefulWidget {
//   final String name;
//   final String phone;
//   final String email;
//   final String address;
//   final Function(Map<String, String>) onSave;

//   const EditProfilePage({
//     Key? key,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.address,
//     required this.onSave,
//   }) : super(key: key);

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   late TextEditingController _nameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _emailController;
//   late TextEditingController _addressController;
//   final _formKey = GlobalKey<FormState>();
//   bool isSaving = false;

//   @override
//   void initState() {
  
//     super.initState();
//     _nameController = TextEditingController(text: widget.name);
//     _phoneController = TextEditingController(text: widget.phone);
//     _emailController = TextEditingController(text: widget.email);
//     _addressController = TextEditingController(text: widget.address);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       isSaving = true;
//     });

//     // Simulate API call
//     await Future.delayed(const Duration(milliseconds: 1000));

//     if (mounted) {
//       widget.onSave({
//         'name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'email': _emailController.text.trim(),
//         'address': _addressController.text.trim(),
        
//       });

//       Navigator.pop(context);
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: const [
//               Icon(Icons.check_circle, color: Colors.white),
//               SizedBox(width: 12),
//               Text(
//                 'Profile updated successfully',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//           backgroundColor: const Color(0xFF2E7D32),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     }

//     if (mounted) {
//       setState(() {
//         isSaving = false;
//       });
//     }
//   }

//   String _getInitials(String name) {
//     final parts = name.trim().split(' ');
//     if (parts.isEmpty) return 'NA';
//     if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
//     return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           "Edit Profile",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFFFF5722),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 30),
            
//             // Profile Image Section
//             _buildProfileSection(),
            
//             const SizedBox(height: 30),

//             // Form Fields Container
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 15,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     _buildTextField(
//                       controller: _nameController,
//                       label: "Full Name",
//                       icon: Icons.person_outline,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your name';
//                         }
//                         if (value.length < 3) {
//                           return 'Name must be at least 3 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
                    
//                     _buildTextField(
//                       controller: _phoneController,
//                       label: "Phone Number",
//                       icon: Icons.phone_outlined,
//                       keyboardType: TextInputType.phone,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(10),
//                       ],
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your phone number';
//                         }
//                         if (value.length != 10) {
//                           return 'Please enter a valid 10-digit number';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
                    
//                     _buildTextField(
//                       controller: _emailController,
//                       label: "Email Address",
//                       icon: Icons.email_outlined,
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         final emailRegex = RegExp(
//                           r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//                         );
//                         if (!emailRegex.hasMatch(value)) {
//                           return 'Please enter a valid email address';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
                    
//                     _buildTextField(
//                       controller: _addressController,
//                       label: "Address",
//                       icon: Icons.location_on_outlined,
//                       maxLines: 3,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your address';
//                         }
//                         if (value.length < 10) {
//                           return 'Please enter a complete address';
//                         }
//                         return null;
//                       },
//                     ),
                    
//                     const SizedBox(height: 30),
                    
//                     // Save Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: isSaving ? null : _saveProfile,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFFF5722),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 2,
//                           shadowColor: const Color(0xFFFF5722).withOpacity(0.4),
//                         ),
//                         child: isSaving
//                             ? const SizedBox(
//                                 height: 24,
//                                 width: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2.5,
//                                 ),
//                               )
//                             : Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: const [
//                                   Icon(Icons.check_circle_outline, size: 22),
//                                   SizedBox(width: 10),
//                                   Text(
//                                     'Save Changes',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 0.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileSection() {
//     final initials = _getInitials(widget.name);
    
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: const Color(0xFFFF5722), width: 3),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFFFF5722).withOpacity(0.3),
//                 blurRadius: 15,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: CircleAvatar(
//             radius: 60,
//             backgroundColor: const Color(0xFFFFEBEE),
//             child: Text(
//               initials,
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFFF5722),
//                 letterSpacing: 1,
//               ),
//             ),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: const Color(0xFFFF5722),
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 3),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFFFF5722).withOpacity(0.4),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.camera_alt,
//             color: Colors.white,
//             size: 20,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       maxLines: maxLines,
//       enabled: !isSaving,
//       validator: validator,
//       style: const TextStyle(
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(
//           color: Colors.grey[600],
//           fontWeight: FontWeight.w500,
//         ),
//         prefixIcon: Container(
//           margin: const EdgeInsets.all(12),
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: const Color(0xFFFF5722).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: const Color(0xFFFF5722),
//             size: 22,
//           ),
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
//         ),
//         errorStyle: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: maxLines > 1 ? 16 : 18,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String address;
  final Function(Map<String, String>) onSave;

  const EditProfilePage({
    Key? key,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _emailController = TextEditingController(text: widget.email);
    _addressController = TextEditingController(text: widget.address);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      widget.onSave({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
      });

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Profile updated successfully',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2C2C2C),
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Profile Avatar Section
                _buildProfileAvatar(),
                
                const SizedBox(height: 32),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ModernTextField(
                          controller: _nameController,
                          label: "Full Name",
                          icon: Icons.person_outline_rounded,
                          enabled: !isSaving,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _ModernTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          enabled: !isSaving,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length != 10) {
                              return 'Please enter a valid 10-digit number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _ModernTextField(
                          controller: _emailController,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isSaving,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _ModernTextField(
                          controller: _addressController,
                          label: "Address",
                          icon: Icons.location_on_outlined,
                          maxLines: 3,
                          enabled: !isSaving,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            if (value.length < 10) {
                              return 'Please enter a complete address';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        _buildActionButtons(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final initials = _getInitials(_nameController.text.isNotEmpty ? _nameController.text : widget.name);
    
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          children: [
            // Gradient Ring
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Camera Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Handle image upload
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Image upload coming soon',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF667EEA),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFAFAFA), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSaving ? null : () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(14),
                child: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Save Button
        Expanded(
          flex: 2,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSaving ? null : _saveProfile,
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Modern Text Field Widget
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            enabled: enabled,
            validator: validator,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              hintText: 'Enter your ${label.toLowerCase()}',
              hintStyle: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w400,
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
                  color: Color(0xFF667EEA),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFFF4757),
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFFF4757),
                  width: 2,
                ),
              ),
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFF4757),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 16 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}