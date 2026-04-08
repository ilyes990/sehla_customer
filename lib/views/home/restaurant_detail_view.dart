import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sehla_customer/views/base_view.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../models/meal_model.dart';
import '../../models/restaurant_model.dart';
import '../../view_models/restaurant_view_model.dart';
import 'meal_detail_view.dart';

class RestaurantDetailView extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailView({super.key, required this.restaurant});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  List<MealModel> meals = [];
  bool _isLoading = true;
  String? _error;

  Future<void> getMealsByRestaurant(
      RestaurantViewModel vm, BuildContext context) async {
    var result = await vm.loadPlats(idResto: widget.restaurant.id);
    if (result is List<MealModel>) {
      meals = result;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plats chargés avec succès")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des plats")),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = result is List<MealModel>
            ? null
            : 'Erreur lors du chargement des plats';
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<RestaurantViewModel>(onModelReady: (model) {
      getMealsByRestaurant(model, context);
    }, builder: (context, vm, _) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfo(),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  _buildMealsSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: AppColors.textPrimary),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80",
              fit: BoxFit.cover,
              placeholder: (ctx, url) => const ShimmerBox(
                  width: double.infinity, height: 250, radius: 0),
              errorWidget: (ctx, url, err) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.restaurant, size: 60),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.restaurant.name, style: AppTextStyles.headlineLarge)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMealsSection() {
    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_error != null) {
      return _buildError();
    }

    if (meals.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Text('Notre menu', style: AppTextStyles.headlineMedium),
        ),
        const SizedBox(height: 4),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Text(
            '${meals.length} plat${meals.length > 1 ? 's' : ''} disponible${meals.length > 1 ? 's' : ''}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Column(
            children: meals.asMap().entries.map((e) {
              final i = e.key;
              final meal = e.value;
              final delay = i * 60;
              return _buildMealCard(meal, delay);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealModel meal, int delay) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailView(meal: meal)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: AppColors.cardShadow,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  bottomLeft: Radius.circular(AppConstants.radiusL),
                ),
                child: CachedNetworkImage(
                  imageUrl: meal.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) =>
                      ShimmerBox(width: 90, height: 90, radius: 0),
                  errorWidget: (ctx, url, err) => Container(
                    width: 90,
                    height: 90,
                    color: AppColors.surfaceVariant,
                    child:
                        const Icon(Icons.fastfood, color: AppColors.textHint),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        meal.nom,
                        style:
                            AppTextStyles.headlineSmall.copyWith(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatPrice(meal.prix),
                        style: AppTextStyles.price.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Add button
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  /// French locale price: "1 200 DZD"
  static String _formatPrice(double prix) {
    final str = prix.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202f');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} DZD';
  }

  Widget _buildLoadingShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: ShimmerBox(width: 120, height: 22, radius: 8),
        ),
        const SizedBox(height: 16),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Column(
            children: List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: const ShimmerBox(
                    width: double.infinity, height: 100, radius: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_menu_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('Aucun plat disponible', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Ce restaurant n\'a pas encore de plats listés.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textHint, size: 56),
            const SizedBox(height: 12),
            Text('Erreur de chargement', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Réessayer',
              variant: ButtonVariant.outline,
              width: 160,
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                getMealsByRestaurant(
                    context.read<RestaurantViewModel>(), context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
