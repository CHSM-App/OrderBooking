// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'location_permission_screen.dart';

// class OTPScreen extends StatefulWidget {
//   final String phoneNumber;

//   const OTPScreen({Key? key, required this.phoneNumber}) : super(key: key);

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   final List<TextEditingController> _otpControllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(
//     6,
//     (index) => FocusNode(),
//   );
//   bool _isLoading = false;

//   void _verifyOTP() async {
//     String otp = _otpControllers.map((c) => c.text).join();
    
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter complete OTP')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);
    
//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));
    
//     setState(() => _isLoading = false);
    
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const LocationPermissionScreen(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               const Color(0xFFFFFBF0),
//               const Color(0xFFFFE082).withOpacity(0.1),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 // Back button
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.black),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Icon
//                             Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFC107).withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.lock_outline,
//                     size: 60,
//                     color: Color(0xFFFFC107),
//                   ),
//                 ),
//                           const SizedBox(height: 40),
                          
//                           // Title
//                          const Text(
//                   'Enter Verification Code',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C2C2C),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'We sent a code to your phone',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFF757575),
//                   ),
//                 ),
//                           const SizedBox(height: 50),
                          
//                           // OTP Input Card
//                           Container(
//                             padding: const EdgeInsets.all(24),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 // OTP Input Boxes
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                   children: List.generate(
//                                     6,
//                                     (index) => SizedBox(
//                                       width: 45,
//                                       child: TextFormField(
//                                         controller: _otpControllers[index],
//                                         focusNode: _focusNodes[index],
//                                         keyboardType: TextInputType.number,
//                                         textAlign: TextAlign.center,
//                                         maxLength: 1,
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.digitsOnly,
//                                         ],
//                                         decoration: InputDecoration(
//                                           counterText: '',
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                             borderSide: BorderSide(
//                                               color: Colors.grey.shade300,
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                             borderSide: const BorderSide(
//                                               color: Colors.yellow,
//                                               width: 2,
//                                             ),
//                                           ),
//                                         ),
//                                         onChanged: (value) {
//                                           if (value.isNotEmpty && index < 5) {
//                                             _focusNodes[index + 1].requestFocus();
//                                           }
//                                           if (value.isEmpty && index > 0) {
//                                             _focusNodes[index - 1].requestFocus();
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
                                
//                                 // Verify Button
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                     onPressed: _isLoading ? null : _verifyOTP,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.yellow,
//                                       padding: const EdgeInsets.symmetric(vertical: 16),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       elevation: 0,
//                                     ),
//                                     child: _isLoading
//                                         ? const SizedBox(
//                                             height: 20,
//                                             width: 20,
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2,
//                                             ),
//                                           )
//                                         : const Text(
//                                             'Verify',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
                                
//                                 // Resend OTP
//                                 TextButton(
//                                   onPressed: () {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text('OTP resent successfully'),
//                                       ),
//                                     );
//                                   },
//                                   child: const Text(
//                                     'Resend OTP',
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:order_booking_app/screens/employee_screen/home_page.dart';
import 'package:order_booking_app/screens/employee_screen/main_navigation_screen.dart';
import 'location_permission_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 50,
                    color: Color(0xFFFFC107),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Location Permission',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                const Text(
                  'We need your location to show nearby shops and provide better service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Allow Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Allow Permission',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Skip Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      _showPermissionDialog(); // Show dialog instead of direct navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFFBF0),
              const Color(0xFFFFE082).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              size: 60,
                              color: Color(0xFFFFC107),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Title
                          const Text(
                            'Enter Verification Code',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'We sent a code to your phone',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 50),
                          
                          // OTP Input Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // OTP Input Boxes
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    6,
                                    (index) => SizedBox(
                                      width: 45,
                                      child: TextFormField(
                                        controller: _otpControllers[index],
                                        focusNode: _focusNodes[index],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          counterText: '',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.yellow,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty && index < 5) {
                                            _focusNodes[index + 1].requestFocus();
                                          }
                                          if (value.isEmpty && index > 0) {
                                            _focusNodes[index - 1].requestFocus();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Verify Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _verifyOTP,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.yellow,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Verify',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Resend OTP
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('OTP resent successfully'),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}