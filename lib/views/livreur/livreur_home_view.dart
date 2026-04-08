import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_constants.dart';
import '../../../core/app_text_styles.dart';
import '../../../models/livreur_model.dart';
import '../../../view_models/auth_view_model.dart';
import '../../../view_models/livreur_notification_view_model.dart';

class LivreurHomeView extends StatefulWidget {
  const LivreurHomeView({super.key});

  @override
  State<LivreurHomeView> createState() => _LivreurHomeViewState();
}

class _LivreurHomeViewState extends State<LivreurHomeView> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Accueil'),
    _NavItem(icon: Icons.assignment_rounded, label: 'Livraisons'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Gains'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final livreurId = int.tryParse(authVm.livreur?.id ?? '') ?? 0;
      if (livreurId > 0) {
        context.read<LivreurNotificationViewModel>().refreshBadge(livreurId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _LivreurDashboardTab(),
            _LivreurDeliveriesTab(),
            _LivreurEarningsTab(),
            _LivreurProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppConstants.bottomNavHeight,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final selected = i == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: AppConstants.animFast,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryLight
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusCircle),
                          ),
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ── Dashboard Tab ─────────────────────────────────────────────────────────────
class _LivreurDashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final livreur = vm.livreur;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingL, 24, AppConstants.paddingL, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(livreur),
                const SizedBox(height: 28),
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildSectionTitle('Livraisons en attente'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildPendingDeliveryCard(i).padding(
                const EdgeInsets.only(bottom: 12),
              ),
              childCount: 3,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildGreeting(LivreurModel? livreur) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Bonjour'
        : hour < 18
            ? 'Bon après-midi'
            : 'Bonsoir';
    final name = livreur?.name.split(' ').first ?? 'Livreur';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, $name 👋',
                style: AppTextStyles.headlineLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(duration: 500.ms).slideX(
                    begin: -0.2,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 4),
              Text(
                'Prêt pour les livraisons d\'aujourd\'hui ?',
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Bell icon with badge
        Consumer2<AuthViewModel, LivreurNotificationViewModel>(
          builder: (ctx, authVm, notifVm, _) {
            final unread = notifVm.unreadCount;
            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                  ctx, AppConstants.routeLivreurNotifications),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut actuel',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'En ligne 🟢',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vous recevez des commandes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.white,
            activeTrackColor: AppColors.white.withOpacity(0.3),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms);
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            label: 'Livrées',
            value: '12',
            color: AppColors.success,
            delay: 300,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.pending_actions_rounded,
            label: 'En attente',
            value: '3',
            color: AppColors.warning,
            delay: 380,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.attach_money_rounded,
            label: 'Gains',
            value: '2 400 DA',
            color: AppColors.primary,
            delay: 460,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.headlineSmall)
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildPendingDeliveryCard(int index) {
    final orders = [
      _DeliveryInfo(
          client: 'Youcef Amrani',
          address: '12 Rue Didouche Mourad, Alger',
          distance: '2.4 km',
          amount: '850 DA'),
      _DeliveryInfo(
          client: 'Nadia Boukhalfa',
          address: '45 Cité Climat de France, Alger',
          distance: '3.1 km',
          amount: '1 200 DA'),
      _DeliveryInfo(
          client: 'Karim Mansouri',
          address: '8 Boulevard Krim Belkacem, Alger',
          distance: '1.8 km',
          amount: '650 DA'),
    ];
    final order = orders[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.client, style: AppTextStyles.headlineSmall),
                    Text(order.address,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusCircle),
                ),
                child: Text(order.distance,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('Accepter · ${order.amount}'),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 500 + index * 80), duration: 400.ms)
        .slideY(
          begin: 0.15,
          end: 0,
          delay: Duration(milliseconds: 500 + index * 80),
          duration: 400.ms,
        );
  }
}

class _DeliveryInfo {
  final String client, address, distance, amount;
  const _DeliveryInfo(
      {required this.client,
      required this.address,
      required this.distance,
      required this.amount});
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        );
  }
}

// ── Deliveries Tab ────────────────────────────────────────────────────────────
class _LivreurDeliveriesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingL, 24, AppConstants.paddingL, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mes livraisons', style: AppTextStyles.headlineLarge)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 4),
                Text('Historique complet de vos livraisons',
                        style: AppTextStyles.bodyMedium)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildDeliveryHistoryCard(i),
              childCount: 5,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildDeliveryHistoryCard(int i) {
    final statuses = [
      'Livrée ✓',
      'Livrée ✓',
      'Refusée',
      'Livrée ✓',
      'Livrée ✓'
    ];
    final amounts = ['850 DA', '1 200 DA', '-', '650 DA', '950 DA'];
    final status = statuses[i];
    final isRefused = status == 'Refusée';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isRefused
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              isRefused ? Icons.cancel_rounded : Icons.check_circle_rounded,
              color: isRefused ? AppColors.error : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Commande #${1000 + i}',
                    style: AppTextStyles.headlineSmall),
                const SizedBox(height: 2),
                Text('Il y a ${(i + 1) * 2}h · Alger Centre',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amounts[i],
                style: AppTextStyles.labelLarge.copyWith(
                  color:
                      isRefused ? AppColors.textSecondary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isRefused ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 + i * 60), duration: 350.ms)
        .slideX(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 100 + i * 60),
          duration: 350.ms,
        );
  }
}

// ── Earnings Tab ──────────────────────────────────────────────────────────────
class _LivreurEarningsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Mes gains', style: AppTextStyles.headlineLarge)
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 4),
          Text('Résumé de vos revenus', style: AppTextStyles.bodyMedium)
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 28),
          // Total card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              boxShadow: AppColors.primaryShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total ce mois',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '12 400 DA',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: AppColors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+18% par rapport au mois dernier',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),
          // Weekly breakdown
          Text('Cette semaine', style: AppTextStyles.headlineSmall)
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms),
          const SizedBox(height: 16),
          ...List.generate(7, (i) {
            final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
            final amounts = [1800, 2100, 1400, 2400, 1900, 2200, 600];
            final max = 2400;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(days[i], style: AppTextStyles.labelMedium),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      child: LinearProgressIndicator(
                        value: amounts[i] / max,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 68,
                    child: Text(
                      '${amounts[i]} DA',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textPrimary),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                    delay: Duration(milliseconds: 400 + i * 50),
                    duration: 350.ms)
                .slideX(
                  begin: 0.1,
                  end: 0,
                  delay: Duration(milliseconds: 400 + i * 50),
                  duration: 350.ms,
                );
          }),
        ],
      ),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────
class _LivreurProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final livreur = vm.livreur;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Profil', style: AppTextStyles.headlineLarge)
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 28),
          // Avatar + name
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.primaryShadow,
                  ),
                  child: Center(
                    child: Text(
                      livreur?.name.isNotEmpty == true
                          ? livreur!.name[0].toUpperCase()
                          : 'L',
                      style: AppTextStyles.displayMedium
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  livreur?.name ?? 'Livreur',
                  style: AppTextStyles.headlineLarge,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 4),
                Text(
                  livreur?.email ?? '',
                  style: AppTextStyles.bodyMedium,
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Info cards
          _buildInfoRow(
              Icons.phone_outlined, 'Téléphone', livreur?.phone ?? '—', 200),
          const SizedBox(height: 12),
          _buildInfoRow(
              Icons.email_outlined, 'Email', livreur?.email ?? '—', 280),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.badge_outlined, 'ID Livreur',
              '#${livreur?.id ?? '—'}', 360),
          const SizedBox(height: 32),
          // Logout button
          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: () async {
                await vm.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppConstants.routeLogin,
                    (_) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Se déconnecter'),
            ),
          ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, int delay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.headlineSmall),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 350.ms)
        .slideX(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 350.ms,
        );
  }
}

// Extension for padding
extension WidgetPadding on Widget {
  Widget padding(EdgeInsets insets) => Padding(padding: insets, child: this);
}
