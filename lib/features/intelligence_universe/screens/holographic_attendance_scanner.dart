import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';

class HolographicAttendanceScanner extends StatelessWidget {
  const HolographicAttendanceScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Feed Background (Dark tinted)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF0A1A2A), Colors.black],
                radius: 1.2,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryNeon),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Holographic Scanner",
                        style: TextStyle(color: AppColors.primaryNeon, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Viewfinder and Laser
                Center(
                  child: FadeIn(
                    duration: const Duration(seconds: 2),
                    child: Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.5), width: 2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppColors.primaryNeon.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5)
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Viewfinder Corners
                          _buildCorner(Alignment.topLeft),
                          _buildCorner(Alignment.topRight),
                          _buildCorner(Alignment.bottomLeft),
                          _buildCorner(Alignment.bottomRight),
                          
                          // Holographic Grid inside Viewfinder
                          CustomPaint(
                            size: const Size(300, 400),
                            painter: GridPainter(color: AppColors.primaryNeon.withValues(alpha: 0.1)),
                          ),
                          
                          // Scanning Laser
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 380),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOutSine,
                            builder: (context, double value, child) {
                              // Wrap in a layout builder or calculate manually to simulate sweeping up and down
                              double modulatedValue = value;
                              if (value > 190) {
                                modulatedValue = 380 - value; // Sweep back up
                              }
                              return Positioned(
                                top: modulatedValue * 2, // scale to fit 400
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNeon,
                                    boxShadow: [
                                      BoxShadow(color: AppColors.primaryNeon, blurRadius: 15, spreadRadius: 5),
                                    ],
                                  ),
                                ),
                              );
                            },
                            onEnd: () {}, // Could loop this if using AnimationController, TweenBuilder is a single pass unless we hack it.
                          ),
                          
                          // Center Face Guide
                          Center(
                            child: Icon(Icons.face, color: AppColors.primaryNeon.withValues(alpha: 0.3), size: 120),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Biometric Match Status
                FadeInUp(
                  delay: const Duration(seconds: 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryNeon),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.fingerprint, color: AppColors.primaryNeon, size: 40),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("BIOMETRIC MATCH: 99.8%", style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
                              SizedBox(height: 4),
                              Text("Identity verified. Attendance recorded.", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight) ? const BorderSide(color: AppColors.primaryNeon, width: 4) : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) ? const BorderSide(color: AppColors.primaryNeon, width: 4) : BorderSide.none,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) ? const BorderSide(color: AppColors.primaryNeon, width: 4) : BorderSide.none,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight) ? const BorderSide(color: AppColors.primaryNeon, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
