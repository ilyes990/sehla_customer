import 'package:flutter/foundation.dart';

import '../models/meal_model.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

enum OrderLoadingState { initial, loading, success, error }

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService;

  OrderViewModel({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  // ── State ─────────────────────────────────────────────────────────────────
  OrderLoadingState _state = OrderLoadingState.initial;
  OrderModel? _lastOrder;
  String? _errorMessage;

  // ── Cart ──────────────────────────────────────────────────────────────────
  MealModel? _currentMeal;
  int _quantity = 1;

  // ── Getters ───────────────────────────────────────────────────────────────
  OrderLoadingState get state => _state;
  bool get isLoading => _state == OrderLoadingState.loading;
  OrderModel? get lastOrder => _lastOrder;
  String? get errorMessage => _errorMessage;
  MealModel? get currentMeal => _currentMeal;
  int get quantity => _quantity;

  double get totalPrice => (_currentMeal?.price ?? 0) * _quantity;

  // ── Meal Detail ───────────────────────────────────────────────────────────
  void setCurrentMeal(MealModel meal) {
    _currentMeal = meal;
    _quantity = 1;
    _state = OrderLoadingState.initial;
    notifyListeners();
  }

  void incrementQuantity() {
    if (_quantity < 20) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  // ── Create Order ──────────────────────────────────────────────────────────
  Future<bool> createOrder({
    required String restaurantId,
    required String restaurantName,
    required String deliveryAddress,
    required double deliveryFee,
    String? notes,
  }) async {
    if (_currentMeal == null) return false;

    _state = OrderLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: [
          OrderItemModel(
            mealId: _currentMeal!.id,
            mealName: _currentMeal!.name,
            mealImageUrl: _currentMeal!.imageUrl,
            quantity: _quantity,
            unitPrice: _currentMeal!.price,
          ),
        ],
        deliveryAddress: deliveryAddress,
        deliveryFee: deliveryFee,
        notes: notes,
      );

      _lastOrder = order;
      _state = OrderLoadingState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = OrderLoadingState.error;
      _errorMessage = 'Impossible de créer la commande';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _state = OrderLoadingState.initial;
    _errorMessage = null;
    _quantity = 1;
    notifyListeners();
  }
}
