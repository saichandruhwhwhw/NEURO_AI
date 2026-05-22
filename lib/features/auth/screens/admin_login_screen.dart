import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../dashboard/screens/admin_dashboard.dart';
import '../../dashboard/widgets/glass_container.dart';
import '../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userData = await _authService.loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (mounted) {
          if (userData != null && userData['role'] == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: Invalid Role or Account not found.')));
            await _authService.logout();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: ${e.toString()}')));
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
          // Theme Background (Red + Dark)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.redAccent.withValues(alpha: 0.15),
                  Colors.black,
                ],
                center: Alignment.bottomCenter,
                radius: 1.5,
              ),
            ),
          ),
          
          // Background Animation
          Positioned(
            top: 50,
            right: 0,
            left: 0,
            child: Pulse(
              infinite: true,
              duration: const Duration(seconds: 2),
              child: const Icon(Icons.shield, size: 300, color: Colors.white10),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 800;
                    if (isWide) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildLoginForm()),
                          const SizedBox(width: 40),
                          Expanded(child: _buildAdminPreview()),
                        ],
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLoginForm(),
                        const SizedBox(height: 40),
                        _buildAdminPreview(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Back Button
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

  Widget _buildLoginForm() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.admin_panel_settings, size: 60, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'COMMAND CORE',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'AI Security & Governance',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12, letterSpacing: 1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.security, color: Colors.redAccent),
                    labelText: 'Admin Official Email',
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
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.vpn_key, color: Colors.redAccent),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    labelText: 'Master Passcode',
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
                ),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (val) {},
                          activeColor: Colors.redAccent,
                          checkColor: Colors.white,
                        ),
                        const Text('Trust Device', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                    : const Text('Enter Command Core', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.fingerprint, color: Colors.redAccent, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminPreview() {
    return FadeInDown(
      duration: const Duration(milliseconds: 900),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            const Text('SYSTEM INTELLIGENCE', style: TextStyle(color: Colors.white54, letterSpacing: 4, fontSize: 12)),
            const SizedBox(height: 20),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent.withValues(alpha: 0.2)),
                    child: const Icon(Icons.dns, color: Colors.greenAccent),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Server Status', style: TextStyle(color: Colors.white70)),
                        Text('Optimal', style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orangeAccent.withValues(alpha: 0.2)),
                    child: const Icon(Icons.policy, color: Colors.orangeAccent),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Security Threats', style: TextStyle(color: Colors.white70)),
                        Text('Zero Detected', style: TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
