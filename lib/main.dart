import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/client/home_screen.dart';
import 'screens/client/products_screen.dart';
import 'screens/client/about_screen.dart';
import 'screens/admin/login_screen.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/edit_company_info_screen.dart';
import 'screens/client/client_login_screen.dart';
import 'screens/client/client_register_screen.dart';
import 'screens/client/cart_screen.dart';
import 'screens/client/wishlist_screen.dart';
import 'screens/client/my_orders_screen.dart';

import 'screens/admin/admin_orders_screen.dart';
import 'screens/client/profile_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betalab Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Color(0xFFd92b2c), // User specified Red
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFd92b2c),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: Color(0xFF212121), // Black/Dark Grey from logo
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      localizationsDelegates: [
        // TODO: Add Arabic localizations
      ],
      // supportedLocales: [Locale('ar', 'AE')],
      // locale: Locale('ar', 'AE'),
      home: HomeScreen(),
      routes: {
        '/products': (context) => ProductsScreen(),
        '/about': (context) => AboutScreen(),
        '/admin-login': (context) => LoginScreen(),
        '/admin-dashboard': (context) => DashboardScreen(),
        '/edit-company-info': (context) => EditCompanyInfoScreen(),
        '/client-login': (context) => ClientLoginScreen(),
        '/client-register': (context) => ClientRegisterScreen(),
        '/cart': (context) => CartScreen(),
        '/wishlist': (context) => WishlistScreen(),
        '/orders': (context) => MyOrdersScreen(),
        '/admin-orders': (context) => AdminOrdersScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
