import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/cart_view_model.dart';
import 'cart_view.dart';
import 'order_success_view.dart';

/// Pre-submit confirmation screen.
/// Shows order summary → customer taps "Passer la commande" → calls API.
class CheckoutConfirmationView extends StatefulWidget {
  const CheckoutConfirmationView({super.key});

  @override
  State<CheckoutConfirmationView> createState() =>
      _CheckoutConfirmationViewState();
}

class _CheckoutConfirmationViewState extends State<CheckoutConfirmationView> {
  bool _submitting = false;

  void _showToast(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: color ?? AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _onPasser() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final authVm = context.read<AuthViewModel>();
    final cartVm = context.read<CartViewModel>();
    final user = authVm.user;

    if (user == null) {
      setState(() => _submitting = false);
      _showToast('Session expirée, veuillez vous reconnecter');
      return;
    }

    final success = await cartVm.submitOrder(user);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      // Navigate to success screen, removing confirmation + cart from stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessView(orderId: cartVm.lastOrderId ?? 0),
        ),
        (route) => route.settings.name == AppConstants.routeHome ||
            route.isFirst,
      );
    } else {
      final msg = cartVm.errorMessage ?? '';
      if (msg.contains('serveur') || msg.isEmpty) {
        _showToast('Erreur serveur, veuillez réessayer', color: AppColors.error);
      } else {
        _showToast(msg, color: AppColors.error);
      }
      cartVm.resetSubmitState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Récapitulatif', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Consumer2<CartViewModel, AuthViewModel>(
        builder: (context, cartVm, authVm, _) {
          final restaurant = cartVm.currentRestaurant;
          final user = authVm.user;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Restaurant info ─────────────────────────────────────
                      if (restaurant != null)
                        _SectionCard(
                          icon: Icons.storefront_outlined,
                          title: restaurant.name,
                          subtitle: restaurant.description,
                        ).animate().fadeIn(duration: 350.ms),

                      const SizedBox(height: 12),

                      // ── Items ───────────────────────────────────────────────
                      _buildItemsSection(cartVm),

                      const SizedBox(height: 12),

                      // ── Delivery location ───────────────────────────────────
                      if (user != null)
                        _SectionCard(
                          icon: Icons.location_on_outlined,
                          title: 'Adresse de livraison',
                          subtitle: user.location ?? 'Non définie',
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 350.ms),

                      const SizedBox(height: 12),

                      // ── Total ───────────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusL),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total à payer',
                                style: AppTextStyles.headlineSmall),
                            Text(
                              CartView.formatPrice(cartVm.totalPrice),
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 350.ms),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemsSection(CartViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text('Commande', style: AppTextStyles.headlineSmall),
          ),
          const SizedBox(height: 8),
          ...vm.items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (i > 0)
                  const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.meal.name} × ${item.quantity}',
                              style: AppTextStyles.labelMedium,
                            ),
                            if (item.note.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Note: ${item.note}',
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        CartView.formatPrice(item.totalPrice),
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 350.ms);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppConstants.paddingL, 16, AppConstants.paddingL, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CustomButton(
        label: 'Passer la commande',
        prefixIcon: Icons.delivery_dining_rounded,
        isLoading: _submitting,
        onPressed: _submitting ? null : _onPasser,
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
