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
            .fetchNotifications(livreurId);
      }
    });
  }

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
          return _buildList(vm.notifications);
        },
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
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

  // ── Loading ─────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
      ),
    );
  }

  // ── Empty ───────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
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

  // ── Error ───────────────────────────────────────────────────────────────────
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
              vm.errorMessage ?? 'Impossible de charger les notifications',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final authVm = context.read<AuthViewModel>();
                final livreurId = int.tryParse(authVm.livreur?.id ?? '') ?? 0;
                vm.fetchNotifications(livreurId);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusCircle),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List ────────────────────────────────────────────────────────────────────
  Widget _buildList(List<NotificationModel> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM, vertical: AppConstants.paddingM),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        return _NotificationCard(notification: notifications[i])
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

// ─── Notification Card ──────────────────────────────────────────────────────────
// Same clean simple style as the customer side.
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LivreurNotificationViewModel>();
    final authVm = context.read<AuthViewModel>();
    final livreurId = int.tryParse(authVm.livreur?.id ?? '') ?? 0;

    final isReserved =
        notification.status == 'reserved' || notification.status == 'acceptée';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
        border: isReserved
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isReserved ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  isReserved
                      ? Icons.local_shipping_rounded
                      : Icons.notifications_rounded,
                  color: isReserved ? AppColors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message.isNotEmpty
                          ? notification.message
                          : (isReserved
                              ? 'Commande en cours'
                              : 'Nouvelle commande'),
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.createdAt.toString(),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              if (isReserved)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'RESERVÉ',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          if (isReserved && notification.restoNom != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.restaurant_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(notification.restoNom!, style: AppTextStyles.labelLarge),
              ],
            ),
            if (notification.lesplats != null &&
                notification.lesplats!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...notification.lesplats!.map((p) => Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 4),
                    child: Text('• ${p.quantite}x ${p.nom}',
                        style: AppTextStyles.bodySmall),
                  )),
            ],
          ],

          const SizedBox(height: 16),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: isReserved
                ? ElevatedButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final success = await vm.markAsDelivered(
                                notification.idCommande!, notification.id);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Commande marquée comme livrée !')),
                              );
                              // Refresh to update list
                              vm.fetchNotifications(livreurId);
                            }
                          },
                    icon: vm.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline_rounded,
                            size: 20),
                    label: Text(vm.isLoading
                        ? 'Traitement...'
                        : 'Marquer comme Livrée'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM)),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final success =
                                await vm.takeOrder(notification.id, livreurId);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Vous avez pris la commande !')),
                              );
                            }
                          },
                    icon: vm.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.shopping_bag_outlined, size: 20),
                    label: Text(
                        vm.isLoading ? 'Traitement...' : 'Prendre la commande'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
