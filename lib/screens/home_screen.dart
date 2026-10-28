import 'dart:math';

import 'package:inventory_offline_app/models/item_capture.model.dart';
import 'package:inventory_offline_app/providers/inventory_provider.dart';
import 'package:inventory_offline_app/screens/inventory_screen.dart';
import 'package:inventory_offline_app/screens/lcd_screen.dart';
import 'package:inventory_offline_app/screens/printers_screen.dart';
import 'package:inventory_offline_app/screens/upload_screen.dart';
import 'package:inventory_offline_app/ui/input_decorations_rounded.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InventoryProvider>(context);
    print('rack capture');
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () =>
                      Navigator.pushNamed(context, UploadScreen.routeName),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey[500],
                  elevation: 5,
                  color: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  child: const Text(
                    'Cargar XLS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () =>
                      Navigator.pushNamed(context, InventoryScreen.routeName),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey[500],
                  elevation: 5,
                  color: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  child: const Text(
                    'Capturar Inventario',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                 MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () =>
                      Navigator.pushNamed(context, PrinterScreen.routeName),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey[500],
                  elevation: 5,
                  color: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  child: const Text(
                    'Módulo de impresoras',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  onPressed: () =>
                      Navigator.pushNamed(context, LcdScreen.routeName),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledColor: Colors.grey[500],
                  elevation: 5,
                  color: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  child: const Text(
                    'Módulo pantalla LCD ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
