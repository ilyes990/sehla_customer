import 'package:get_it/get_it.dart';
import 'services/plats_service.dart';
import 'services/restaurant_service.dart';
import 'view_models/home_view_model.dart';
import 'view_models/restaurant_view_model.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<RestaurantService>(() => RestaurantService());
  locator.registerLazySingleton<PlatsService>(() => PlatsService());

  locator.registerLazySingleton<HomeViewModel>(() => HomeViewModel());
  locator
      .registerLazySingleton<RestaurantViewModel>(() => RestaurantViewModel());
}


/*
ilyes.sissaoui@gmail.com

Ilyessissaoui99
*/