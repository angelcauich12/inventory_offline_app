import 'dart:isolate';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:inventory_offline_app/screens/upload_screen.dart';

class UploadProvider extends ChangeNotifier {
  List<List<dynamic>> _excelDataList = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<List<dynamic>> get excelDataList => _excelDataList;

  set excelDataList(List<List<dynamic>> value) {
    _excelDataList = value;
  }
}
