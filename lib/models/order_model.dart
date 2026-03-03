enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled
}

class OrderItemModel {
  final String mealId;
  final String mealName;
  final String mealImageUrl;
  final int quantity;
  final double unitPrice;

  const OrderItemModel({
    required this.mealId,
    required this.mealName,
    required this.mealImageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;
}

class OrderModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final DateTime createdAt;
  final String deliveryAddress;
  final double deliveryFee;
  final String? notes;

  const OrderModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    required this.deliveryFee,
    this.notes,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  double get total => subtotal + deliveryFee;
}
