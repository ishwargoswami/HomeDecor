import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:decor_home/firebase_options.dart';
import 'package:decor_home/screens/cart_screen.dart';
import 'package:decor_home/screens/login_screen.dart';
import 'package:decor_home/screens/main_screen.dart';
import 'package:decor_home/screens/splash_screen.dart';
import 'package:decor_home/screens/add_project.dart';
import 'package:decor_home/screens/add_decor_item.dart';
import 'package:decor_home/screens/project_dashboard.dart';
import 'package:decor_home/screens/wishlist_screen.dart';
import 'package:decor_home/screens/orders_screen.dart';
import 'package:decor_home/screens/recently_viewed_screen.dart';
import 'package:decor_home/services/auth_provider.dart';
import 'package:decor_home/services/budget_provider.dart';
import 'package:decor_home/services/cart_service.dart';
import 'package:decor_home/services/decor_provider.dart';
import 'package:decor_home/services/notification_provider.dart';
import 'package:decor_home/services/theme_provider.dart';
import 'package:decor_home/services/storage_service.dart';
import 'package:decor_home/util/const.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}

// Application icon reference - use this for the app icon
// This icon name can be used with Flutter's icon font system
// Icons.home_work_rounded - A rounded house icon for home decoration app

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DecorProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CartService()),
        Provider(create: (_) => StorageService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'DecorHome',
            debugShowCheckedModeBanner: false,
            theme: Constants.lightTheme,
            darkTheme: Constants.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routes: {
              '/': (context) => SplashScreen(),
              '/login': (context) => LoginScreen(),
              '/main': (context) => MainScreen(),
              '/add_project': (context) => AddProjectScreen(),
              '/add_decor_item': (context) => AddDecorItemScreen(),
              '/dashboard': (context) => ProjectDashboardScreen(),
              '/cart': (context) => CartScreen(),
              '/wishlist': (context) => WishlistScreen(),
              '/orders': (context) => OrdersScreen(),
              '/recently_viewed': (context) => RecentlyViewedScreen(),
            },
            initialRoute: '/',
          );
        }
      ),
    );
  }
}
