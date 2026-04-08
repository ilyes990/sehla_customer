import '../models/notification_model.dart';
import 'base_api_service.dart';

class TakesOrderService extends BaseApiService {
  static const String _takeOrderEndpoint = 'notfications_livreur/api_take_order_livreur.php';

  /// Takes an order.
  /// Returns the updated [NotificationModel] if successful.
  Future<NotificationModel?> takeOrder({
    required int idNotificationLivreur,
    required int idLivreur,
  }) async {
    final body = {
      'id_notification_livreur': idNotificationLivreur,
      'id_livreur': idLivreur,
    };

    try {
      final response = await post(_takeOrderEndpoint, body: body);

      if (response is Map<String, dynamic>) {
        final success = response['success'];
        if (success == true || success == 'true' || success == 1) {
          if (response['notification'] != null) {
            final notif = NotificationModel.fromJson(response['notification']);
            // If message is in top level, use copyWith
            return notif.copyWith(message: response['message'] as String?);
          }
        }
      }
      return null;
    } catch (e) {
      print('[TakesOrderService] takeOrder error: $e');
      return null;
    }
  }
}
