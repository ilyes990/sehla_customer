import '../services/plats_service.dart';

import '../core/enums_view_state.dart';
import '../locator.dart';
import 'base_view_model.dart';

class RestaurantViewModel extends BaseViewModel {
  final PlatsService _platsService = locator<PlatsService>();

  /// Loads plats for a given restaurant.
  /// Returns `List<MealModel>` on success, or a `String` error message on failure.
  Future<dynamic> loadPlats({required String idResto}) async {
    changeState(ViewState.Busy);
    try {
      final plats = await _platsService.getPlatsByRestaurant(idResto);
      changeState(ViewState.Idle);
      return plats;
    } catch (e) {
      changeState(ViewState.Idle);
      return 'Erreur lors du chargement des plats';
    }
  }
}
