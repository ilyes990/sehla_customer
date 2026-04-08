import 'package:sehla_customer/view_models/base_view_model.dart';
import '../core/enums_view_state.dart';
import '../locator.dart';
import '../models/restaurant_model.dart';
import '../services/restaurant_service.dart';

class HomeViewModel extends BaseViewModel {
  final RestaurantService _restaurantService = locator<RestaurantService>();

  List<RestaurantModel> _restaurants = [];
  String? _errorMessage;

  List<RestaurantModel> get restaurants => _restaurants;
  String? get errorMessage => _errorMessage;

  /// Fetch all restaurants from the API
  Future<void> loadHomeData() async {
    changeState(ViewState.Busy);
    _errorMessage = null;

    try {
      _restaurants = await _restaurantService.getAllRestaurants();
    } catch (e) {
      _errorMessage = 'Impossible de charger les restaurants';
    }

    changeState(ViewState.Idle);
  }
}
