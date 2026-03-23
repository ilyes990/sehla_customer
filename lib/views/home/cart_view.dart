import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../view_models/cart_view_model.dart';
import 'checkout_confirmation_view.dart';

/// Cart screen — lists all added plats with qty controls and per-item notes.
class CartView extends StatelessWidget {
  const CartView({super.key});

  /// French locale price formatter: "3 200 DZD"
  static String formatPrice(double prix) {
    final str = prix.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('\u202f');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} DZD';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mon panier', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Consumer<CartViewModel>(
        builder: (context, vm, _) {
          if (vm.isEmpty) return _buildEmpty(context);
          return Column(
            children: [
              Expanded(child: _buildItemList(context, vm)),
              _buildBottomBar(context, vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('Votre panier est vide', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text('Ajoutez des plats pour commencer',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 28),
          CustomButton(
            label: 'Explorer les restaurants',
            variant: ButtonVariant.outline,
            width: 230,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  Widget _buildItemList(BuildContext context, CartViewModel vm) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: vm.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = vm.items[i];
        return _CartItemCard(
          item: item,
          index: i,
          onIncrement: () => vm.incrementQuantity(item.meal.id),
          onDecrement: () => vm.decrementQuantity(item.meal.id),
          onRemove: () => vm.removeItem(item.meal.id),
          onNoteChanged: (note) => vm.updateNote(item.meal.id, note),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: i * 60),
              duration: 300.ms,
            )
            .slideY(
              begin: 0.08,
              end: 0,
              delay: Duration(milliseconds: i * 60),
              duration: 300.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, CartViewModel vm) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.headlineMedium),
              Text(
                formatPrice(vm.totalPrice),
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Confirm button
          CustomButton(
            label: 'Confirmer la commande',
            prefixIcon: Icons.check_circle_outline_rounded,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CheckoutConfirmationView(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Item Card ────────────────────────────────────────────────────────────
class _CartItemCard extends StatefulWidget {
  final CartItem item;
  final int index;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final void Function(String note) onNoteChanged;

  const _CartItemCard({
    required this.item,
    required this.index,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onNoteChanged,
  });

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.item.note);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('cart_item_${widget.item.meal.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 26),
      ),
      onDismissed: (_) => widget.onRemove(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: CachedNetworkImage(
                    imageUrl: widget.item.meal.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(
                        width: 64, height: 64, radius: 12),
                    errorWidget: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.fastfood,
                          color: AppColors.textHint, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.meal.name,
                        style: AppTextStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CartView.formatPrice(
                            widget.item.meal.price * widget.item.quantity),
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                // Remove button
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textHint),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Quantity controls + note
            Row(
              children: [
                // Note field
                Expanded(
                  child: TextField(
                    controller: _noteCtrl,
                    onChanged: widget.onNoteChanged,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Ajouter une note…',
                      hintStyle: AppTextStyles.inputHint.copyWith(fontSize: 12),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                        borderSide:
                            const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Qty controls
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusCircle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(
                          icon: Icons.remove_rounded,
                          onTap: widget.onDecrement),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${widget.item.quantity}',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                      _QtyButton(
                          icon: Icons.add_rounded, onTap: widget.onIncrement),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
