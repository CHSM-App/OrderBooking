// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'otp_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   void _sendOTP() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);
      
//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));
      
//       setState(() => _isLoading = false);
      
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OTPScreen(
//               phoneNumber: _phoneController.text,
//             ),
//           ),
//         );
//       }
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
//                  const Color(0xFFFFC107),
//               const Color(0xFFFFD54F),
//               const Color(0xFFFFE082),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Logo/Icon
//                   Container(
//   width: 140,
//   height: 140,
//   decoration: BoxDecoration(
//     color: Colors.white,
//     shape: BoxShape.circle,
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.1),
//         blurRadius: 20,
//         offset: const Offset(0, 10),
//       ),
//     ],
//   ),
//   child: ClipRect(
//     child: Image.network(
//       'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
//       fit: BoxFit.cover,
//     ),
//   ),
// ),

//                     const SizedBox(height: 40),
                    
//                     // Title
//                     const Text(
//                       'Juice Delivery',
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Employee Login',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black
//                       ),
//                     ),
//                     const SizedBox(height: 50),
                    
//                     // Phone Input Card
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                             const Text(
//                         'Login',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF2C2C2C),
//                         ),
//                       ),
//                          const SizedBox(height: 8),
//                           const Text(
//                         'Enter your phone number to continue',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF757575),
//                         ),
                      
//                           ),
//                           const SizedBox(height: 20),
//                           TextFormField(
//                             controller: _phoneController,
//                             keyboardType: TextInputType.phone,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                               LengthLimitingTextInputFormatter(10),
//                             ],
//                             decoration: InputDecoration(
//                               prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFFFC107)),
//                               hintText: '10 digit mobile number',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(color: Colors.grey.shade300),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(color: Colors.yellow, width: 2),
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter mobile number';
//                               }
//                               if (value.length != 10) {
//                                 return 'Please enter valid 10 digit number';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 24),
//                           ElevatedButton(
//                             onPressed: _isLoading ? null : _sendOTP,
//                             style: ElevatedButton.styleFrom(
//                                backgroundColor: const Color(0xFFFFC107),
//                           foregroundColor: const Color(0xFF2C2C2C),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: _isLoading
//                                 ? const SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Text(
//                                     'Send OTP',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }
// }

// Employee Login Screen
import 'package:flutter/material.dart';
import 'package:order_booking_app/screens/employee_screen/otp_screen.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _mobileController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Top Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 50,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Employee Portal',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Welcome back to your workspace',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // White Card
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back! 👋',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your mobile number to continue',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Mobile Number Input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mobile Number',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isFocused
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey[300]!,
                                    width: _isFocused ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  color: _isFocused
                                      ? const Color(0xFF6366F1).withOpacity(0.05)
                                      : Colors.grey[50],
                                  boxShadow: _isFocused
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF6366F1)
                                                .withOpacity(0.2),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      child: const Text(
                                        '+91',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.grey[300],
                                    ),
                                    Expanded(
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          setState(() {
                                            _isFocused = hasFocus;
                                          });
                                        },
                                        child: TextField(
                                          controller: _mobileController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Enter mobile number',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 18,
                                            ),
                                            counterText: '',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Send OTP Button
                         // After validating the mobile number
SizedBox(
  width: double.infinity,
  height: 58,
  child: ElevatedButton(
    onPressed: () {
      final mobile = _mobileController.text.trim();
      if (mobile.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
        );
        return;
      }

      // Navigate to OTP Screen (for demo, directly go to HomePage)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => OTPScreen(
              phoneNumber: _mobileController.text,
            ),
          ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6366F1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Send OTP',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
      ],
    ),
  ),
),

                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'By continuing, you agree to our Terms & Conditions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
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
}
