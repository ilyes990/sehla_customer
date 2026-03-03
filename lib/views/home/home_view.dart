import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/home_view_model.dart';
import '../home/meal_detail_view.dart';
import '../home/restaurant_detail_view.dart';
import '../widgets/meal_card.dart';
import '../widgets/restaurant_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentBottomIndex = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentBottomIndex,
        children: const [
          _HomeTab(),
          _ExploreTab(),
          _OrdersTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Explorer',
                  index: 1,
                  currentIndex: _currentBottomIndex,
                  onTap: () => setState(() => _currentBottomIndex = 1)),
              _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Commandes',
                  index: 2,
                  currentIndex: _currentBottomIndex,
                  onTap: () => setState(() => _currentBottomIndex = 2)),
              _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  index: 3,
                  currentIndex: _currentBottomIndex,
                  onTap: () => setState(() => _currentBottomIndex = 3)),
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
    return Consumer2<HomeViewModel, AuthViewModel>(
      builder: (context, homeVm, authVm, _) {
        return CustomScrollView(
          slivers: [
            _buildAppBar(context, authVm),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSearchBar(context, homeVm),
                  const SizedBox(height: 8),
                  _buildCategoryFilter(homeVm),
                  const SizedBox(height: 20),
                  if (homeVm.isLoading) ...[
                    _buildShimmerFeatured(),
                    const SizedBox(height: 20),
                    _buildShimmerList(),
                  ] else if (homeVm.loadingState == HomeLoadingState.error) ...[
                    _buildError(context, homeVm),
                  ] else ...[
                    _buildFeaturedSection(context, homeVm),
                    const SizedBox(height: 24),
                    _buildPopularMealsSection(context, homeVm),
                    const SizedBox(height: 24),
                    _buildAllRestaurantsSection(context, homeVm),
                    const SizedBox(height: 80),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, AuthViewModel authVm) {
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
                      Text(
                        authVm.user?.location?.split(',').first ??
                            'Alger Centre',
                        style: AppTextStyles.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(Icons.notifications_outlined,
                            color: AppColors.primary, size: 22),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingL, vertical: 8),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppColors.textHint, size: 20),
              const SizedBox(width: 10),
              Text('Rechercher restaurants, plats...',
                  style: AppTextStyles.inputHint),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildCategoryFilter(HomeViewModel vm) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        itemCount: vm.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = vm.categories[i];
          return TagChip(
            label: cat,
            selected: vm.selectedCategory == cat,
            onTap: () => vm.selectCategory(cat),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: i * 50), duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, HomeViewModel vm) {
    if (vm.featuredRestaurants.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: SectionHeader(title: '🔥 À la une'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            itemCount: vm.featuredRestaurants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final r = vm.featuredRestaurants[i];
              return RestaurantCard(
                restaurant: r,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailView(restaurant: r),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: i * 100),
                    duration: 400.ms,
                  )
                  .slideX(
                    begin: 0.2,
                    end: 0,
                    delay: Duration(milliseconds: i * 100),
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularMealsSection(BuildContext context, HomeViewModel vm) {
    if (vm.popularMeals.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: SectionHeader(
            title: '⭐ Plats populaires',
            actionLabel: 'Voir tout',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            itemCount: vm.popularMeals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final m = vm.popularMeals[i];
              return MealCard(
                meal: m,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealDetailView(meal: m),
                  ),
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: i * 80),
                    duration: 400.ms,
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllRestaurantsSection(BuildContext context, HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: SectionHeader(title: '🍽️ Tous les Restos'),
        ),
        const SizedBox(height: 12),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Column(
            children: vm.filteredRestaurants.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              return RestaurantCard(
                restaurant: r,
                horizontal: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailView(restaurant: r),
                  ),
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: i * 80),
                    duration: 400.ms,
                  );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, HomeViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textHint, size: 60),
            const SizedBox(height: 12),
            Text('Impossible de charger', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(vm.errorMessage ?? '', style: AppTextStyles.bodyMedium),
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

  Widget _buildShimmerFeatured() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: ShimmerBox(width: 140, height: 22, radius: 8),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, __) =>
                const ShimmerBox(width: 240, height: 210, radius: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: const ShimmerBox(
                width: double.infinity, height: 110, radius: 16),
          ),
        ),
      ),
    );
  }
}

// ─── Explore Tab ──────────────────────────────────────────────────────────────
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorer'), centerTitle: false),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Catégories', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.4,
                    children: vm.categories
                        .where((c) => c != 'Tous')
                        .map((c) => _CategoryGridItem(category: c))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final String category;
  const _CategoryGridItem({required this.category});

  static const Map<String, IconData> _icons = {
    'Algérienne': Icons.restaurant_menu_rounded,
    'Italienne': Icons.local_pizza_outlined,
    'Fast Food': Icons.fastfood_rounded,
    'Japonaise': Icons.set_meal_rounded,
    'Mexicaine': Icons.lunch_dining_rounded,
    'Healthy': Icons.eco_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(builder: (context, vm, _) {
      final isSelected = vm.selectedCategory == category;
      return GestureDetector(
        onTap: () {
          vm.selectCategory(category);
        },
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow:
                isSelected ? AppColors.primaryShadow : AppColors.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icons[category] ?? Icons.restaurant,
                size: 32,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );
    });
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
