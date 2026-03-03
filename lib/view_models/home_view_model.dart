import 'package:flutter/foundation.dart';
import '../models/restaurant_model.dart';
import '../models/meal_model.dart';
import '../services/restaurant_service.dart';

enum HomeLoadingState { initial, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final RestaurantService _restaurantService;

  HomeViewModel({RestaurantService? restaurantService})
      : _restaurantService = restaurantService ?? RestaurantService();

  // ── State ─────────────────────────────────────────────────────────────────
  HomeLoadingState _loadingState = HomeLoadingState.initial;
  List<RestaurantModel> _restaurants = [];
  List<MealModel> _popularMeals = [];
  List<RestaurantModel> _featuredRestaurants = [];
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'Tous';

  // ── Category List ─────────────────────────────────────────────────────────
  final List<String> categories = [
    'Tous',
    'Algérienne',
    'Italienne',
    'Fast Food',
    'Japonaise',
    'Mexicaine',
    'Healthy',
  ];

  // ── Getters ───────────────────────────────────────────────────────────────
  HomeLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == HomeLoadingState.loading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<MealModel> get popularMeals => _popularMeals;
  List<RestaurantModel> get featuredRestaurants => _featuredRestaurants;

  List<RestaurantModel> get filteredRestaurants {
    var result = _restaurants;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.cuisineType.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  // ── Load Data ─────────────────────────────────────────────────────────────
  Future<void> loadHomeData() async {
    _loadingState = HomeLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _restaurantService.getRestaurants(
            category: _selectedCategory == 'Tous' ? null : _selectedCategory),
        _restaurantService.getPopularMeals(),
      ]);

      _restaurants = results[0] as List<RestaurantModel>;
      _popularMeals = results[1] as List<MealModel>;
      _featuredRestaurants = _restaurants.where((r) => r.isFeatured).toList();
      _loadingState = HomeLoadingState.loaded;
    } catch (e) {
      _loadingState = HomeLoadingState.error;
      _errorMessage = 'Impossible de charger les données';
    }

    notifyListeners();
  }

  // ── Category Filter ───────────────────────────────────────────────────────
  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    await loadHomeData();
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
