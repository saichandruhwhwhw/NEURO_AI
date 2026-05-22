import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../dashboard/widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'admin_login_screen.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _securityCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: 'admin',
          profileData: {
            'fullName': _nameController.text.trim(),
            'adminId': _idController.text.trim(),
            'institutionName': _institutionController.text.trim(),
            'securityCode': _securityCodeController.text.trim(),
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Command Core Access Created! Please Login.')));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.redAccent.withValues(alpha: 0.15), Colors.black],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeInUp(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.admin_panel_settings, size: 50, color: Colors.redAccent),
                            const SizedBox(height: 16),
                            const Text(
                              'ADMIN REGISTRATION',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Secure Institution Initialization',
                              style: TextStyle(color: Colors.redAccent, fontSize: 12, letterSpacing: 1),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            _buildField(_nameController, 'Admin Name', Icons.person),
                            const SizedBox(height: 16),
                            _buildField(_idController, 'Admin ID', Icons.badge),
                            const SizedBox(height: 16),
                            _buildField(_institutionController, 'Institution Name', Icons.account_balance),
                            const SizedBox(height: 16),
                            _buildField(_emailController, 'Official Email', Icons.email),
                            const SizedBox(height: 16),
                            _buildField(_securityCodeController, 'Security Clearance Code', Icons.security),
                            const SizedBox(height: 16),
                            _buildPasswordField(_passwordController, 'Master Password'),
                            const SizedBox(height: 16),
                            _buildPasswordField(_confirmController, 'Confirm Master Password'),
                            
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 10,
                                shadowColor: Colors.redAccent.withValues(alpha: 0.5),
                              ),
                              child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Create Command Core Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                              child: const Text('Already have Core Access? Login', style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (val) => val!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.redAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: Colors.black26,
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      validator: (val) {
        if (val!.isEmpty) return 'Required';
        if (label == 'Confirm Master Password' && val != _passwordController.text) return 'Passwords do not match';
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key, color: Colors.redAccent),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: Colors.black26,
      ),
    );
  }
}
