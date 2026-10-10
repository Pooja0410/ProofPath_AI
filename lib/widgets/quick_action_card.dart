import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class QuickActionCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap, required MaterialColor iconColor,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}