import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_model.dart';
import 'base_api_service.dart';

class LivreurNotificationService {
  static const String _fetchEndpoint =
      'https://sahladelivery.com/notfications_livreur/api_get_notifications_livreur.php';

  static const String _takeOrderEndpoint =
      'https://sahladelivery.com/notfications_livreur/api_take_order_livreur.php';

  // ── Fetch notifications ──────────────────────────────────────────────────────

  /// Fetches unread notifications for the given [livreurId].
  /// Returns a list of [NotificationModel].
  /// Throws [ApiException] on network or server errors.
  Future<List<NotificationModel>> fetchNotifications(int livreurId) async {
    final uri = Uri.parse(_fetchEndpoint);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'livreur_id': livreurId}),
      );

      final decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      final success = decoded['success'];
      if (success == true || success == 'true' || success == 1) {
        final rawList = decoded['notifications'];
        if (rawList == null) return [];
        if (rawList is! List) return [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }

      final msg = decoded['message'] as String? ??
          decoded['error'] as String? ??
          'Impossible de charger les notifications';
      throw ApiException(
          message: msg, statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }
  }

  // ── Take order ──────────────────────────────────────────────────────────────

  /// Attempts to reserve a notification (order) for this livreur.
  ///
  /// POST /api_take_order_livreur.php
  /// Body: { "id_notification_livreur": <int>, "id_livreur": <int> }
  ///
  /// Returns the reserved [NotificationModel] on success (200).
  ///
  /// Throws [ApiException] with specific status codes:
  ///   • 409 → race condition: order was just taken by another livreur
  ///   • 404 → notification not found
  ///   • 400 → missing / invalid fields
  ///   • other → generic server/network error
  Future<NotificationModel> takeOrder({
    required int idNotificationLivreur,
    required int idLivreur,
  }) async {
    final uri = Uri.parse(_takeOrderEndpoint);
    http.Response response;

    try {
      response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_notification_livreur': idNotificationLivreur,
          'id_livreur': idLivreur,
        }),
      );
    } catch (_) {
      throw const ApiException(
          message: 'Erreur réseau : impossible de joindre le serveur');
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        message: 'Réponse invalide du serveur',
        statusCode: response.statusCode,
      );
    }

    // ── 409 Conflict ──────────────────────────────────────────────────────────
    if (response.statusCode == 409) {
      throw ApiException(
        message: decoded['message'] as String? ??
            'Cette commande vient d\'être prise par un autre livreur',
        statusCode: 409,
      );
    }

    // ── 404 Not Found ─────────────────────────────────────────────────────────
    if (response.statusCode == 404) {
      throw ApiException(
        message: decoded['message'] as String? ?? 'Commande introuvable',
        statusCode: 404,
      );
    }

    // ── 400 Bad Request ───────────────────────────────────────────────────────
    if (response.statusCode == 400) {
      throw ApiException(
        message: decoded['message'] as String? ?? 'Requête invalide',
        statusCode: 400,
      );
    }

    // ── 200 + success: true ───────────────────────────────────────────────────
    final success = decoded['success'];
    if ((success == true || success == 'true' || success == 1) &&
        response.statusCode == 200) {
      final rawNotif = decoded['notification'];
      if (rawNotif is Map<String, dynamic>) {
        return NotificationModel.fromJson(rawNotif);
      }
      throw ApiException(
        message: 'Réponse invalide du serveur',
        statusCode: response.statusCode,
      );
    }

    // ── Fallback ──────────────────────────────────────────────────────────────
    throw ApiException(
      message: decoded['message'] as String? ?? 'Une erreur est survenue',
      statusCode: response.statusCode,
    );
  }
}
