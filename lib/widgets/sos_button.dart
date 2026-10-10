import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SosButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SosButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _animationController,

      builder: (context, child) {

        final scale = 1.0 + (_animationController.value * 0.04);

        return Transform.scale(
          scale: scale,

          child: GestureDetector(
            onTap: widget.onPressed,

            child: Container(
              width: 210,
              height: 210,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFF6375),
                    AppColors.sosRed,
                    Color(0xFFD91F3C),
                  ],
                ),

                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.sosRed.withOpacity(
                      0.35 + (_animationController.value * 0.15),
                    ),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                ],
              ),

              child: Center(
                child: Container(
                  width: 165,
                  height: 165,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.45),
                      width: 2,
                    ),
                  ),

                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [

                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Tap for Help',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}