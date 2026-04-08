import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../core/enums_view_state.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/customer_notification_view_model.dart';
import '../../view_models/home_view_model.dart';
import '../base_view.dart';
import '../home/restaurant_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentBottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      onModelReady: (model) {
        model.loadHomeData();
      },
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _currentBottomIndex,
            children: const [
              _HomeTab(),
              _OrdersTab(),
              _ProfileTab(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Accueil',
                  index: 0,
                  currentIndex: _currentBottomIndex,
                  onTap: () => setState(() => _currentBottomIndex = 0)),
              _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Commandes',
                  index: 1,
                  currentIndex: _currentBottomIndex,
                  onTap: () => setState(() => _currentBottomIndex = 1)),
              _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  index: 2,
                  currentIndex: _currentBottomIndex,
                  onTap: () => setState(() => _currentBottomIndex = 2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── NavItem ──────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        return CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: _buildBody(context, vm),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 68,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.primary, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            'Livraison à',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Consumer<AuthViewModel>(
                        builder: (context, authVm, _) {
                          return Text(
                            authVm.user?.location?.split(',').first ??
                                'Alger Centre',
                            style: AppTextStyles.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Bell icon with badge
                Consumer<CustomerNotificationViewModel>(
                  builder: (ctx, notifVm, _) {
                    final unread = notifVm.unreadCount;
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, AppConstants.routeCustomerNotifications),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusM),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(Icons.notifications_outlined,
                                  color: AppColors.primary, size: 22),
                            ),
                            if (unread > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    // Loading state
    if (vm.state == ViewState.Busy) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: const ShimmerBox(
                  width: double.infinity, height: 90, radius: 16),
            ),
          ),
        ),
      );
    }

    // Error state
    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.wifi_off_rounded,
                  color: AppColors.textHint, size: 60),
              const SizedBox(height: 12),
              Text('Impossible de charger',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(vm.errorMessage!, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 20),
              CustomButton(
                label: 'Réessayer',
                variant: ButtonVariant.outline,
                width: 160,
                onPressed: () => vm.loadHomeData(),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (vm.restaurants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.restaurant_outlined,
                  color: AppColors.textHint, size: 60),
              const SizedBox(height: 12),
              Text('Aucun restaurant', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text('Aucun restaurant disponible pour le moment.',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 20),
              CustomButton(
                label: 'Réessayer',
                variant: ButtonVariant.outline,
                width: 160,
                onPressed: () => vm.loadHomeData(),
              ),
            ],
          ),
        ),
      );
    }

    // Success — display restaurant list
    return _buildRestaurantsList(context, vm);
  }

  Widget _buildRestaurantsList(BuildContext context, HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: SectionHeader(title: '🍽️ Restaurants'),
        ),
        const SizedBox(height: 12),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Column(
            children: vm.restaurants.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              return _RestaurantTile(restaurant: r)
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: i * 80),
                    duration: 400.ms,
                  );
            }).toList(),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Restaurant Tile (simple, matches API fields) ─────────────────────────────
class _RestaurantTile extends StatelessWidget {
  final dynamic restaurant;
  const _RestaurantTile({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailView(restaurant: restaurant),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Restaurant icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: AppTextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (restaurant.tel != null)
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.tel!,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  if (restaurant.email != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.email!,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Orders Tab ───────────────────────────────────────────────────────────────
class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Commandes'), centerTitle: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Aucune commande', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Vos commandes apparaîtront ici',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Tab ──────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil'), centerTitle: false),
      body: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          final user = vm.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.primaryShadow,
                  ),
                  child: Center(
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: AppTextStyles.displayLarge
                          .copyWith(color: Colors.white, fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? '', style: AppTextStyles.headlineLarge),
                Text(user?.email ?? '', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 28),
                _profileTile(Icons.person_outline_rounded, 'Mon profil', () {}),
                _profileTile(Icons.location_on_outlined, 'Mes adresses', () {}),
                _profileTile(Icons.history_rounded, 'Historique', () {}),
                _profileTile(Icons.settings_outlined, 'Paramètres', () {}),
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Se déconnecter',
                  variant: ButtonVariant.outline,
                  onPressed: () => vm.logout().then((_) {
                    Navigator.pushReplacementNamed(
                        context, AppConstants.routeLogin);
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: AppTextStyles.labelLarge),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.textHint),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          side: const BorderSide(color: AppColors.border),
        ),
        tileColor: AppColors.white,
      ),
    );
  }
}
