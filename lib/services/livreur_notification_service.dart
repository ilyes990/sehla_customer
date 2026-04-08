import 'dart:convert';

import '../models/notification_model.dart';
import 'base_api_service.dart';
import 'package:http/http.dart' as http;

/* 
Requested param 

livreur_id type iinteger required yes 

Example successful response : 
{
    "success": true,
    "notifications": [
        {
            "id": 12,
            "message": "New order assigned to you",
            "created_at": "2026-02-26 15:10:00"
        }
    ]
}

Example error response : 
{
    "success": false,
    "message": "livreur_id is required"
}

 */
class LivreurNotificationService {
  static const String baseUrl =
      'https://sahladelivery.com/notfications_livreur/api_get_notifications_livreur.php';

  /// Fetches notifications for the given [livreurId].
  /// API returns: { success: true, notifications: [ { id, message, created_at } ] }
  Future<dynamic> fetchNotifications(int livreurId) async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['notifications']
            .map((x) => NotificationModel.fromJson(x))
            .toList();
      }
    }

    throw const ApiException(message: 'Format de réponse invalide');
  }
}


/* 

class NotificationModel {
  final int id;
  final String message;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _toInt(json['id']),
      message: json['message'] as String? ?? '',
      createdAt: _toDate(json['created_at']),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static int _toInt(dynamic val) =>
      val is int ? val : int.tryParse(val.toString()) ?? 0;

  static DateTime _toDate(dynamic val) {
    if (val == null) return DateTime.now();
    try {
      return DateTime.parse(val.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  /// French-style formatted date: "26 Fév 2026 à 14:30"
  String get formattedDate {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    final d = createdAt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = months[d.month - 1];
    final hr = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day $month ${d.year} à $hr:$min';
  }
}


*/

