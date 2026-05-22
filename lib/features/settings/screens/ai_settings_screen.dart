import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../auth/services/auth_service.dart';
import '../../intelligence_universe/screens/intelligence_universe_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiSettingsScreen extends StatelessWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              "Neural Settings",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "System configuration & AI control",
              style: TextStyle(
                color: AppColors.accentPink.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Entry Point to the 50-Feature Universe
          FadeInUp(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IntelligenceUniverseScreen()),
                  );
                },
                icon: const Icon(Icons.language, color: Colors.white),
                label: const Text("ENTER INTELLIGENCE UNIVERSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNeon.withValues(alpha: 0.3),
                  side: BorderSide(color: AppColors.primaryNeon, width: 2),
                  shadowColor: AppColors.primaryNeon,
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildSettingsGroup(
              title: "AI Assistant Controls",
              icon: Icons.psychology,
              color: AppColors.primaryNeon,
              children: [
                _buildToggle("Adaptive Learning Mode", true, AppColors.primaryNeon),
                _buildToggle("Auto-generate Study Paths", true, AppColors.primaryNeon),
                _buildToggle("Strict Focus Enforcement", false, AppColors.primaryNeon),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildSettingsGroup(
              title: "Security & Privacy",
              icon: Icons.security,
              color: AppColors.secondaryNeon,
              children: [
                _buildToggle("Biometric Authentication", true, AppColors.secondaryNeon),
                _buildToggle("Encrypt Cognitive Data", true, AppColors.secondaryNeon),
                _buildToggle("Share Anonymous Analytics", false, AppColors.secondaryNeon),
                _buildActionTile(context, "Change Security Passcode", Icons.key, AppColors.secondaryNeon, () {
                  _showChangePasswordDialog(context);
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: _buildSettingsGroup(
              title: "Personalization",
              icon: Icons.color_lens,
              color: AppColors.accentPink,
              children: [
                _buildToggle("Holographic Effects", true, AppColors.accentPink),
                _buildToggle("Cinematic Transitions", true, AppColors.accentPink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return HolographicCard(
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15))),
          Switch(
            value: value,
            onChanged: (v) {},
            activeThumbColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 12),
                  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final changeFormKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final AuthService authService = AuthService();

    bool oldObscure = true;
    bool newObscure = true;
    bool confirmObscure = true;
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
                child: HolographicCard(
                  glowColor: AppColors.secondaryNeon,
                  child: Form(
                    key: changeFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.security_update_good, color: AppColors.secondaryNeon, size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    'UPDATE PASSCODE',
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
                            'Please verify your identity with your current passcode before updating to a new neural passcode.',
                            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          
                          // Old Password Input
                          TextFormField(
                            controller: oldPasswordController,
                            obscureText: oldObscure,
                            style: const TextStyle(color: Colors.white),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              if (val.length < 6) return 'Passcode too short (min 6 chars)';
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondaryNeon),
                              suffixIcon: IconButton(
                                icon: Icon(oldObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                                onPressed: () => setStateDialog(() => oldObscure = !oldObscure),
                              ),
                              labelText: 'Current Passcode',
                              labelStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.secondaryNeon.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.secondaryNeon),
                              ),
                              filled: true,
                              fillColor: Colors.black26,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // New Password Input
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: newObscure,
                            style: const TextStyle(color: Colors.white),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              if (val.length < 6) return 'Passcode too short (min 6 chars)';
                              if (val == oldPasswordController.text) return 'New passcode must be different';
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppColors.secondaryNeon),
                              suffixIcon: IconButton(
                                icon: Icon(newObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                                onPressed: () => setStateDialog(() => newObscure = !newObscure),
                              ),
                              labelText: 'New Passcode',
                              labelStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.secondaryNeon.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.secondaryNeon),
                              ),
                              filled: true,
                              fillColor: Colors.black26,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Input
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: confirmObscure,
                            style: const TextStyle(color: Colors.white),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              if (val != newPasswordController.text) return 'Passcodes do not match';
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.check_circle_outline, color: AppColors.secondaryNeon),
                              suffixIcon: IconButton(
                                icon: Icon(confirmObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                                onPressed: () => setStateDialog(() => confirmObscure = !confirmObscure),
                              ),
                              labelText: 'Confirm New Passcode',
                              labelStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.secondaryNeon.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.secondaryNeon),
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
                                    if (changeFormKey.currentState!.validate()) {
                                      setStateDialog(() => dialogLoading = true);
                                      try {
                                        await authService.changePassword(
                                          oldPassword: oldPasswordController.text.trim(),
                                          newPassword: newPasswordController.text.trim(),
                                        );
                                        
                                        if (context.mounted) {
                                          FuturisticToast.show(
                                            context,
                                            message: "Passcode updated successfully.",
                                          );
                                          Navigator.pop(context);
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        String errMsg = "Update Failed: ${e.message}";
                                        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                                          errMsg = "Incorrect old passcode.";
                                        } else if (e.code == 'requires-recent-login') {
                                          errMsg = "Session expired. Please log out and back in to change passcode.";
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
                              backgroundColor: AppColors.secondaryNeon,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 10,
                              shadowColor: AppColors.secondaryNeon.withValues(alpha: 0.5),
                            ),
                            child: dialogLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text(
                                    'UPDATE NEURAL PASSCODE',
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
              ),
            );
          },
        );
      },
    );
  }
}
