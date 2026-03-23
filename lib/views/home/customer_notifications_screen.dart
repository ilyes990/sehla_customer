import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../models/notification_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/customer_notification_view_model.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() =>
      _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState
    extends State<CustomerNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final customerId = int.tryParse(authVm.user?.id ?? '') ?? 0;
      if (customerId > 0) {
        context
            .read<CustomerNotificationViewModel>()
            .startPolling(customerId);
      }
    });
  }

  @override
  void dispose() {
    // Stop polling when user leaves the screen
    // (ViewModel itself will also clean up on dispose, but we stop early here
    //  so the timer doesn't keep running in the background needlessly)
    context.read<CustomerNotificationViewModel>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<CustomerNotificationViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return _buildLoading();
          if (vm.hasError) return _buildError(vm);
          if (vm.notifications.isEmpty) return _buildEmpty();
          return _buildList(vm.notifications);
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

  Widget _buildError(CustomerNotificationViewModel vm) {
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
                final customerId =
                    int.tryParse(authVm.user?.id ?? '') ?? 0;
                vm.fetchNotifications(customerId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<NotificationModel> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingM),
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

// ─── Notification Card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

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
          // Bell icon
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
          // Message + timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.formattedDate,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Retry Button ──────────────────────────────────────────────────────────────
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
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.radiusCircle),
        ),
      ),
    );
  }
}
