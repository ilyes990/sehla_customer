import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../models/meal_model.dart';
import '../../view_models/plats_view_model.dart';
import 'meal_detail_view.dart';

/// Customer-side screen: shows all active plats for a given restaurant
/// in a 2-column grid. Called "Nos Plats".
class PlatsListScreen extends StatefulWidget {
  /// The restaurant id to filter by. Pass null to show all plats.
  final int? idResto;

  /// Optional restaurant name for the app bar subtitle.
  final String? restaurantName;

  const PlatsListScreen({
    super.key,
    this.idResto,
    this.restaurantName,
  });

  @override
  State<PlatsListScreen> createState() => _PlatsListScreenState();
}

class _PlatsListScreenState extends State<PlatsListScreen> {
  late final PlatsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = PlatsViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.loadPlats(idResto: widget.idResto);
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Consumer<PlatsViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) return _buildLoading();
            if (vm.loadState == PlatsLoadState.error) return _buildError(vm);
            if (vm.plats.isEmpty) return _buildEmpty();
            return _buildGrid(vm.plats);
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nos Plats', style: AppTextStyles.headlineMedium),
          if (widget.restaurantName != null)
            Text(widget.restaurantName!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primary)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
          color: AppColors.primary, strokeWidth: 2.5),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Aucun plat disponible pour ce restaurant',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  Widget _buildError(PlatsViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text('Impossible de charger les plats',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => vm.loadPlats(idResto: widget.idResto),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusCircle)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<MealModel> plats) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: plats.length,
      itemBuilder: (context, i) {
        return _PlatGridCard(
          plat: plats[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MealDetailView(meal: plats[i])),
          ),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: i * 50),
              duration: 350.ms,
            )
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              delay: Duration(milliseconds: i * 50),
              duration: 350.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }
}

// ─── Plat Grid Card ───────────────────────────────────────────────────────────
class _PlatGridCard extends StatelessWidget {
  final MealModel plat;
  final VoidCallback? onTap;

  const _PlatGridCard({required this.plat, this.onTap});

  /// French locale price: "1 200 DZD"
  String _formatPrice(double prix) {
    final intPrix = prix.toInt();
    final str = intPrix.toString();
    // Insert space thousands separator
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202f');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} DZD';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: plat.isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusL)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: plat.imageUrl,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) =>
                        const ShimmerBox(
                            width: double.infinity, height: 130, radius: 0),
                    errorWidget: (ctx, url, err) => Container(
                      width: double.infinity,
                      height: 130,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.restaurant_menu_rounded,
                          color: AppColors.textHint, size: 36),
                    ),
                  ),
                  if (!plat.isAvailable)
                    Container(
                      width: double.infinity,
                      height: 130,
                      color: Colors.black38,
                      child: Center(
                        child: Text('Indisponible',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
            // ── Info ───────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plat.name,
                      style: AppTextStyles.headlineSmall
                          .copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      _formatPrice(plat.price),
                      style: AppTextStyles.price
                          .copyWith(fontSize: 13, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    // "Ajouter au panier" button
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: plat.isAvailable
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusM),
                              ),
                              child: MaterialButton(
                                onPressed: onTap,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusM)),
                                child: Text(
                                  'Ajouter',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusM),
                              ),
                              child: Center(
                                child: Text('Indisponible',
                                    style: AppTextStyles.labelSmall
                                        .copyWith(color: AppColors.textHint)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
