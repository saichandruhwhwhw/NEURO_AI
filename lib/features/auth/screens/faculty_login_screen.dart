import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/screens/faculty_dashboard.dart';
import '../../dashboard/widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../../../core/widgets/futuristic_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyLoginScreen extends StatefulWidget {
  const FacultyLoginScreen({super.key});

  @override
  State<FacultyLoginScreen> createState() => _FacultyLoginScreenState();
}

class _FacultyLoginScreenState extends State<FacultyLoginScreen> {
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
          if (userData != null && userData['role'] == 'faculty') {
            FuturisticToast.show(context, message: "Authentication Successful. Redirecting...");
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FacultyDashboard()));
          } else {
            FuturisticToast.show(context, message: "Access Denied: Invalid Role or Account not found.", isError: true);
            await _authService.logout();
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String errorMessage = "Login Failed: ${e.message}";
          if (e.code == 'invalid-credential') {
            errorMessage = "Access Denied: Invalid Secure Passcode or Email.";
          } else if (e.code == 'invalid-email') {
            errorMessage = "Formatting Error: Invalid Email Structure.";
          } else if (e.code == 'network-request-failed') {
            errorMessage = "Connection Lost: Check Network Uplink.";
          }
          FuturisticToast.show(context, message: errorMessage, isError: true);
        }
      } catch (e) {
        if (mounted) {
          FuturisticToast.show(context, message: "System Error: ${e.toString()}", isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showResetPasswordDialog() {
    final resetFormKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    bool dialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassContainer(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: resetFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lock_reset, color: AppColors.accentPurple, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'FACULTY RECOVERY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        const Text(
                          'Enter your faculty email registered in the academic monitoring system to transmit a recovery link.',
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        
                        // Email Input
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Required';
                            final bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val);
                            if (!emailValid) return 'Invalid Email Format';
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.accentPurple),
                            labelText: 'Registered Faculty Email',
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
                        ),
                        const SizedBox(height: 28),
                        
                        // Action Button
                        ElevatedButton(
                          onPressed: dialogLoading
                              ? null
                              : () async {
                                  if (resetFormKey.currentState!.validate()) {
                                    setStateDialog(() => dialogLoading = true);
                                    try {
                                      final email = emailController.text.trim();
                                      
                                      // 1. Check if email exists in Firestore
                                      final emailExists = await _authService.checkEmailExists(email);
                                      if (!emailExists) {
                                        if (context.mounted) {
                                          FuturisticToast.show(
                                            context,
                                            message: "Email not found.",
                                            isError: true,
                                          );
                                        }
                                        setStateDialog(() => dialogLoading = false);
                                        return;
                                      }

                                      // 2. Send Reset Link
                                      await _authService.sendResetEmail(email);
                                      
                                      if (context.mounted) {
                                        FuturisticToast.show(
                                          context,
                                          message: "Password reset link sent successfully.",
                                        );
                                        Navigator.pop(context);
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      String errMsg = "Invalid email.";
                                      if (e.code == 'invalid-email') {
                                        errMsg = "Invalid email.";
                                      } else if (e.message != null) {
                                        errMsg = e.message!;
                                      }
                                      if (context.mounted) {
                                        FuturisticToast.show(
                                          context,
                                          message: errMsg,
                                          isError: true,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        FuturisticToast.show(
                                          context,
                                          message: "System Error: ${e.toString()}",
                                          isError: true,
                                        );
                                      }
                                    } finally {
                                      setStateDialog(() => dialogLoading = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 10,
                            shadowColor: AppColors.accentPurple.withValues(alpha: 0.5),
                          ),
                          child: dialogLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'TRANSMIT RESET LINK',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Theme Background (Purple + Silver)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPurple.withValues(alpha: 0.25),
                  AppColors.background,
                ],
                center: Alignment.topRight,
                radius: 2.0,
              ),
            ),
          ),
          
          // Background Animation
          Positioned(
            bottom: 100,
            left: 50,
            child: Pulse(
              infinite: true,
              duration: const Duration(seconds: 4),
              child: Icon(Icons.bar_chart, size: 250, color: AppColors.accentPurple.withValues(alpha: 0.1)),
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
                          Expanded(child: _buildFacultyPreview()),
                          const SizedBox(width: 40),
                          Expanded(child: _buildLoginForm()),
                        ],
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLoginForm(),
                        const SizedBox(height: 40),
                        _buildFacultyPreview(),
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
    return FadeInRight(
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
                const Icon(Icons.supervised_user_circle, size: 60, color: AppColors.accentPurple),
                const SizedBox(height: 16),
                const Text(
                  'FACULTY PORTAL',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'AI Classroom Monitoring System',
                  style: TextStyle(color: AppColors.accentPurple, fontSize: 12, letterSpacing: 1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val);
                    if (!emailValid) return 'Invalid Email Format';
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge, color: AppColors.accentPurple),
                    labelText: 'Faculty Email',
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
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (val.length < 6) return 'Passcode too short (min 6 chars)';
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.accentPurple),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    labelText: 'Secure Passcode',
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
                          activeColor: AppColors.accentPurple,
                          checkColor: Colors.white,
                        ),
                        const Text('Remember me', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    TextButton(
                      onPressed: _showResetPasswordDialog,
                      child: const Text('Forgot passcode?', style: TextStyle(color: AppColors.accentPurple, fontSize: 12)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                    : const Text('Access Academic Nexus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyPreview() {
    return FadeInLeft(
      duration: const Duration(milliseconds: 900),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            const Text('NEXUS PREVIEW', style: TextStyle(color: Colors.white54, letterSpacing: 4, fontSize: 12)),
            const SizedBox(height: 20),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withValues(alpha: 0.2)),
                    child: const Icon(Icons.people_alt, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class Attendance', style: TextStyle(color: Colors.white70)),
                        Text('89.4% Live', style: TextStyle(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.bold)),
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentPurple.withValues(alpha: 0.2)),
                    child: const Icon(Icons.insights, color: AppColors.accentPurple),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Performance Heatmap', style: TextStyle(color: Colors.white70)),
                        Text('3 Alerts', style: TextStyle(color: AppColors.accentPurple, fontSize: 24, fontWeight: FontWeight.bold)),
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
