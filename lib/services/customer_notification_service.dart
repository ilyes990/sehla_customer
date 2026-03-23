import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_model.dart';
import 'base_api_service.dart';

class CustomerNotificationService {
  static const String _endpoint =
      'https://sahladelivery.com/custumer/api_get_notifications_customer.php';

  /// Fetches unread notifications for the given [customerId].
  /// Returns a list of [NotificationModel].
  /// Throws [ApiException] on network or server errors.
  Future<List<NotificationModel>> fetchNotifications(int customerId) async {
    final uri = Uri.parse(_endpoint);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'customer_id': customerId}),
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

      // success == false: treat as no-data / error
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
}
