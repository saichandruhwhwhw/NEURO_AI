import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'faculty_login_screen.dart';

class FacultyRegistrationScreen extends StatefulWidget {
  const FacultyRegistrationScreen({super.key});

  @override
  State<FacultyRegistrationScreen> createState() => _FacultyRegistrationScreenState();
}

class _FacultyRegistrationScreenState extends State<FacultyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
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
          role: 'faculty',
          profileData: {
            'fullName': _nameController.text.trim(),
            'facultyId': _idController.text.trim(),
            'department': _deptController.text.trim(),
            'subjectHandling': _subjectController.text.trim(),
            'experience': _experienceController.text.trim(),
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty Nexus ID Created! Please Login.')));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FacultyLoginScreen()));
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppColors.accentPurple.withValues(alpha: 0.2), AppColors.background],
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
                            const Icon(Icons.school, size: 50, color: AppColors.accentPurple),
                            const SizedBox(height: 16),
                            const Text(
                              'FACULTY REGISTRATION',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Academic Monitoring Configuration',
                              style: TextStyle(color: AppColors.accentPurple, fontSize: 12, letterSpacing: 1),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            _buildField(_nameController, 'Faculty Name', Icons.person),
                            const SizedBox(height: 16),
                            _buildField(_idController, 'Faculty ID', Icons.badge),
                            const SizedBox(height: 16),
                            _buildField(_emailController, 'Email', Icons.email),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildField(_deptController, 'Department', Icons.domain)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildField(_experienceController, 'Experience (Yrs)', Icons.timeline)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildField(_subjectController, 'Subject Handling', Icons.menu_book),
                            const SizedBox(height: 16),
                            _buildPasswordField(_passwordController, 'Password'),
                            const SizedBox(height: 16),
                            _buildPasswordField(_confirmController, 'Confirm Password'),
                            
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 10,
                                shadowColor: AppColors.accentPurple.withValues(alpha: 0.5),
                              ),
                              child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Create Faculty Nexus ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FacultyLoginScreen())),
                              child: const Text('Already have a Nexus ID? Login', style: TextStyle(color: Colors.white70)),
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
        prefixIcon: Icon(icon, color: AppColors.accentPurple),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentPurple.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentPurple),
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
        if (label == 'Confirm Password' && val != _passwordController.text) return 'Passwords do not match';
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.accentPurple),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentPurple.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentPurple),
        ),
        filled: true,
        fillColor: Colors.black26,
      ),
    );
  }
}
