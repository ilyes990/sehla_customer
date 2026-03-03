import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../models/order_model.dart';

class OrderConfirmationView extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationView({super.key, required this.order});

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
              _buildSuccessIcon(),
              const SizedBox(height: 28),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 32),
              _buildOrderCard(),
              const Spacer(),
              _buildButtons(context),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: AppColors.primaryShadow,
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildTitle() {
    return Text(
      'Commande Confirmée ! 🎉',
      style: AppTextStyles.headlineLarge,
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }

  Widget _buildSubtitle() {
    return Text(
      'Votre commande est en cours de préparation.\nElle sera livrée dans les meilleurs délais.',
      style: AppTextStyles.bodyMedium,
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _orderRow('Commande #',
              order.id.split('_').last.substring(0, 6).toUpperCase()),
          const Divider(height: 20),
          _orderRow('Restaurant', order.restaurantName),
          const SizedBox(height: 8),
          ...order.items.map((item) => _orderRow(
                '${item.mealName} × ${item.quantity}',
                '${item.totalPrice.toInt()} DA',
              )),
          const Divider(height: 20),
          _orderRow('Frais de livraison', '${order.deliveryFee.toInt()} DA'),
          const SizedBox(height: 8),
          _orderRow(
            '💰 Total',
            '${order.total.toInt()} DA',
            bold: true,
          ),
          const Divider(height: 20),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Icon(Icons.location_on_outlined,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(
          begin: 0.2,
          end: 0,
          delay: 500.ms,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _orderRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: bold
              ? AppTextStyles.labelLarge.copyWith(color: AppColors.primary)
              : AppTextStyles.labelMedium,
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          label: 'Suivre ma commande',
          prefixIcon: Icons.gps_fixed_rounded,
          onPressed: () {},
        ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
        const SizedBox(height: 12),
        CustomButton(
          label: 'Retour à l\'accueil',
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppConstants.routeHome,
            (route) => false,
          ),
        ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
      ],
    );
  }
}
