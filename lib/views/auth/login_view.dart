import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_text_styles.dart';
import '../../core/design_system.dart';
import '../../view_models/auth_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserType _selectedRole = UserType.customer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRole(UserType role) {
    if (_selectedRole == role) return;
    setState(() => _selectedRole = role);
    context.read<AuthViewModel>().clearError();
    _formKey.currentState?.reset();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();

    if (_selectedRole == UserType.livreur) {
      final success = await vm.loginLivreur(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.routeLivreurHome);
      }
    } else {
      final success = await vm.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushReplacementNamed(
            context, AppConstants.routeLocationPicker);
      }
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
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildRoleSelector(),
                    const SizedBox(height: 32),
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 16),
                    _buildErrorMessage(),
                    const Spacer(),
                    _buildRegisterLink(),
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
    final isLivreur = _selectedRole == UserType.livreur;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(size: 56, showText: false, dark: true),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            isLivreur ? 'Content de vous revoir ! 🛵' : 'Bienvenue ! 👋',
            key: ValueKey(isLivreur),
            style: AppTextStyles.displayMedium,
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            isLivreur
                ? 'Connectez-vous à votre espace livreur'
                : 'Connectez-vous pour commander\nvos plats préférés',
            key: ValueKey('sub_$isLivreur'),
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          _buildRoleTab(
            label: 'Client',
            icon: Icons.person_outline_rounded,
            role: UserType.customer,
          ),
          _buildRoleTab(
            label: 'Livreur',
            icon: Icons.delivery_dining_rounded,
            role: UserType.livreur,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
          begin: 0.15,
          end: 0,
          delay: 200.ms,
          duration: 400.ms,
        );
  }

  Widget _buildRoleTab({
    required String label,
    required IconData icon,
    required UserType role,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            boxShadow: isSelected ? AppColors.cardShadow : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(
              begin: 0.2,
              end: 0,
              delay: 300.ms,
              duration: 400.ms,
              curve: Curves.easeOut),
          const SizedBox(height: 20),
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
          ).animate().fadeIn(delay: 380.ms, duration: 400.ms).slideY(
              begin: 0.2,
              end: 0,
              delay: 380.ms,
              duration: 400.ms,
              curve: Curves.easeOut),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Mot de passe oublié ?',
                style:
                    AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    final isLivreur = _selectedRole == UserType.livreur;
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        return CustomButton(
          label: isLivreur ? 'Connexion livreur' : 'Se connecter',
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : _onLogin,
          prefixIcon: isLivreur
              ? Icons.delivery_dining_rounded
              : Icons.login_rounded,
        ).animate().fadeIn(delay: 460.ms, duration: 400.ms).slideY(
            begin: 0.2,
            end: 0,
            delay: 460.ms,
            duration: 400.ms,
            curve: Curves.easeOut);
      },
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
                child: Text(
                  vm.errorMessage!,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).shake(hz: 2);
      },
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: AppTextStyles.bodyMedium,
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(
              context, AppConstants.routeRegister),
          child: Text(
            'S\'inscrire',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
