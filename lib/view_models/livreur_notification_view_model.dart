import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/base_api_service.dart';
import '../services/livreur_notification_service.dart';

enum LivreurNotificationLoadState { idle, loading, success, error }

/// Result of a takeOrder() call, used by the UI to react appropriately.
enum TakeOrderResult { success, conflict409, notFound404, badRequest400, error }

class LivreurNotificationViewModel extends ChangeNotifier {
  final LivreurNotificationService _service;

  LivreurNotificationViewModel({LivreurNotificationService? service})
      : _service = service ?? LivreurNotificationService();

  // ── State ──────────────────────────────────────────────────────────────────
  LivreurNotificationLoadState _state = LivreurNotificationLoadState.idle;
  List<NotificationModel> _notifications = [];
  String? _errorMessage;
  Timer? _pollingTimer;

  // Per-notification loading state: keys are notification IDs being processed
  final Set<int> _takingOrderIds = {};

  // ── Getters ────────────────────────────────────────────────────────────────
  LivreurNotificationLoadState get state => _state;
  List<NotificationModel> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.length;
  bool get isLoading => _state == LivreurNotificationLoadState.loading;
  bool get hasError => _state == LivreurNotificationLoadState.error;

  /// Returns true when the given notification ID is in the process of being taken
  bool isTakingOrder(int notifId) => _takingOrderIds.contains(notifId);

  // ── Fetch ──────────────────────────────────────────────────────────────────
  Future<void> fetchNotifications(int livreurId) async {
    _state = LivreurNotificationLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _service.fetchNotifications(livreurId);
      _state = LivreurNotificationLoadState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = LivreurNotificationLoadState.error;
    } catch (_) {
      _errorMessage = 'Impossible de charger les notifications';
      _state = LivreurNotificationLoadState.error;
    }
    notifyListeners();
  }

  // ── Take Order ─────────────────────────────────────────────────────────────

  /// Attempts to reserve the notification identified by [notifId] for [livreurId].
  ///
  /// Returns a [TakeOrderResult] so the UI can show the right toast/badge.
  ///
  /// On success  → the notification's status in [_notifications] is updated to "reserved".
  /// On conflict → the notification is updated to a non-libre status so the button disappears.
  Future<TakeOrderResult> takeOrder({
    required int notifId,
    required int livreurId,
  }) async {
    // Prevent double-tap: if already in-flight, bail out immediately
    if (_takingOrderIds.contains(notifId)) return TakeOrderResult.error;

    _takingOrderIds.add(notifId);
    notifyListeners();

    try {
      final reserved = await _service.takeOrder(
        idNotificationLivreur: notifId,
        idLivreur: livreurId,
      );

      // Update the notification in the local list
      _notifications = _notifications.map((n) {
        if (n.id == notifId) {
          // Prefer the server response; fall back to updating status in-place
          return reserved;
        }
        return n;
      }).toList();

      _takingOrderIds.remove(notifId);
      notifyListeners();
      return TakeOrderResult.success;
    } on ApiException catch (e) {
      _takingOrderIds.remove(notifId);

      if (e.statusCode == 409) {
        // Mark as unavailable locally so the button disappears
        _notifications = _notifications.map((n) {
          if (n.id == notifId) return n.copyWithStatus('unavailable');
          return n;
        }).toList();
        notifyListeners();
        return TakeOrderResult.conflict409;
      }

      if (e.statusCode == 404) {
        notifyListeners();
        return TakeOrderResult.notFound404;
      }

      if (e.statusCode == 400) {
        notifyListeners();
        return TakeOrderResult.badRequest400;
      }

      notifyListeners();
      return TakeOrderResult.error;
    } catch (_) {
      _takingOrderIds.remove(notifId);
      notifyListeners();
      return TakeOrderResult.error;
    }
  }

  // ── Polling ────────────────────────────────────────────────────────────────
  /// Starts polling every 30 seconds using [livreurId].
  /// Also triggers an immediate fetch.
  void startPolling(int livreurId) {
    stopPolling();
    fetchNotifications(livreurId);
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchNotifications(livreurId),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ── Lightweight badge refresh (no loading state change) ───────────────────
  Future<void> refreshBadge(int livreurId) async {
    try {
      _notifications = await _service.fetchNotifications(livreurId);
      notifyListeners();
    } catch (_) {
      // Silently ignore badge errors
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
