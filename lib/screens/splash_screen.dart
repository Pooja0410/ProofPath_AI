import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'home/home_screen.dart';
import 'auth/auth_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        AuthService.instance.currentUser().then((user) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => user == null ? const AuthScreen() : const HomeScreen(),
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8FC),
              Color(0xFFF0EEFF),
              Color(0xFFE7E4FF),
            ],
          ),
        ),

        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ScaleTransition(
                  scale: _scaleAnimation,

                  child: Container(
                    width: 110,
                    height: 110,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.pink,
                        ],
                      ),

                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.shield_rounded,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                RichText(
                  text: const TextSpan(
                    children: [

                      TextSpan(
                        text: 'ProofPath ',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),

                      TextSpan(
                        text: 'AI',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pink,
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Where every path becomes proof',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Zero-action evidence capture\nfor personal safety.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: 60),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: const Text(
                    'Stay Safe • Stay Heard • Stay Protected',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
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