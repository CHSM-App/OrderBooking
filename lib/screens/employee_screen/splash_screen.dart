import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoScaleAnimation;

  final List<ProductItem> _products = [
    ProductItem('https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&h=400&fit=crop', 'Juice', 0),
    ProductItem('https://images.unsplash.com/photo-1481671703460-040cb8a2d909?w=400&h=400&fit=crop', 'Chocolate', 45),
    ProductItem('https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&h=400&fit=crop', 'Fruits', 90),
    ProductItem('https://images.unsplash.com/photo-1508747703725-719777637510?w=400&h=400&fit=crop', 'Nuts', 135),
    ProductItem('https://images.unsplash.com/photo-1588964895597-cfccd6e2dbf9?w=400&h=400&fit=crop', 'Grocery', 180),
    ProductItem('https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=400&h=400&fit=crop', 'Smoothie', 225),
    ProductItem('https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=400&fit=crop', 'Coffee', 270),
    ProductItem('https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=400&h=400&fit=crop', 'Snacks', 315),
  ];

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_pulseController);
    
    _mainController.forward();
    
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFF5F5F5),
              const Color(0xFFEEEEEE),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),
            
            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Product circle carousel
                        SizedBox(
                          height: 280,
                          width: 280,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow effect
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Rotating products
                              AnimatedBuilder(
                                animation: _rotationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationController.value * 2 * math.pi,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: _products.map((product) {
                                        return _buildProductImage(product);
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                              
                              // Center logo
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: AnimatedBuilder(
                                  animation: _logoScaleAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _logoScaleAnimation.value,
                                      child: Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFFFFC107),
                                              const Color(0xFFFF9800),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFC107).withOpacity(0.5),
                                              blurRadius: 25,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.shopping_bag_rounded,
                                          size: 55,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 50),
                        
                        // App title with slide animation
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    const Color(0xFF1976D2),
                                    const Color(0xFF42A5F5),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'QuickDeliver',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color.fromARGB(255, 255, 131, 7),
                                      const Color.fromARGB(255, 255, 149, 0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 255, 172, 7).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Order Booking Portal',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Loading indicator
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color.fromARGB(255, 255, 119, 7),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Loading your workspace...',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductItem product) {
    final angle = (product.angle * math.pi / 180);
    final radius = 120.0;
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.rotate(
        angle: -_rotationController.value * 2 * math.pi,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: const Color(0xFFFFC107).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFFFC107),
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.fastfood_rounded,
                      size: 30,
                      color: Colors.orange[400],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = 4.0 + random.nextDouble() * 6;
    final duration = 3000 + random.nextInt(4000);
    
    return Positioned(
      left: random.nextDouble() * 400,
      top: random.nextDouble() * 800,
      child: _AnimatedParticle(
        duration: duration,
        size: size,
      ),
    );
  }
}

class _AnimatedParticle extends StatefulWidget {
  final int duration;
  final double size;

  const _AnimatedParticle({
    required this.duration,
    required this.size,
  });

  @override
  State<_AnimatedParticle> createState() => _AnimatedParticleState();
}

class _AnimatedParticleState extends State<_AnimatedParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value * 100),
          child: Opacity(
            opacity: (1 - _animation.value) * 0.6,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProductItem {
  final String imageUrl;
  final String name;
  final double angle;

  ProductItem(this.imageUrl, this.name, this.angle);
}