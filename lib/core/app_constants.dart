class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Sehla';
  static const String appTagline = 'Livraison rapide, toujours frais';
  static const String baseUrl = 'https://sahladelivery.com';

  // Routes — Customer
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeLocationPicker = '/location-picker';
  static const String routeHome = '/home';
  static const String routeRestaurantDetail = '/restaurant-detail';
  static const String routeMealDetail = '/meal-detail';
  static const String routeOrderConfirmation = '/order-confirmation';
  static const String routeCart = '/cart';
  static const String routeOrderSuccess = '/order-success';

  // Routes — Notifications
  static const String routeCustomerNotifications =
      '/customer/notifications';
  static const String routeLivreurNotifications =
      '/livreur/notifications';

  // Routes — Plats
  static const String routePlatsList = '/plats';
  static const String routePlatCreate = '/plats/create';
  static const String routePlatEdit = '/plats/edit';

  // Routes — Livreur
  static const String routeLivreurHome = '/livreur/home';

  // Dimensions
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 100.0;

  static const double buttonHeight = 54.0;
  static const double inputHeight = 52.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 72.0;

  // Cards
  static const double cardRestaurantHeight = 200.0;
  static const double cardMealHeight = 170.0;

  // Splash
  static const Duration splashDuration = Duration(seconds: 3);

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 700);
}
