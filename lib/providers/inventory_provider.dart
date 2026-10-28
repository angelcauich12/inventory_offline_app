import 'package:inventory_offline_app/models/item_capture.model.dart';
import 'package:flutter/material.dart';

class InventoryProvider extends ChangeNotifier {
  ItemCapture itemCapture = ItemCapture(rack: '', items: []);
  Item item = Item(barcode: '', qty: 0);
  bool manualRackCapture = false;
  bool manualBarCodeCapture = false;

  resetRack() {
    itemCapture.rack = '';
    itemCapture.items = [];
    resetItem();
    notifyListeners();
  }

  resetItem() {
    item.barcode = '';
    item.qty = 0;
    manualRackCapture = false;
    manualBarCodeCapture = false;
    notifyListeners();
  }
}
