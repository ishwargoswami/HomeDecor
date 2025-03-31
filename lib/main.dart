import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foodybite/firebase_options.dart';
import 'package:flutter_foodybite/screens/login_screen.dart';
import 'package:flutter_foodybite/screens/main_screen.dart';
import 'package:flutter_foodybite/screens/splash_screen.dart';
import 'package:flutter_foodybite/screens/add_project.dart';
import 'package:flutter_foodybite/screens/add_decor_item.dart';
import 'package:flutter_foodybite/screens/project_dashboard.dart';
import 'package:flutter_foodybite/services/auth_provider.dart';
import 'package:flutter_foodybite/services/budget_provider.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/services/notification_provider.dart';
import 'package:flutter_foodybite/services/theme_provider.dart';
import 'package:flutter_foodybite/services/storage_service.dart';
import 'package:flutter_foodybite/util/const.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}

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
        Provider(create: (_) => StorageService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: Constants.appName,
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
            },
            initialRoute: '/',
          );
        }
      ),
    );
  }
}
