import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';

class FuturisticToast {
  static void show(BuildContext context, {required String message, bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isError ? Colors.redAccent.withValues(alpha: 0.1) : AppColors.primaryNeon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isError ? Colors.redAccent : AppColors.primaryNeon, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: isError ? Colors.redAccent.withValues(alpha: 0.2) : AppColors.primaryNeon.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: isError ? Colors.redAccent : AppColors.primaryNeon,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the toast after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
