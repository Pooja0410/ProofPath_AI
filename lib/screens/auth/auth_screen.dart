import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _busy = false;
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _age = TextEditingController();
  String? _gender;

  @override
  void dispose() {
    _fullName.dispose(); _username.dispose(); _password.dispose(); _age.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    String? error;
    if (_isLogin) {
      error = await AuthService.instance.login(username: _username.text, password: _password.text);
    } else {
      error = await AuthService.instance.register(
        fullName: _fullName.text,
        username: _username.text,
        password: _password.text,
        age: int.parse(_age.text),
        gender: _gender!,
      );
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false,
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppColors.primary),
    filled: true,
    fillColor: const Color(0xFFF7F6FC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE7E4F2))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 76, height: 76, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.pink])), child: const Icon(Icons.shield_rounded, color: Colors.white, size: 43))),
            const SizedBox(height: 16),
            const Text('ProofPath AI', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 6),
            const Text('Your safety. Your evidence. Your control.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 28),
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
              Expanded(child: _tab('Login', _isLogin)), Expanded(child: _tab('Register', !_isLogin)),
            ])),
            const SizedBox(height: 22),
            Text(_isLogin ? 'Welcome back' : 'Create your account', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(_isLogin ? 'Sign in to continue to your safety dashboard.' : 'Enter your details to get started with ProofPath AI.', style: const TextStyle(color: AppColors.textLight, height: 1.4)),
            const SizedBox(height: 20),
            Form(key: _formKey, child: Column(children: [
              if (!_isLogin) ...[
                TextFormField(controller: _fullName, textCapitalization: TextCapitalization.words, decoration: _decoration('Full name', Icons.person_outline), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null),
                const SizedBox(height: 13),
              ],
              TextFormField(controller: _username, autocorrect: false, decoration: _decoration('Username', Icons.alternate_email), validator: (v) { if (v == null || v.trim().isEmpty) return 'Enter your username'; if (v.trim().contains(' ')) return 'Username cannot contain spaces'; if (v.trim().length < 3) return 'Use at least 3 characters'; return null; }),
              const SizedBox(height: 13),
              TextFormField(controller: _password, obscureText: _obscure, decoration: _decoration('Password', Icons.lock_outline).copyWith(suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure))), validator: (v) { if (v == null || v.isEmpty) return 'Enter your password'; if (!_isLogin && v.length < 8) return 'Use at least 8 characters'; return null; }),
              if (!_isLogin) ...[
                const SizedBox(height: 13),
                TextFormField(controller: _age, keyboardType: TextInputType.number, decoration: _decoration('Age', Icons.cake_outlined), validator: (v) { final n = int.tryParse(v ?? ''); if (n == null || n < 13 || n > 120) return 'Enter a valid age (13–120)'; return null; }),
                const SizedBox(height: 13),
                DropdownButtonFormField<String>(value: _gender, decoration: _decoration('Gender', Icons.wc_outlined), items: const [DropdownMenuItem(value: 'Female', child: Text('Female')), DropdownMenuItem(value: 'Male', child: Text('Male')), DropdownMenuItem(value: 'Non-binary', child: Text('Non-binary')), DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say'))], onChanged: (v) => setState(() => _gender = v), validator: (v) => v == null ? 'Select your gender' : null),
              ],
            ])),
            const SizedBox(height: 22),
            SizedBox(height: 52, child: ElevatedButton(onPressed: _busy ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isLogin ? 'Login' : 'Create account', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
            const SizedBox(height: 16),
            Text(_isLogin ? 'New to ProofPath AI?' : 'Already have an account?', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textLight)),
            TextButton(onPressed: () => setState(() { _isLogin = !_isLogin; _formKey.currentState?.reset(); }), child: Text(_isLogin ? 'Create an account' : 'Login instead', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
          ],
        )),
      ))),
    );
  }

  Widget _tab(String label, bool selected) => InkWell(onTap: () => setState(() => _isLogin = label == 'Login'), borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textLight))));
}
