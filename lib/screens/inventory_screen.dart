import 'package:flutter/material.dart';
import 'package:inventory_offline_app/providers/inventory_provider.dart';
import 'package:inventory_offline_app/ui/input_decorations_rounded.dart';
import 'package:provider/provider.dart';

class InventoryScreen extends StatefulWidget {
  static String routeName = 'inventory';
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final invProvider = Provider.of<InventoryProvider>(context);
    print('rack capture');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventario',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (invProvider.itemCapture.rack.isEmpty)
                ? Column(
                    children: [
                      Form(
                        key: UniqueKey(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              autofocus: true,
                              autocorrect: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecorationsRounded
                                  .authInputDecorationRounded(
                                hintText: 'xxxxxxxxxxxxxx',
                                labelText: 'Mueble',
                                color: Colors.purple,
                              ),
                              onChanged: (invProvider.manualRackCapture)
                                  ? null
                                  : (value) {
                                      setState(() {
                                        invProvider.itemCapture.rack = value;
                                      });
                                    },
                              validator: (value) {
                                return (value != null && value.isNotEmpty)
                                    ? null
                                    : 'Captura el mueble';
                              },
                              onFieldSubmitted: (value) {
                                setState(() {
                                  invProvider.itemCapture.rack = value;
                                  invProvider.manualRackCapture = false;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            invProvider.manualRackCapture =
                                !invProvider.manualRackCapture;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: (invProvider.manualRackCapture)
                                ? Colors.green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Captura manual',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : (invProvider.item.barcode.isEmpty &&
                        invProvider.item.qty == 0)
                    ? Column(
                        children: [
                          Form(
                            key: UniqueKey(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextFormField(
                                  autofocus: true,
                                  autocorrect: false,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecorationsRounded
                                      .authInputDecorationRounded(
                                    hintText: 'xxxxxxxxxxxxxx',
                                    labelText: 'Código de Barras',
                                    color: Colors.purple,
                                  ),
                                  onChanged: (invProvider.manualBarCodeCapture)
                                      ? null
                                      : (value) {
                                          setState(() {
                                            invProvider.item.barcode = value;
                                          });
                                        },
                                  validator: (value) {
                                    return (value != null && value.isNotEmpty)
                                        ? null
                                        : 'Captura un código';
                                  },
                                  onFieldSubmitted: (value) {
                                    setState(() {
                                      invProvider.item.barcode = value;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                invProvider.manualBarCodeCapture =
                                    !invProvider.manualBarCodeCapture;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: (invProvider.manualBarCodeCapture)
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                'Captura manual',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : (invProvider.item.barcode.isNotEmpty &&
                            invProvider.item.qty == 0)
                        ? Center(
                            child: Form(
                              key: UniqueKey(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    readOnly: true,
                                    keyboardType: TextInputType.text,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecorationsRounded
                                        .authInputDecorationRounded(
                                      hintText: '',
                                      labelText: 'Código',
                                      color: Colors.purple,
                                    ),
                                    initialValue: invProvider.item.barcode,
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    initialValue:
                                        invProvider.item.qty.toString(),
                                    autofocus: true,
                                    autocorrect: false,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecorationsRounded
                                        .authInputDecorationRounded(
                                      hintText: '',
                                      labelText: 'Cantidad',
                                      color: Colors.purple,
                                    ),
                                    // onChanged: (value) => print(value),
                                    validator: (value) {
                                      return (value != null && value.isNotEmpty)
                                          ? null
                                          : 'Captura la cantidad';
                                    },
                                    onFieldSubmitted: (value) {
                                      print('Cantidad $value');
                                      setState(() {
                                        invProvider.item.qty = int.parse(value);
                                        invProvider.itemCapture.items
                                            .add(invProvider.item);
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Column(
                              children: [
                                Text(
                                    'Items ${invProvider.itemCapture.items.length}'),
                                const Text('Codigo capturado'),
                                Text(invProvider.item.barcode),
                                Text(
                                  invProvider.item.qty.toString(),
                                ),
                                TextButton(
                                  onPressed: () {
                                    invProvider.resetItem();
                                  },
                                  child: const Text('Capturar otro codigo'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    invProvider.resetRack();
                                  },
                                  child: const Text('Cambio de Mueble'),
                                )
                              ],
                            ),
                          )
          ],
        ),
      ),
    );
  }
}
