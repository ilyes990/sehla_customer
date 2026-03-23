import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';

/// Full-screen success confirmation shown after a successful createCommande call.
class OrderSuccessView extends StatelessWidget {
  final int orderId;

  const OrderSuccessView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            children: [
              const Spacer(),
              // ── Animated checkmark ────────────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.primaryShadow,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 66,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                'Commande envoyée !',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              const SizedBox(height: 10),

              // ── Subtitle ──────────────────────────────────────────────────
              Text(
                'Votre commande #$orderId est en\nattente de confirmation',
                style: AppTextStyles.bodyMedium.copyWith(height: 1.55),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 24),

              // ── Status badge ──────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusCircle),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text(
                      'En attente',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 550.ms, duration: 400.ms).scale(
                    delay: 550.ms,
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

              const Spacer(),

              // ── Back to home button ────────────────────────────────────────
              CustomButton(
                label: 'Retour à l\'accueil',
                prefixIcon: Icons.home_outlined,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.routeHome,
                  (route) => false,
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
