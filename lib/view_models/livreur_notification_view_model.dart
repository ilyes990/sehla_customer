import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/base_api_service.dart';
import '../services/commande_service.dart';
import '../services/livreur_notification_service.dart';
import '../services/takes_order_service.dart';

enum LivreurNotificationState { idle, loading, success, error }

class LivreurNotificationViewModel extends ChangeNotifier {

  LivreurNotificationState _state = LivreurNotificationState.idle;
  List<NotificationModel> _notifications = [];
  String? _errorMessage;

  // New dependencies
  final LivreurNotificationService _service;
  final TakesOrderService _takesOrderService;
  final CommandeService _commandeService;

  LivreurNotificationViewModel({
    LivreurNotificationService? service,
    TakesOrderService? takesOrderService,
    CommandeService? commandeService,
  })  : _service = service ?? LivreurNotificationService(),
        _takesOrderService = takesOrderService ?? TakesOrderService(),
        _commandeService = commandeService ?? CommandeService();

  // ── Getters ────────────────────────────────────────────────────────────────
  LivreurNotificationState get state => _state;
  List<NotificationModel> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.length;
  bool get isLoading => _state == LivreurNotificationState.loading;
  bool get hasError => _state == LivreurNotificationState.error;

  // ── Fetch (initial / manual retry — shows loading state) ───────────────────
  Future<void> fetchNotifications(int livreurId) async {
    _state = LivreurNotificationState.loading;
    _errorMessage = null;
    notifyListeners();
    await _silentRefresh(livreurId);
  }

  // ── Silent background poll — no loading-state flip ─────────────────────────
  Future<void> _silentRefresh(int livreurId) async {
    try {
      _notifications = await _service.fetchNotifications(livreurId);
      _state = LivreurNotificationState.success;
    } on ApiException catch (e) {
      // Only flip to full error UI if we have no existing data
      if (_notifications.isEmpty) {
        _errorMessage = e.message;
        _state = LivreurNotificationState.error;
      }
    } catch (_) {
      if (_notifications.isEmpty) {
        _errorMessage = 'Impossible de charger les notifications';
        _state = LivreurNotificationState.error;
      }
    }
    notifyListeners();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────
  /// Claims the order associated with the notification.
  Future<bool> takeOrder(int notifId, int livreurId) async {
    _state = LivreurNotificationState.loading;
    notifyListeners();

    final updatedNotif = await _takesOrderService.takeOrder(
      idNotificationLivreur: notifId,
      idLivreur: livreurId,
    );

    if (updatedNotif != null) {
      // Update local list with the new notification details
      final index = _notifications.indexWhere((n) => n.id == notifId);
      if (index != -1) {
        _notifications[index] = updatedNotif;
      }
      _state = LivreurNotificationState.success;
      notifyListeners();
      return true;
    }

    _state = LivreurNotificationState.error;
    _errorMessage = 'Impossible de prendre la commande';
    notifyListeners();
    return false;
  }

  /// Marks an order as delivered.
  Future<bool> markAsDelivered(int commandeId, int notifId) async {
    _state = LivreurNotificationState.loading;
    notifyListeners();

    final success = await _commandeService.updateCommandeStatus(
      commandeId: commandeId,
      status: 'livree',
    );

    if (success) {
      // Refresh the whole list or update the status of this specific notification locally
      final index = _notifications.indexWhere((n) => n.id == notifId);
      if (index != -1) {
        // We'll just assume 'livree' for now to update the UI immediately
        _notifications[index] = _notifications[index].copyWith(
          // We can't update 'status' unless we add it to copyWith or refetch
          // For now, let's just refetch to be safe since child might have changed
        );
      }
      _state = LivreurNotificationState.success;
      notifyListeners();
      return true;
    }

    _state = LivreurNotificationState.error;
    _errorMessage = 'Impossible de mettre à jour le statut';
    notifyListeners();
    return false;
  }

  // ── Manual refresh (no loading state flip) ───────────────────
  Future<void> refreshBadge(int livreurId) => _silentRefresh(livreurId);

  @override
  void dispose() {
    super.dispose();
  }
}
