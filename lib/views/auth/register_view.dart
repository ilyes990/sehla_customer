import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../view_models/auth_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController(); // nom
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telfController = TextEditingController(); // telf
  final _locationController = TextEditingController(); // location

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telfController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final success = await vm.register(
      nom: _nomController.text.trim(),
      telf: _telfController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      location: _locationController.text.trim(),
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildRegisterButton(),
                    const SizedBox(height: 16),
                    _buildErrorMessage(),
                    const SizedBox(height: 24),
                    _buildLoginLink(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: AppColors.cardShadow,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 24),
        Text('Créer un compte 🚀', style: AppTextStyles.displayMedium)
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0, duration: 500.ms),
        const SizedBox(height: 6),
        Text(
          'Rejoignez Sehla et savourez la livraison rapide',
          style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // nom
          CustomTextField(
            label: 'Nom complet',
            hint: 'Ahmed Benali',
            controller: _nomController,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // email
          CustomTextField(
            label: 'Adresse email',
            hint: 'exemple@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email requis';
              if (!v.contains('@')) return 'Email invalide';
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 280.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 280.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // telf
          CustomTextField(
            label: 'Numéro de téléphone',
            hint: '0555 123 456',
            controller: _telfController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Téléphone requis' : null,
          )
              .animate()
              .fadeIn(delay: 360.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 360.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // location
          CustomTextField(
            label: 'Ville / Localisation',
            hint: 'Ex : Oran, Alger, Constantine…',
            controller: _locationController,
            prefixIcon: Icons.location_on_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Localisation requise' : null,
          )
              .animate()
              .fadeIn(delay: 440.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 440.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // password
          CustomTextField(
            label: 'Mot de passe',
            hint: '••••••••',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mot de passe requis';
              if (v.length < 6) return 'Minimum 6 caractères';
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 520.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 520.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) => CustomButton(
        label: 'Créer mon compte',
        isLoading: vm.isLoading,
        onPressed: vm.isLoading ? null : _onRegister,
        prefixIcon: Icons.rocket_launch_rounded,
      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        if (vm.errorMessage == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(vm.errorMessage!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error)),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).shake(hz: 2);
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Déjà un compte ? ', style: AppTextStyles.bodyMedium),
        GestureDetector(
          onTap: () =>
              Navigator.pushReplacementNamed(context, AppConstants.routeLogin),
          child: Text(
            'Se connecter',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
