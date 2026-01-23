import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // إضافة مكتبة قاعدة البيانات
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
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // تحديث هام: ربط التطبيق بسيرفر سنغافورة الخاص بك لتفعيل الإضافة والتعديل
  FirebaseDatabase.instance.databaseURL =
      "https://betalab-beta-lab-store-default-rtdb.asia-southeast1.firebasedatabase.app/";

  // اختبار الاتصال عند بدء التشغيل
  DatabaseService().testConnection();

  runApp(const MyApp());
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
        primaryColor: const Color(0xFFd92b2c),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFd92b2c),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: const Color(0xFF212121),
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: const HomeScreen(),
      routes: {
        '/products': (context) => const ProductsScreen(),
        '/about': (context) => const AboutScreen(),
        '/admin-login': (context) => LoginScreen(),
        '/admin-dashboard': (context) => const DashboardScreen(),
        '/edit-company-info': (context) => const EditCompanyInfoScreen(),
        '/client-login': (context) => ClientLoginScreen(),
        '/client-register': (context) => ClientRegisterScreen(),
        '/cart': (context) => const CartScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/orders': (context) => MyOrdersScreen(),
        '/admin-orders': (context) => const AdminOrdersScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
