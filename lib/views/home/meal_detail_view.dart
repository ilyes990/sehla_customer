import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../models/meal_model.dart';
import '../../models/restaurant_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/order_view_model.dart';
import 'order_confirmation_view.dart';

class MealDetailView extends StatefulWidget {
  final MealModel meal;

  const MealDetailView({super.key, required this.meal});

  @override
  State<MealDetailView> createState() => _MealDetailViewState();
}

class _MealDetailViewState extends State<MealDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().setCurrentMeal(widget.meal);
    });
  }

  RestaurantModel? get _restaurant {
    try {
      return dummyRestaurants
          .firstWhere((r) => r.id == widget.meal.restaurantId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _onCreateOrder() async {
    final vm = context.read<OrderViewModel>();
    final authVm = context.read<AuthViewModel>();
    final restaurant = _restaurant;

    final success = await vm.createOrder(
      restaurantId: widget.meal.restaurantId,
      restaurantName: restaurant?.name ?? 'Restaurant',
      deliveryAddress: authVm.user?.location ?? 'Adresse non définie',
      deliveryFee: restaurant?.deliveryFee ?? 150,
    );

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationView(order: vm.lastOrder!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildHeroImage(context),
                SliverToBoxAdapter(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
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
        background: CachedNetworkImage(
          imageUrl: widget.meal.imageUrl,
          fit: BoxFit.cover,
          placeholder: (ctx, url) =>
              const ShimmerBox(width: double.infinity, height: 300, radius: 0),
          errorWidget: (ctx, url, err) => Container(
            color: AppColors.surfaceVariant,
            child: const Icon(Icons.fastfood, size: 80),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Name + Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    Text(widget.meal.name, style: AppTextStyles.headlineLarge)
                        .animate()
                        .fadeIn(duration: 400.ms),
              ),
              RatingBadge(rating: widget.meal.rating),
            ],
          ),
          const SizedBox(height: 8),

          // Category + Badges
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusCircle),
                ),
                child: Text(
                  widget.meal.category,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
              if (widget.meal.isVegetarian) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusCircle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco_rounded,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Végétarien',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 13, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text('${widget.meal.prepTimeMin} min',
                      style: AppTextStyles.labelSmall),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Description
          Text(widget.meal.description, style: AppTextStyles.bodyMedium)
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms),
          const SizedBox(height: 20),

          // Ingredients
          if (widget.meal.ingredients.isNotEmpty) ...[
            Text('Ingrédients', style: AppTextStyles.headlineSmall)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.meal.ingredients
                  .map((ing) => TagChip(label: ing))
                  .toList(),
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            const SizedBox(height: 20),
          ],

          // Restaurant Info
          if (_restaurant != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
                    child: const Icon(Icons.storefront_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_restaurant!.name,
                            style: AppTextStyles.labelLarge),
                        Text(_restaurant!.cuisineType,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textHint),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<OrderViewModel>(
      builder: (context, vm, _) {
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
          child: Row(
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: vm.decrementQuantity,
                      icon: const Icon(Icons.remove_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                    Text(
                      '${vm.quantity}',
                      style: AppTextStyles.headlineMedium,
                    ),
                    IconButton(
                      onPressed: vm.incrementQuantity,
                      icon: const Icon(Icons.add_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Order button
              Expanded(
                child: CustomButton(
                  label: widget.meal.isAvailable
                      ? 'Commander · ${vm.totalPrice.toInt()} DA'
                      : 'Indisponible',
                  isLoading: vm.isLoading,
                  onPressed: (widget.meal.isAvailable && !vm.isLoading)
                      ? _onCreateOrder
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
