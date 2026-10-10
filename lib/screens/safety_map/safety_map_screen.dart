// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/live_map.dart';

class SafetyMapScreen extends StatelessWidget {
  const SafetyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Safety Map',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.filter_list,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              const Text(
                'AI Risk Map',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Identify incident hotspots around you',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              // Map
              Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Stack(
                  children: [
                    const LiveMap(
                      height: 380,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),

                    // Hotspot overlays
                    _hotspot(
                      top: 75,
                      left: 80,
                      size: 75,
                      opacity: 0.22,
                    ),

                    _hotspot(
                      top: 180,
                      right: 65,
                      size: 90,
                      opacity: 0.25,
                    ),

                    _hotspot(
                      bottom: 65,
                      left: 145,
                      size: 65,
                      opacity: 0.18,
                    ),

                    // Current location label
                    Positioned(
                      top: 195,
                      left: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'You are here',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),

                    // Map legend
                    Positioned(
                      left: 15,
                      bottom: 15,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _legendItem('High Risk', AppColors.sosRed),
                            const SizedBox(height: 7),
                            _legendItem('Medium Risk', Colors.orange),
                            const SizedBox(height: 7),
                            _legendItem('Low Risk', Colors.green),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // AI Analysis Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            'AI Risk Analysis',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Incident patterns are analyzed '
                            'to identify risk hotspots.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Risk Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: _riskCard(
                      'High Risk',
                      '3',
                      AppColors.sosRed,
                      Icons.warning_amber_rounded,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _riskCard(
                      'Medium',
                      '7',
                      Colors.orange,
                      Icons.info_outline,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _riskCard(
                      'Low Risk',
                      '12',
                      Colors.green,
                      Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Nearby Alert
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.sosRed
                            .withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.sosRed,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            'Nearby Risk Area',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'A higher incident concentration '
                            'was detected in this area.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Refresh
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Risk Map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize:
                      const Size(double.infinity, 52),
                  side: const BorderSide(
                    color: AppColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hotspot({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,

      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.sosRed.withOpacity(opacity),
        ),
      ),
    );
  }

  Widget _legendItem(
    String text,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _riskCard(
    String title,
    String number,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const SizedBox(height: 10),

          Text(
            number,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}