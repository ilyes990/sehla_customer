import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../view_models/auth_view_model.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final _addressController = TextEditingController();
  String? _selectedAddress;

  final List<String> _suggestedAddresses = [
    '12 Rue Didouche Mourad, Alger Centre',
    '5 Boulevard Khemisti, Alger',
    '8 Rue Larbi Ben M\'Hidi, Hussein Dey',
    '22 Avenue de l\'ALN, Bab Ezzouar',
    '3 Rue Ahmed Ghermoul, El Biar',
  ];

  void _selectAddress(String address) {
    setState(() {
      _selectedAddress = address;
      _addressController.text = address;
    });
  }

  void _confirmLocation() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez entrer une adresse'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        ),
      );
      return;
    }
    context.read<AuthViewModel>().updateLocation(address);
    Navigator.pushReplacementNamed(context, AppConstants.routeHome);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choisir l\'adresse'),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppConstants.routeLogin),
        ),
      ),
      body: Column(
        children: [
          // MAP PLACEHOLDER
          _buildMapPlaceholder(),
          // BOTTOM SHEET
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusXL)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusCircle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Adresse de livraison',
                            style: AppTextStyles.headlineMedium)
                        .animate()
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 6),
                    Text(
                      'Saisissez ou sélectionnez votre adresse',
                      style: AppTextStyles.bodyMedium,
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: '',
                      hint: 'Entrez votre adresse...',
                      controller: _addressController,
                      prefixIcon: Icons.location_on_outlined,
                      keyboardType: TextInputType.streetAddress,
                      onChanged: (_) => setState(() {}),
                      suffix: _addressController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.textHint, size: 18),
                              onPressed: () {
                                _addressController.clear();
                                setState(() => _selectedAddress = null);
                              },
                            )
                          : null,
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                    const SizedBox(height: 20),
                    Text('Adresses suggérées', style: AppTextStyles.labelLarge)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 12),
                    ..._suggestedAddresses.asMap().entries.map((entry) {
                      final i = entry.key;
                      final addr = entry.value;
                      final isSelected = _selectedAddress == addr;
                      return _buildAddressTile(addr, isSelected, i);
                    }),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Confirmer cette adresse',
                      onPressed: _confirmLocation,
                      prefixIcon: Icons.check_circle_outline_rounded,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Grid lines
          CustomPaint(
            size: const Size(double.infinity, 220),
            painter: _MapGridPainter(),
          ),
          // Pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.primaryShadow,
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 28),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                    begin: 1.0,
                    end: 1.15,
                    duration: 1000.ms,
                    curve: Curves.easeInOut),
                // Pin shadow
                Container(
                  width: 20,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          // Map label
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Carte interactive bientôt',
                      style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(String address, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _selectAddress(address),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(
                Icons.location_on_outlined,
                size: 18,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 250 + index * 60),
            duration: 400.ms,
          ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
