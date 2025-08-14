import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _loadingController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));
    
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
    
    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);
    
    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _startSplashScreen();
  }

  void _startSplashScreen() async {
    // Start background animation immediately
    _backgroundController.repeat();
    
    // Start logo animation
    _logoController.forward();
    
    // Wait a bit then start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _textController.forward();
    }
    
    // Wait a bit then start loading animation
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _loadingController.forward();
    }
    
    // Total wait time before navigation
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFFFF9800),
                    const Color(0xFFFFB74D),
                    (_backgroundAnimation.value * 0.5).clamp(0.0, 1.0),
                  )!,
                  Color.lerp(
                    const Color(0xFFFF5722),
                    const Color(0xFFFF7043),
                    (_backgroundAnimation.value * 0.3).clamp(0.0, 1.0),
                  )!,
                  const Color(0xFFE64A19),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated background circles
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      final offset = (_backgroundAnimation.value * 2 * 3.14159) + (index * 2.0);
                      return Positioned(
                        top: 100.0 + (50.0 * index) + (30.0 * (1.0 + 0.5 * index) * 
                            (0.5 + 0.5 * math.sin(offset))),
                        right: -50.0 + (100.0 * index) + (40.0 * (1.0 + 0.3 * index) * 
                            (0.5 + 0.5 * math.cos(offset))),
                        child: Container(
                          width: 80.0 + (20.0 * index),
                          height: 80.0 + (20.0 * index),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05 + (0.02 * index)),
                          ),
                        ),
                      );
                    },
                  );
                }),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with multiple animations
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotationAnimation.value,
                              child: FadeTransition(
                                opacity: _logoOpacityAnimation,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                        spreadRadius: -5,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFFF5722).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                        spreadRadius: -8,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Inner glow
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              const Color(0xFFFF9800).withOpacity(0.1),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Icon
                                      ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                        child: const Icon(
                                          Icons.restaurant_menu,
                                          size: 70,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // App Name with slide animation
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _textSlideAnimation.value),
                            child: FadeTransition(
                              opacity: _textOpacityAnimation,
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds),
                                child: const Text(
                                  'Recipe App',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Subtitle with slide animation
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _textSlideAnimation.value * 0.5),
                            child: FadeTransition(
                              opacity: _textOpacityAnimation,
                              child: Text(
                                'Temukan Resep Favoritmu',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w300,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Enhanced loading indicator
                      AnimatedBuilder(
                        animation: _loadingAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _loadingAnimation,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer ring
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white.withOpacity(0.3),
                                        ),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    // Inner ring
                                    SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: CircularProgressIndicator(
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Mempersiapkan aplikasi...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}