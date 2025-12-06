import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fasalmitra/screens/home_page.dart';
import 'package:fasalmitra/widgets/custom_cursor_overlay.dart';

import 'package:fasalmitra/screens/phone_login.dart';
import 'package:fasalmitra/screens/create_listing_screen.dart';
import 'package:fasalmitra/screens/marketplace_screen.dart';
import 'package:fasalmitra/screens/register_screen.dart';
import 'package:fasalmitra/screens/cart_screen.dart';
import 'package:fasalmitra/screens/account_screen.dart';
import 'package:fasalmitra/screens/my_orders_screen.dart';
import 'package:fasalmitra/screens/orders_received_screen.dart';
import 'package:fasalmitra/screens/price_prediction_screen.dart';
import 'package:fasalmitra/services/auth_service.dart';
import 'package:fasalmitra/services/language_service.dart';
import 'package:fasalmitra/services/tip_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Removed Firebase

  final prefs = await SharedPreferences.getInstance();
  await AuthService.instance.init(prefs);

  await LanguageService.instance.init(prefs);
  await TipService.instance.init();

  // Create test user if not exists (Optional check)
  try {
    // Mock check or skip this entirely if connected to real API to avoid spamming
    // await AuthService.instance.signUpWithEmailPassword(
    //   email: 'test@email.com',
    //   password: 'Pass@123',
    //   username: 'Test User',
    //   mobile: '1234567890'
    // );
  } catch (e) {
    print('Test user creation skipped: $e');
  }

  runApp(const FasalMitraApp());
}

class FasalMitraApp extends StatelessWidget {
  const FasalMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final localeCode = LanguageService.instance.currentLanguage;
        return MaterialApp(
          title: 'FasalMitra',
          debugShowCheckedModeBanner: false,
          locale: Locale(localeCode),
          supportedLocales: LanguageService.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            return CustomCursorOverlay(child: child!);
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          home: const HomePage(),
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            RegisterScreen.routeName: (context) => const RegisterScreen(),
            HomePage.routeName: (context) => const HomePage(),
            CreateListingScreen.routeName: (context) =>
                const CreateListingScreen(),
            MarketplaceScreen.routeName: (context) => const MarketplaceScreen(),
            CartScreen.routeName: (context) => const CartScreen(),
            AccountScreen.routeName: (context) => const AccountScreen(),
            MyOrdersScreen.routeName: (context) => const MyOrdersScreen(),
            OrdersReceivedScreen.routeName: (context) =>
                const OrdersReceivedScreen(),
            PricePredictionScreen.routeName: (context) =>
                const PricePredictionScreen(),
          },
        );
      },
    );
  }
}
