// To parse this JSON data, do
//
//     final itemCapture = itemCaptureFromJson(jsonString);

import 'dart:convert';

ItemCapture itemCaptureFromJson(String str) =>
    ItemCapture.fromJson(json.decode(str));

String itemCaptureToJson(ItemCapture data) => json.encode(data.toJson());

class ItemCapture {
  String rack;
  List<Item> items;

  ItemCapture({
    required this.rack,
    required this.items,
  });

  factory ItemCapture.fromJson(Map<String, dynamic> json) => ItemCapture(
        rack: json["rack"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "rack": rack,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  String barcode;
  int qty;

  Item({
    required this.barcode,
    required this.qty,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        barcode: json["barcode"],
        qty: json["qty"],
      );

  Map<String, dynamic> toJson() => {
        "barcode": barcode,
        "qty": qty,
      };
}
