import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_text_styles.dart';
import '../../../models/notification_model.dart';
import '../../../view_models/auth_view_model.dart';
import '../../../view_models/livreur_notification_view_model.dart';

class LivreurNotificationsScreen extends StatefulWidget {
  const LivreurNotificationsScreen({super.key});

  @override
  State<LivreurNotificationsScreen> createState() =>
      _LivreurNotificationsScreenState();
}

class _LivreurNotificationsScreenState
    extends State<LivreurNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final livreurId = int.tryParse(authVm.livreur?.id ?? '') ?? 0;
      if (livreurId > 0) {
        context
            .read<LivreurNotificationViewModel>()
            .startPolling(livreurId);
      }
    });
  }

  @override
  void dispose() {
    context.read<LivreurNotificationViewModel>().stopPolling();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _showToast(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: color ?? AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _onTakeOrder(NotificationModel notif) async {
    final authVm = context.read<AuthViewModel>();
    final vm = context.read<LivreurNotificationViewModel>();
    final livreurId = int.tryParse(authVm.livreur?.id ?? '') ?? 0;

    final result = await vm.takeOrder(
      notifId: notif.id,
      livreurId: livreurId,
    );

    switch (result) {
      case TakeOrderResult.success:
        _showToast(
          'Commande réservée avec succès ✓',
          color: AppColors.primary,
        );
        break;
      case TakeOrderResult.conflict409:
        _showToast(
          'Cette commande vient d\'être prise par un autre livreur',
          color: AppColors.warning,
        );
        break;
      case TakeOrderResult.notFound404:
        _showToast('Commande introuvable', color: AppColors.error);
        break;
      case TakeOrderResult.badRequest400:
      case TakeOrderResult.error:
        _showToast('Une erreur est survenue, réessayez',
            color: AppColors.error);
        break;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<LivreurNotificationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return _buildLoading();
          if (vm.hasError) return _buildError(vm);
          if (vm.notifications.isEmpty) return _buildEmpty();
          return _buildList(vm);
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Notifications', style: AppTextStyles.headlineMedium),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 72,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification pour le moment',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  Widget _buildError(LivreurNotificationViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger les notifications',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _RetryButton(
              onPressed: () {
                final authVm = context.read<AuthViewModel>();
                final livreurId =
                    int.tryParse(authVm.livreur?.id ?? '') ?? 0;
                vm.fetchNotifications(livreurId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(LivreurNotificationViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingM),
      itemCount: vm.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final notif = vm.notifications[i];
        return _OrderNotifCard(
          notification: notif,
          isTaking: vm.isTakingOrder(notif.id),
          onTakeOrder: () => _onTakeOrder(notif),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: i * 60),
              duration: 350.ms,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: i * 60),
              duration: 350.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }
}

// ─── Order Notification Card ───────────────────────────────────────────────────
class _OrderNotifCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isTaking;
  final VoidCallback onTakeOrder;

  const _OrderNotifCard({
    required this.notification,
    required this.isTaking,
    required this.onTakeOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isLibre = notification.isLibre;
    final isReserved = notification.isReserved;

    // Decide if this is a rich order notification or a simple message notification
    final isOrderNotif = notification.restoNom != null ||
        notification.lesPlats.isNotEmpty ||
        notification.status != null;

    if (!isOrderNotif) {
      // Fallback: simple message card (backward-compatible)
      return _SimpleNotifCard(notification: notification);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isLibre
              ? AppColors.primaryLight
              : isReserved
                  ? AppColors.accentLight
                  : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Header row: restaurant name + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.restoNom ?? 'Restaurant',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: notification.status),
            ],
          ),

          const SizedBox(height: 10),

          // ─ Plats list
          if (notification.lesPlats.isNotEmpty) ...[
            ...notification.lesPlats.map((plat) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 6, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${plat.nom} x${plat.quantite}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
          ] else if (notification.message.isNotEmpty) ...[
            Text(notification.message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 10),
          ],

          // ─ Date
          Text(
            notification.formattedDate,
            style: AppTextStyles.bodySmall,
          ),

          // ─ Action button (only for "libre" status)
          if (isLibre) ...[
            const SizedBox(height: 14),
            _TakeOrderButton(
              isTaking: isTaking,
              onPressed: isTaking ? null : onTakeOrder,
            ),
          ] else if (isReserved) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusCircle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Commande réservée ✓',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Simple fallback notification card (no status / order info) ───────────────
class _SimpleNotifCard extends StatelessWidget {
  final NotificationModel notification;
  const _SimpleNotifCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.primaryLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Icon(Icons.notifications_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message, style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(notification.formattedDate,
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String? status;
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'libre':
        bg = AppColors.primary;
        fg = Colors.white;
        label = 'Disponible';
        break;
      case 'reserved':
        bg = AppColors.accent;
        fg = Colors.white;
        label = 'Réservée';
        break;
      default:
        bg = AppColors.border;
        fg = AppColors.textSecondary;
        label = 'Non disponible';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Take Order Button ────────────────────────────────────────────────────────
class _TakeOrderButton extends StatelessWidget {
  final bool isTaking;
  final VoidCallback? onPressed;

  const _TakeOrderButton({required this.isTaking, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)]),
          borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
          boxShadow: onPressed != null ? AppColors.primaryShadow : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
            child: Center(
              child: isTaking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Prendre la commande',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Retry Button ─────────────────────────────────────────────────────────────
class _RetryButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RetryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text('Réessayer'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
        ),
      ),
    );
  }
}
