import 'package:flutter/foundation.dart';

import '../models/meal_model.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';
import '../services/base_api_service.dart';
import '../services/commande_service.dart';

enum CartSubmitState { idle, loading, success, error }

/// A single item in the cart.
class CartItem {
  final MealModel meal;
  final RestaurantModel restaurant;
  int quantity;
  String note; // optional per-dish note

  CartItem({
    required this.meal,
    required this.restaurant,
    this.quantity = 1,
    this.note = '',
  });

  double get totalPrice => meal.prix * quantity;

  CartItem copyWith({int? quantity, String? note}) => CartItem(
        meal: meal,
        restaurant: restaurant,
        quantity: quantity ?? this.quantity,
        note: note ?? this.note,
      );
}

class CartViewModel extends ChangeNotifier {
  final CommandeService _commandeService;

  CartViewModel({CommandeService? commandeService})
      : _commandeService = commandeService ?? CommandeService();

  // ── Cart items ─────────────────────────────────────────────────────────────
  final List<CartItem> _items = [];

  // ── Submit state ───────────────────────────────────────────────────────────
  CartSubmitState _submitState = CartSubmitState.idle;
  String? _errorMessage;
  int? _lastOrderId;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<CartItem> get items => List.unmodifiable(_items);
  CartSubmitState get submitState => _submitState;
  bool get isSubmitting => _submitState == CartSubmitState.loading;
  String? get errorMessage => _errorMessage;
  int? get lastOrderId => _lastOrderId;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// All items in the cart must belong to the same restaurant.
  RestaurantModel? get currentRestaurant =>
      _items.isEmpty ? null : _items.first.restaurant;

  // ── Cart mutations ─────────────────────────────────────────────────────────

  /// Adds a meal to the cart or increments its quantity if already present.
  /// If items from a different restaurant exist, clears the cart first.
  void addItem(MealModel meal, RestaurantModel restaurant) {
    // If adding from a different restaurant, clear the cart first
    if (_items.isNotEmpty && _items.first.restaurant.id != restaurant.id) {
      _items.clear();
    }

    final existingIndex = _items.indexWhere((i) => i.meal.id == meal.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(meal: meal, restaurant: restaurant));
    }
    notifyListeners();
  }

  void incrementQuantity(String mealId) {
    final i = _items.indexWhere((item) => item.meal.id == mealId);
    if (i >= 0 && _items[i].quantity < 20) {
      _items[i].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String mealId) {
    final i = _items.indexWhere((item) => item.meal.id == mealId);
    if (i < 0) return;
    if (_items[i].quantity <= 1) {
      _items.removeAt(i);
    } else {
      _items[i].quantity--;
    }
    notifyListeners();
  }

  void removeItem(String mealId) {
    _items.removeWhere((item) => item.meal.id == mealId);
    notifyListeners();
  }

  void updateNote(String mealId, String note) {
    final i = _items.indexWhere((item) => item.meal.id == mealId);
    if (i >= 0) {
      _items[i] = _items[i].copyWith(note: note);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _submitState = CartSubmitState.idle;
    _errorMessage = null;
    _lastOrderId = null;
    notifyListeners();
  }

  // ── Create order ───────────────────────────────────────────────────────────

  /// Submits the cart as a new order.
  ///
  /// [user] — from the auth session (never ask the user to retype these)
  /// [restaurant] — from the cart's currentRestaurant
  ///
  /// Returns true on 201 success, false on any error.
  /// On error, [errorMessage] is set so the UI can show a toast.
  Future<bool> submitOrder(UserModel user) async {
    if (_items.isEmpty) return false;
    final restaurant = currentRestaurant;
    if (restaurant == null) return false;

    _submitState = CartSubmitState.loading;
    _errorMessage = null;
    notifyListeners();

    final plats = _items
        .map((item) => CommandePlatItem(
              id: int.tryParse(item.meal.id) ?? 0,
              nom: item.meal.nom,
              quantite: item.quantity,
              prix: item.meal.prix,
              note: item.note,
            ))
        .toList();

    try {
      final result = await _commandeService.createCommande(
        customerId: int.tryParse(user.id) ?? 0,
        customerNom: user.name,
        customerTel: user.phone,
        customerLocation: user.location ?? '',
        restoId: int.tryParse(restaurant.id) ?? 0,
        restoNom: restaurant.name,
        restoTel: restaurant.tel ?? '',
        restoAdresse: restaurant.email ?? '',
        prixCommandeTotale: totalPrice,
        lesPlats: plats,
      );

      _lastOrderId = result.idCommande;
      _submitState = CartSubmitState.success;
      notifyListeners();
      clearCart(); // clear on success
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _submitState = CartSubmitState.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Une erreur inattendue est survenue';
      _submitState = CartSubmitState.error;
      notifyListeners();
      return false;
    }
  }

  void resetSubmitState() {
    _submitState = CartSubmitState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
