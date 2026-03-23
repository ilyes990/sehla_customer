import '../models/meal_model.dart';
import '../models/restaurant_model.dart';
import 'base_api_service.dart';

class RestaurantService extends BaseApiService {
  /// Fetch all restaurants from real API
  Future<List<RestaurantModel>> getRestaurants({String? category}) async {
    print('[getRestaurants] Fetching restaurants...');
    try {
      final response = await get('resto/resto_api.php');
      print('[getRestaurants] Response type: ${response.runtimeType}');

      if (response == null) {
        print('[getRestaurants] Response is null → returning []');
        return [];
      }

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else if (response is Map && response.containsKey('restaurants')) {
        // Handle potential wrapper
        data = response['restaurants'] as List;
      } else {
        print('[getRestaurants] Unexpected format → returning []');
        return [];
      }

      var result = data.map((json) {
        final r = RestaurantModel.fromJson(json);
        print('[getRestaurants] Restaurant: id="${r.id}", name="${r.name}"');
        return r;
      }).toList();

      if (category != null && category != 'Tous') {
        result = result.where((r) => r.cuisineType == category).toList();
      }
      return result;
    } catch (e, stack) {
      print('[getRestaurants] ERROR: $e');
      print(stack);
      return [];
    }
  }

  /// Fetch meals by restaurant from real API
  Future<List<MealModel>> getMealsByRestaurant(String restaurantId) async {
    print('[getMealsByRestaurant] Called with restaurantId="$restaurantId"');
    try {
      final response = await get('les_plats/api_plats.php');
      print(
          '[getMealsByRestaurant] Raw response type: ${response.runtimeType}');

      if (response == null) {
        print('[getMealsByRestaurant] Response is null → returning []');
        return [];
      }

      List<dynamic> data;
      if (response is List) {
        data = response;
      } else {
        print(
            '[getMealsByRestaurant] Unexpected response format → returning []');
        return [];
      }

      print('[getMealsByRestaurant] Total plats from API: ${data.length}');

      // Log unique id_resto values to help diagnose ID mismatches
      final ids = data
          .map((j) => (j['id_resto'] ?? j['restaurant_id'])?.toString().trim())
          .toSet();
      print('[getMealsByRestaurant] id_resto values in API: $ids');

      final normalizedRestaurantId = restaurantId.trim();

      final filtered = data
          .map((json) => MealModel.fromJson(json))
          .where((m) => m.restaurantId.trim() == normalizedRestaurantId)
          .toList();

      print(
          '[getMealsByRestaurant] Matched ${filtered.length} plats for restaurantId="$normalizedRestaurantId"');
      return filtered;
    } catch (e, stack) {
      print('[getMealsByRestaurant] ERROR: $e');
      print(stack);
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
