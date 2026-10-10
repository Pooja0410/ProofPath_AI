// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/live_map.dart';

class LiveLocationScreen extends StatelessWidget {
  const LiveLocationScreen({super.key});

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
          'Live Location',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Tracking Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 25,
                    ),
                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Tracking Active',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Your location is being monitored',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Live Map
              Container(
                height: 330,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    const LiveMap(
                      height: 330,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),

                    // LIVE badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 10,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 12),

              // Location Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    _locationRow(
                      Icons.location_on,
                      'Latitude',
                      '18.5204° N',
                    ),

                    const Divider(height: 24),

                    _locationRow(
                      Icons.explore,
                      'Longitude',
                      '73.8567° E',
                    ),

                    const Divider(height: 24),

                    _locationRow(
                      Icons.speed,
                      'Accuracy',
                      '± 5 meters',
                    ),

                    const Divider(height: 24),

                    _locationRow(
                      Icons.access_time,
                      'Last Updated',
                      'Just now',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Secure Location Card
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
                child: const Row(
                  children: [

                    Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 30,
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Protected',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Your live location is securely linked '
                            'to the active incident.',
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

              const SizedBox(height: 25),

              // Stop Tracking Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.location_off),
                label: const Text('Stop Tracking'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sosRed,
                  minimumSize:
                      const Size(double.infinity, 52),
                  side: const BorderSide(
                    color: AppColors.sosRed,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}