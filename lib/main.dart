import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_constants.dart';
import 'core/app_theme.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/customer_notification_view_model.dart';
import 'view_models/home_view_model.dart';
import 'view_models/livreur_notification_view_model.dart';
import 'view_models/cart_view_model.dart';
import 'view_models/order_view_model.dart';
import 'view_models/plats_view_model.dart';
import 'views/admin/plat_form_view.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/home/cart_view.dart';
import 'views/home/customer_notifications_screen.dart';
import 'views/home/home_view.dart';
import 'views/home/plats_list_screen.dart';
import 'views/livreur/livreur_home_view.dart';
import 'views/livreur/livreur_notifications_screen.dart';
import 'views/location/location_picker_view.dart';
import 'views/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SehlaApp());
}

class SehlaApp extends StatelessWidget {
  const SehlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => CustomerNotificationViewModel()),
        ChangeNotifierProvider(create: (_) => LivreurNotificationViewModel()),
        ChangeNotifierProvider(create: (_) => PlatsViewModel()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppConstants.routeSplash,
        routes: {
          AppConstants.routeSplash: (_) => const SplashScreen(),
          AppConstants.routeLogin: (_) => const LoginView(),
          AppConstants.routeRegister: (_) => const RegisterView(),
          AppConstants.routeLocationPicker: (_) => const LocationPickerView(),
          AppConstants.routeHome: (_) => const HomeView(),
          AppConstants.routeCart: (_) => const CartView(),
          // Livreur
          AppConstants.routeLivreurHome: (_) => const LivreurHomeView(),
          // Notifications
          AppConstants.routeCustomerNotifications: (_) =>
              const CustomerNotificationsScreen(),
          AppConstants.routeLivreurNotifications: (_) =>
              const LivreurNotificationsScreen(),
          // Plats (customer-side list)
          AppConstants.routePlatsList: (_) => const PlatsListScreen(),
          // Plat create form
          AppConstants.routePlatCreate: (_) => const PlatFormView(),
        },
        // Plat edit needs a MealModel argument — use onGenerateRoute
        onGenerateRoute: (settings) {
          if (settings.name == AppConstants.routePlatEdit) {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => PlatFormView(
                plat: args?['plat'],
                idResto: args?['idResto'] as int?,
              ),
            );
          }
          if (settings.name == AppConstants.routePlatsList) {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => PlatsListScreen(
                idResto: args?['idResto'] as int?,
                restaurantName: args?['restaurantName'] as String?,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
