import '../models/restaurant_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantService {
  static const String _baseUrl = 'https://sahladelivery.com/resto/resto_api.php';

  /// GET /resto_api.php  →  List<RestaurantModel>
  Future<List<RestaurantModel>> getAllRestaurants() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => RestaurantModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }

  /// GET /resto_api.php?id=X  →  RestaurantModel
  Future<RestaurantModel> getRestaurantById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl?id=$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return RestaurantModel.fromJson(data);
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }
}
