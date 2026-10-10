import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/sos_button.dart';
import '../emergency/emergency_screen.dart';
import '../incidents/incident_history_screen.dart';
import'../location/live_location_screen.dart';
import'../profile/profile_screen.dart';
import'../safety_map/safety_map_screen.dart';
class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int selectedIndex = 0;
// sos button handler
  void _handleSOS() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Activate SOS?'),
        content: const Text(
          'Emergency mode will start and evidence capture will begin.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyScreen(),
                ),
              );
            },
            child: const Text('ACTIVATE SOS'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // HEADER

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(
                              'PROOFPATH AI',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textLight,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              'Stay Safe Today',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 48,
                          height: 48,

                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // SOS SECTION

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                      ),

                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.pink.shade50,
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(30),
                      ),

                      child: Column(
                        children: [

                          const Text(
                            'Need help?',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textLight,
                            ),
                          ),

                          const SizedBox(height: 12),

                          SosButton(
                            onPressed: _handleSOS,
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'One tap starts emergency protection',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // QUICK ACCESS

                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      height: 160,

                      child: Row(
                        children: [

                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.location_on_outlined,
                              iconColor: Colors.deepPurple,
                              title: 'Live Location',
                              subtitle: 'Track your location',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LiveLocationScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.map_outlined,
                              iconColor: Colors.deepPurple,
                              title: 'Safety Map',
                              subtitle: 'View risk areas',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SafetyMapScreen(),
                                 ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 160,

                      child: Row(
                        children: [

                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.history_rounded,
                              iconColor: Colors.deepPurple,
                              title: 'History',
                              subtitle: 'Past incidents',
                             onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const IncidentHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.people_outline_rounded,
                              iconColor: Colors.deepPurple,
                              title: 'Contacts',
                              subtitle: 'Trusted contacts',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // PROTECTION STATUS

                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F8F0),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Row(
                        children: [

                          Container(
                            width: 42,
                            height: 42,

                            decoration: const BoxDecoration(
                              color: Color(0xFF2EAA67),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.shield_rounded,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  'Protection Active',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        AppColors.textDark,
                                  ),
                                ),

                                SizedBox(height: 3),

                                Text(
                                  'ProofPath AI is ready when you need it.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2EAA67),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM NAVIGATION

          // BOTTOM NAVIGATION

Container(
  padding: const EdgeInsets.only(
    top: 10,
    bottom: 8,
  ),

  decoration: BoxDecoration(
    color: Colors.white,

    boxShadow: [
      BoxShadow(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.06),
        blurRadius: 15,
        offset: const Offset(0, -4),
      ),
    ],
  ),

  child: NavigationBar(
    backgroundColor: Colors.white,
    elevation: 0,

    selectedIndex: selectedIndex,

    onDestinationSelected: (index) {
      if (index == 0) {
        // HOME
        // Already on Home screen
        return;
      }

      if (index == 1) {
        // MAP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SafetyMapScreen(),
          ),
        );
      }

      if (index == 2) {
        // HISTORY
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const IncidentHistoryScreen(),
          ),
        );
      }

      if (index == 3) {
        // PROFILE
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      }
    },

    destinations: const [

      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),

      NavigationDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map_rounded),
        label: 'Map',
      ),

      NavigationDestination(
        icon: Icon(Icons.history_outlined),
        selectedIcon: Icon(Icons.history_rounded),
        label: 'History',
      ),

      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ],
  ),
),
          ],
        ),
      ),
    );
  }
}