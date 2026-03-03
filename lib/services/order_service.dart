import '../models/order_model.dart';
import 'base_api_service.dart';

class OrderService extends BaseApiService {
  /// Mocked: create a new order
  Future<OrderModel> createOrder({
    required String restaurantId,
    required String restaurantName,
    required List<OrderItemModel> items,
    required String deliveryAddress,
    required double deliveryFee,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Replace with real API call:
    // final data = await post('api/orders', body: {...});

    return OrderModel(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
      deliveryAddress: deliveryAddress,
      deliveryFee: deliveryFee,
      notes: notes,
    );
  }

  /// Mocked: get order history
  Future<List<OrderModel>> getOrderHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [];
  }
}
