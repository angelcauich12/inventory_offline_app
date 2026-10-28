import 'dart:isolate';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inventory_offline_app/providers/upload_provider.dart';
import 'package:inventory_offline_app/screens/item_list_screen.dart';
import 'package:provider/provider.dart';

class UploadScreen extends StatefulWidget {
  static String routeName = 'upload';
  static const int MAXCOLUMNUMBER = 12;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? filePath;

  @override
  void initState() {
    // final uploadProvider = context.read<UploadProvider>();
    // uploadProvider.isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = Provider.of<UploadProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cargar XLS',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: (uploadProvider.isLoading)
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: () => pickFile(uploadProvider),
                child: const Text('Cargar XLS'),
              ),
      ),
    );
  }

  void pickFile(UploadProvider uploadProvider) async {
    try {
      uploadProvider.isLoading = true;
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
        withData: true,
      );

      if (pickedFile != null) {
        uploadProvider.excelDataList =
            await Isolate.run(() => processXLSFile(pickedFile));
        if (context.mounted) {
          Navigator.pushNamed(context, ItemListScreen.routeName);
        }
      }
      uploadProvider.isLoading = false;
    } catch (e) {
      uploadProvider.isLoading = false;
      print('Error: $e');
      final snackBar = SnackBar(
        content: Text('$e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

processXLSFile(pickedFile) {
  var bytes = pickedFile.files.single.bytes;
  // print(bytes);
  List<List<dynamic>> excelData = [];

  var excel = Excel.decodeBytes(bytes!);
  for (var table in excel.tables.keys) {
    for (var row in excel.tables[table]?.rows ?? []) {
      List<dynamic> rowData = [];

      for (var cell in row) {
        final value = cell.value; // Obtiene el valor de la celda
        rowData.add(value); // Agrega el valor a la lista de la fila
        debugPrint('$rowData');
      }

      // Verifica si el código de barras ya existe en la lista
      String? barcode = rowData.length > 1
          ? rowData[1].toString()
          : null; // El código de barras está en la segunda celda (índice 1)
      // print(barcode);
      bool exists = excelData.any(
          (element) => element.length > 1 && element[1].toString() == barcode);

      if (!exists && barcode != null) {
        excelData.add(
            rowData); // Agrega la fila completa a la lista principal si no existe
      }
    }
  }

  // validaciones para columnas
  if (excelData[0][0].toString() != 'articulo' ||
      excelData[0][1].toString() != 'codigo de barra' ||
      excelData[0][2].toString() != 'descripcion') {
    debugPrint('${excelData[0][0]}');
    // excelData = [];
    throw Exception(
        'No coinciden las columnas ${excelData[0][0]} | ${excelData[0][1]} | ${excelData[0][2]}');
  }

  // debugPrint(excelData.length.toString());
  return excelData;
}
