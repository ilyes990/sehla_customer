import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_text_styles.dart';
import '../../../models/meal_model.dart';
import '../../../view_models/plats_view_model.dart';

/// Admin / restaurant-management screen for creating or editing a plat.
///
/// - Pass [plat] to enter edit mode; leave null for create mode.
/// - Pass [idResto] to pre-fill the restaurant context (required for create).
class PlatFormView extends StatefulWidget {
  final MealModel? plat;
  final int? idResto;

  const PlatFormView({super.key, this.plat, this.idResto});

  bool get isEditing => plat != null;

  @override
  State<PlatFormView> createState() => _PlatFormViewState();
}

class _PlatFormViewState extends State<PlatFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prixCtrl;
  late final PlatsViewModel _vm;

  File? _pickedImage;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.plat?.name ?? '');
    _prixCtrl = TextEditingController(
        text: widget.plat != null
            ? widget.plat!.price.toInt().toString()
            : '');
    _vm = PlatsViewModel();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prixCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  int get _resolvedIdResto {
    if (widget.idResto != null) return widget.idResto!;
    if (widget.plat != null) {
      return int.tryParse(widget.plat!.restaurantId) ?? 0;
    }
    return 0;
  }

  // ── Image Picker (no plugin — uses file path input for demo) ─────────────
  // Note: in production you would use image_picker. Here we show the UI
  // with a tap zone and assume the user taps to select. To avoid adding a
  // new pub dependency we show a placeholder with a camera icon.
  Future<void> _pickImage() async {
    // Placeholder: in a real app replace with image_picker call:
    //   final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    //   if (result != null) setState(() { _pickedImage = File(result.path); _imageChanged = true; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Intégrer image_picker pour activer la sélection d\'image.'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Submit
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nom = _nomCtrl.text.trim();
    final prix = double.tryParse(_prixCtrl.text.trim()) ?? 0;
    final idResto = _resolvedIdResto;

    if (idResto == 0) {
      _showSnack('Restaurant non défini', isError: true);
      return;
    }

    bool success;
    if (widget.isEditing) {
      final id = int.tryParse(widget.plat!.id) ?? 0;
      success = await _vm.updatePlat(
        id: id,
        nom: nom,
        prix: prix,
        idResto: idResto,
        imgFile: _imageChanged ? _pickedImage : null,
      );
    } else {
      success = await _vm.createPlat(
        nom: nom,
        prix: prix,
        idResto: idResto,
        imgFile: _pickedImage,
      );
    }

    if (!mounted) return;
    if (success) {
      _showSnack(_vm.mutationSuccess ?? 'Enregistré',
          isError: false);
      Navigator.pop(context, true); // true = list should refresh
    } else {
      _showSnack(_vm.mutationError ?? 'Erreur', isError: true);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
        title: Text('Supprimer ce plat ?',
            style: AppTextStyles.headlineSmall),
        content: Text(
          'Cette action désactivera le plat (il ne sera plus visible par les clients).',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final id = int.tryParse(widget.plat!.id) ?? 0;
    final success = await _vm.deletePlat(id,
        idResto: int.tryParse(widget.plat!.restaurantId));

    if (!mounted) return;
    if (success) {
      _showSnack('Plat supprimé', isError: false);
      Navigator.pop(context, true);
    } else {
      _showSnack(_vm.mutationError ?? 'Erreur de suppression',
          isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<PlatsViewModel>(
        builder: (context, vm, _) {
          final submitting = vm.isSubmitting;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ── Image Picker Zone ─────────────────────────────────
                    _buildImagePicker(submitting)
                        .animate()
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 24),

                    // ── Nom du plat ───────────────────────────────────────
                    _buildLabel('Nom du plat'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nomCtrl,
                      enabled: !submitting,
                      style: AppTextStyles.input,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                          hint: 'Ex: Couscous Royal',
                          icon: Icons.restaurant_menu_rounded),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Le nom est requis'
                              : null,
                    ).animate().fadeIn(delay: 60.ms, duration: 350.ms),
                    const SizedBox(height: 20),

                    // ── Prix ──────────────────────────────────────────────
                    _buildLabel('Prix'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _prixCtrl,
                      enabled: !submitting,
                      style: AppTextStyles.input,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: false),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: _inputDecoration(
                        hint: 'Ex: 1200',
                        icon: Icons.attach_money_rounded,
                        suffix: Text('DZD',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.primary)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Le prix est requis';
                        }
                        final n = double.tryParse(v.trim());
                        if (n == null || n <= 0) {
                          return 'Prix invalide';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
                    const SizedBox(height: 32),

                    // ── Submit button ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: submitting
                              ? null
                              : AppColors.primaryGradient,
                          color: submitting ? AppColors.border : null,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusL),
                          boxShadow: submitting
                              ? []
                              : AppColors.primaryShadow,
                        ),
                        child: MaterialButton(
                          onPressed: submitting ? null : _submit,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusL)),
                          child: submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white),
                                )
                              : Text(
                                  'Enregistrer',
                                  style: AppTextStyles.button
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 180.ms, duration: 350.ms),

                    // ── Delete button (edit mode only) ────────────────────
                    if (widget.isEditing) ...{
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton.icon(
                          onPressed: submitting ? null : _confirmDelete,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error, size: 18),
                          label: Text(
                            'Supprimer ce plat',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ).animate().fadeIn(delay: 240.ms, duration: 350.ms),
                    },

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
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
      title: Text(
        widget.isEditing ? 'Modifier le Plat' : 'Nouveau Plat',
        style: AppTextStyles.headlineMedium,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildImagePicker(bool disabled) {
    final hasCurrentImage =
        widget.plat != null && widget.plat!.imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: disabled ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
              color: AppColors.primaryLight, width: 1.5),
        ),
        child: _pickedImage != null
            ? ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusL - 1),
                child: Image.file(_pickedImage!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasCurrentImage
                        ? 'Appuyez pour changer l\'image'
                        : 'Appuyez pour ajouter une image',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  if (hasCurrentImage)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '(Image actuelle conservée si non remplacée)',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: AppTextStyles.labelLarge);
  }

  InputDecoration _inputDecoration(
      {required String hint,
      required IconData icon,
      Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.inputHint,
      prefixIcon:
          Icon(icon, color: AppColors.textHint, size: 20),
      suffixIcon:
          suffix != null ? Padding(padding: const EdgeInsets.only(right: 14), child: suffix) : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: AppColors.surfaceVariant,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide:
            const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide:
            const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide:
            const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
