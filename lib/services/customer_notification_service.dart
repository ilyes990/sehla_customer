import '../models/notification_model.dart';
import 'base_api_service.dart';

class CustomerNotificationService extends BaseApiService {
  static const String _endpoint = 'custumer/api_get_notifications_customer.php';

  /// Fetches unread notifications for the given [customerId].
  /// Returns a list of [NotificationModel] based on the simplified API spec:
  /// { id, message, created_at }
  Future<List<NotificationModel>> fetchNotifications(int customerId) async {
    final response = await post(
      _endpoint,
      body: {'customer_id': customerId},
    );

    // response is already decoded by BaseApiService
    if (response is Map<String, dynamic>) {
      final success = response['success'];
      if (success == true || success == 'true' || success == 1) {
        final List? rawList = response['notifications'];
        if (rawList == null) return [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }
      
      final String msg = response['message'] ?? 'Impossible de charger les notifications';
      throw ApiException(message: msg);
    }
    
    throw const ApiException(message: 'Format de réponse invalide');
  }
}
