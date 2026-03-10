import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../models/meal_model.dart';
import '../../models/restaurant_model.dart';
import '../../services/restaurant_service.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_view.dart';

class RestaurantDetailView extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailView({super.key, required this.restaurant});

  @override
  State<RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<RestaurantDetailView> {
  final RestaurantService _restaurantService = RestaurantService();
  List<MealModel> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    try {
      final meals =
          await _restaurantService.getMealsByRestaurant(widget.restaurant.id);
      if (mounted) {
        setState(() {
          _meals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 20),
                _buildTags(),
                const SizedBox(height: 24),
                _buildMealsSection(context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
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
              imageUrl: widget.restaurant.imageUrl,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.restaurant.name,
                            style: AppTextStyles.headlineLarge)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.1, end: 0, duration: 400.ms),
                    const SizedBox(height: 4),
                    Text(widget.restaurant.cuisineType,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600))
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms),
                  ],
                ),
              ),
              RatingBadge(rating: widget.restaurant.rating),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statBadge(Icons.timer_outlined,
                  '${widget.restaurant.deliveryTimeMin} min', 'Livraison'),
              const SizedBox(width: 12),
              _statBadge(Icons.delivery_dining_outlined,
                  '${widget.restaurant.deliveryFee.toInt()} DA', 'Frais'),
              const SizedBox(width: 12),
              _statBadge(Icons.shopping_bag_outlined,
                  '${widget.restaurant.minOrder.toInt()} DA', 'Minimum'),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),
          Text(widget.restaurant.description, style: AppTextStyles.bodyMedium)
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _statBadge(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.primaryDark)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    if (widget.restaurant.tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.restaurant.tags.map((t) => TagChip(label: t)).toList(),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildMealsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          child: Text('Notre menu', style: AppTextStyles.headlineMedium),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingXL),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_meals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingXL),
              child: Text('Aucun plat disponible',
                  style: AppTextStyles.bodyMedium),
            ),
          )
        else
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Column(
              children: _meals.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                return MealCard(
                  meal: m,
                  horizontal: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MealDetailView(meal: m)),
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: i * 80),
                      duration: 400.ms,
                    )
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      delay: Duration(milliseconds: i * 80),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
