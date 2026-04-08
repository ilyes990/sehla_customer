import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/base_api_service.dart';
import '../services/customer_notification_service.dart';

enum NotificationLoadState { idle, loading, success, error }

class CustomerNotificationViewModel extends ChangeNotifier {
  final CustomerNotificationService _service;

  CustomerNotificationViewModel({CustomerNotificationService? service})
      : _service = service ?? CustomerNotificationService();

  // ── State ──────────────────────────────────────────────────────────────────
  NotificationLoadState _state = NotificationLoadState.idle;
  List<NotificationModel> _notifications = [];
  String? _errorMessage;
  Timer? _pollingTimer;

  // ── Getters ────────────────────────────────────────────────────────────────
  NotificationLoadState get state => _state;
  List<NotificationModel> get notifications => _notifications;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.length;
  bool get isLoading => _state == NotificationLoadState.loading;
  bool get hasError => _state == NotificationLoadState.error;

  // ── Fetch (initial / manual retry — shows loading state) ───────────────────
  Future<void> fetchNotifications(int customerId) async {
    _state = NotificationLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    await _silentRefresh(customerId);
  }

  // ── Silent background poll — no loading-state flip ─────────────────────────
  Future<void> _silentRefresh(int customerId) async {
    try {
      _notifications = await _service.fetchNotifications(customerId);
      _state = NotificationLoadState.success;
    } on ApiException catch (e) {
      if (_notifications.isEmpty) {
        _errorMessage = e.message;
        _state = NotificationLoadState.error;
      }
    } catch (_) {
      if (_notifications.isEmpty) {
        _errorMessage = 'Impossible de charger les notifications';
        _state = NotificationLoadState.error;
      }
    }
    notifyListeners();
  }

  // ── Polling ────────────────────────────────────────────────────────────────
  /// Starts polling every 5 seconds using [customerId].
  /// First call shows loading indicator; subsequent polls are silent.
  void startPolling(int customerId) {
    stopPolling();
    fetchNotifications(customerId); // first call shows loading indicator
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _silentRefresh(customerId), // subsequent polls are silent
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ── Lightweight badge refresh (no loading state change) ───────────────────
  Future<void> refreshBadge(int customerId) => _silentRefresh(customerId);

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
