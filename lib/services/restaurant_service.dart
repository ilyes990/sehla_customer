import '../models/meal_model.dart';
import '../models/restaurant_model.dart';
import 'base_api_service.dart';

class RestaurantService extends BaseApiService {
  /// Fetch all restaurants from real API
  Future<List<RestaurantModel>> getRestaurants({String? category}) async {
    try {
      final response = await get('resto/resto_api.php');
      if (response == null) return [];

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else if (response is Map && response.containsKey('restaurants')) {
        // Handle potential wrapper
        data = response['restaurants'] as List;
      } else {
        return [];
      }

      var result = data.map((json) => RestaurantModel.fromJson(json)).toList();

      if (category != null && category != 'Tous') {
        result = result.where((r) => r.cuisineType == category).toList();
      }
      return result;
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  /// Fetch meals by restaurant from real API
  Future<List<MealModel>> getMealsByRestaurant(String restaurantId) async {
    try {
      final response = await get('les_plats/api_plats.php');
      if (response == null) return [];

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else {
        return [];
      }

      return data
          .map((json) => MealModel.fromJson(json))
          .where((m) => m.restaurantId == restaurantId)
          .toList();
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }

  /// Fetch popular meals across all restaurants
  Future<List<MealModel>> getPopularMeals() async {
    try {
      final response = await get('les_plats/api_plats.php');
      if (response == null) return [];

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else {
        return [];
      }

      return data
          .map((json) => MealModel.fromJson(json))
          .where((m) => m.isPopular)
          .toList();
    } catch (e) {
      print('Error fetching popular meals: $e');
      return [];
    }
  }

  /// Fetch a single meal
  Future<MealModel?> getMealById(String mealId) async {
    try {
      final response = await get('les_plats/api_plats.php');
      if (response == null) return null;

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else {
        return null;
      }

      try {
        final json = data
            .firstWhere((m) => (m['idplats'] ?? m['id'])?.toString() == mealId);
        return MealModel.fromJson(json);
      } catch (_) {
        return null;
      }
    } catch (e) {
      print('Error fetching meal by id: $e');
      return null;
    }
  }
}
