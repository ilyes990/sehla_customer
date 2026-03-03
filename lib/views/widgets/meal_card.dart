import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_text_styles.dart';
import '../../../core/design_system.dart';
import '../../../models/meal_model.dart';

class MealCard extends StatelessWidget {
  final MealModel meal;
  final VoidCallback? onTap;
  final bool horizontal;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return horizontal ? _buildHorizontal() : _buildVertical();
  }

  Widget _buildVertical() {
    return GestureDetector(
      onTap: meal.isAvailable ? onTap : null,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImage(170, 105,
                borderRadius: AppConstants.radiusL, horizontal: false),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _buildInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontal() {
    return GestureDetector(
      onTap: meal.isAvailable ? onTap : null,
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
              _buildImage(90, 90,
                  borderRadius: AppConstants.radiusL, horizontal: true),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _buildInfo(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: meal.isAvailable
                          ? AppColors.primaryLight
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: meal.isAvailable
                          ? AppColors.primaryDark
                          : AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(double width, double height,
      {required double borderRadius, required bool horizontal}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: horizontal ? Radius.zero : Radius.circular(borderRadius),
            bottomLeft:
                horizontal ? Radius.circular(borderRadius) : Radius.zero,
          ),
          child: CachedNetworkImage(
            imageUrl: meal.imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (ctx, url) =>
                ShimmerBox(width: width, height: height, radius: 0),
            errorWidget: (ctx, url, err) => Container(
              width: width,
              height: height,
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.fastfood, color: AppColors.textHint),
            ),
          ),
        ),
        if (meal.isVegetarian)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
              ),
              child:
                  const Icon(Icons.eco_rounded, color: Colors.white, size: 12),
            ),
          ),
        if (!meal.isAvailable)
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight:
                  horizontal ? Radius.zero : Radius.circular(borderRadius),
              bottomLeft:
                  horizontal ? Radius.circular(borderRadius) : Radius.zero,
            ),
            child: Container(
              width: width,
              height: height,
              color: Colors.black38,
              child: Center(
                child: Text('Indisponible',
                    style:
                        AppTextStyles.labelSmall.copyWith(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          meal.name,
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          meal.category,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '${meal.price.toInt()} DA',
                style: AppTextStyles.price.copyWith(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            RatingBadge(rating: meal.rating, small: true),
          ],
        ),
      ],
    );
  }
}
