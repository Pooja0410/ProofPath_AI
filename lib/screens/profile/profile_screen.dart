import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    AuthService.instance.currentUser().then((user) {
      if (mounted) setState(() => _user = user);
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need your username and password to sign in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('LOG OUT')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // Profile photo
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              (_user?['fullName'] as String?) ?? 'Your Profile',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '@${(_user?['username'] as String?) ?? 'username'}  •  Age ${(_user?['age']?.toString()) ?? '—'}  •  ${(_user?['gender'] as String?) ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            ),

            const SizedBox(height: 25),

            // Protection status
            _protectionCard(),

            const SizedBox(height: 25),

            _sectionTitle('Emergency Contacts'),

            const SizedBox(height: 12),

            _contactCard(
              icon: Icons.person,
              name: 'Mother',
              phone: '+91 XXXXX XXXXX',
            ),

            const SizedBox(height: 12),

            _contactCard(
              icon: Icons.person_outline,
              name: 'Emergency Contact',
              phone: '+91 XXXXX XXXXX',
            ),

            const SizedBox(height: 15),

            // Add contact
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showAddContactDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Emergency Contact'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                    color: AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            _sectionTitle('Security & Privacy'),

            const SizedBox(height: 12),

            _settingsTile(
              icon: Icons.lock_outline,
              title: 'Evidence Encryption',
              subtitle: 'Your evidence is securely protected',
            ),

            _settingsTile(
              icon: Icons.location_on_outlined,
              title: 'Location Permission',
              subtitle: 'Manage location access',
            ),

            _settingsTile(
              icon: Icons.settings_outlined,
              title: 'App Settings',
              subtitle: 'Manage application preferences',
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sosRed,
                  side: const BorderSide(color: AppColors.sosRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _protectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protection Status',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Protection Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String name,
    required String phone,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Emergency contact added successfully',
                    ),
                  ),
                );
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }
}