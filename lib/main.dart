import 'package:inventory_offline_app/providers/inventory_provider.dart';
import 'package:inventory_offline_app/providers/upload_provider.dart';
import 'package:inventory_offline_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:inventory_offline_app/screens/inventory_screen.dart';
import 'package:inventory_offline_app/screens/item_list_screen.dart';
import 'package:inventory_offline_app/screens/lcd_screen.dart';
import 'package:inventory_offline_app/screens/printers_screen.dart';
import 'package:inventory_offline_app/screens/upload_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InventoryProvider>(
          create: (context) => InventoryProvider(),
        ),
        ChangeNotifierProvider<UploadProvider>(
          create: (context) => UploadProvider(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        UploadScreen.routeName: (context) => UploadScreen(),
        ItemListScreen.routeName: (context) => ItemListScreen(),
        InventoryScreen.routeName: (context) => const InventoryScreen(),
        PrinterScreen.routeName: (context) => const PrinterScreen(),
        LcdScreen.routeName:(context) => const LcdScreen()
      },
    );
  }
}
