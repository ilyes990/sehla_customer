import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_text_styles.dart';
import '../../../core/design_system.dart';
import '../../../models/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onTap;
  final bool horizontal;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return horizontal ? _buildHorizontal() : _buildVertical();
  }

  Widget _buildVertical() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImage(240, 120, horizontal: false),
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
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: AppColors.cardShadow,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(100, 100, horizontal: true),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: _buildInfo(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textHint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(double width, double height, {required bool horizontal}) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(AppConstants.radiusL),
        topRight: horizontal
            ? Radius.zero
            : const Radius.circular(AppConstants.radiusL),
        bottomLeft: horizontal
            ? const Radius.circular(AppConstants.radiusL)
            : Radius.zero,
      ),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl:
                "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80",
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => ShimmerBox(
              width: width,
              height: height,
              radius: 0,
            ),
            errorWidget: (ctx, url, err) => Container(
              width: width,
              height: height,
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.restaurant, color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                restaurant.name,
                style: AppTextStyles.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          restaurant.tel ?? '',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(text,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
