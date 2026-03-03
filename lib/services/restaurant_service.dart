import '../models/meal_model.dart';
import '../models/restaurant_model.dart';
import 'base_api_service.dart';

class RestaurantService extends BaseApiService {
  /// Mocked: fetch all restaurants
  Future<List<RestaurantModel>> getRestaurants({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: Replace with real API call:
    // final data = await get('api/restaurants');

    var result = List<RestaurantModel>.from(dummyRestaurants);
    if (category != null && category != 'Tous') {
      result = result.where((r) => r.cuisineType == category).toList();
    }
    return result;
  }

  /// Mocked: fetch meals by restaurant
  Future<List<MealModel>> getMealsByRestaurant(String restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: Replace with real API call:
    // final data = await get('api/restaurants/$restaurantId/meals');

    return dummyMeals.where((m) => m.restaurantId == restaurantId).toList();
  }

  /// Mocked: fetch popular meals across all restaurants
  Future<List<MealModel>> getPopularMeals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return dummyMeals.where((m) => m.isPopular).toList();
  }

  /// Mocked: fetch a single meal
  Future<MealModel?> getMealById(String mealId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return dummyMeals.firstWhere((m) => m.id == mealId);
    } catch (_) {
      return null;
    }
  }
}
