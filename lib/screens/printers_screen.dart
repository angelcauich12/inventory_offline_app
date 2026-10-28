import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/enums.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/generator.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/pos_column.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:thermal_printer/thermal_printer.dart';

class PrinterScreen extends StatefulWidget {
  static const String routeName = 'printers';
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {

  // Printer Type [bluetooth, usb, network]
  var defaultPrinterType = PrinterType.usb;
  var _isBle = false;
  var _reconnect = false;
  var _isConnected = false;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  StreamSubscription<TCPStatus>? _subscriptionTCPStatus;
  BTStatus _currentStatus = BTStatus.none;
  // ignore: unused_field
  TCPStatus _currentTCPStatus = TCPStatus.none;
  // _currentUsbStatus is only supports on Android
  // ignore: unused_field
  USBStatus _currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  String _ipAddress = '';
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  BluetoothPrinter? selectedPrinter;

  @override
  void initState() {
    if (Platform.isWindows) defaultPrinterType = PrinterType.usb;
    super.initState();
    _portController.text = _port;
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) {
      print(' ----------------- status bt $status ------------------ ');
      _currentStatus = status;
      if (status == BTStatus.connected) {
        setState(() {
          _isConnected = true;
        });
      }
      if (status == BTStatus.none) {
        setState(() {
          _isConnected = false;
        });
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      print(' ----------------- status usb $status ------------------ ');
      _currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(type: PrinterType.usb, bytes: pendingTask!);
            pendingTask = null;
          });
        }
      }
    });

    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionTCPStatus = PrinterManager.instance.stateTCP.listen((status) {
      print(' ----------------- status tcp $status ------------------ ');
      _currentTCPStatus = status;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _subscriptionUsbStatus?.cancel();
    _subscriptionTCPStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // method to scan devices according PrinterType
  void _scan() {
    devices.clear();
    _subscription = printerManager.discovery(type: defaultPrinterType, isBle: _isBle).listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
      setState(() {});
    });
  }

  void setPort(String value) {
    if (value.isEmpty) value = '9100';
    _port = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void setIpAddress(String value) {
    _ipAddress = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void selectDevice(BluetoothPrinter device) async {
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter!.address) || (device.typePrinter == PrinterType.usb && selectedPrinter!.vendorId != device.vendorId)) {
        await PrinterManager.instance.disconnect(type: selectedPrinter!.typePrinter);
      }
    }

    selectedPrinter = device;
    setState(() {});
  }

  Future _printReceiveTest() async {
    List<int> bytes = [];

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load();

    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text('Test Print', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Product 1');
    bytes += generator.text('Product 2');

    // bytes += generator.text('￥1,990', containsChinese: true, styles: const PosStyles(align: PosAlign.left));
    // bytes += generator.emptyLines(1);

    // sum width total column must be 12
    bytes += generator.row([
      PosColumn(width: 8, text: 'Lemon lime export quality per pound x 5 units', styles: const PosStyles(align: PosAlign.left, codeTable: 'CP1252')),
      PosColumn(width: 4, text: 'USD 2.00', styles: const PosStyles(align: PosAlign.right, codeTable: 'CP1252')),
    ]);

   

    // // Chinese characters
    bytes += generator.row([
      PosColumn(width: 8, text: '豚肉・木耳と玉子炒め弁当', styles: const PosStyles(align: PosAlign.left), containsChinese: true),
      PosColumn(width: 4, text: '￥1,990', styles: const PosStyles(align: PosAlign.right), containsChinese: true),
    ]);
    _printEscPos(bytes, generator);
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    var connectedTCP = false;
    if (selectedPrinter == null) return;
    var bluetoothPrinter = selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(name: bluetoothPrinter.deviceName, productId: bluetoothPrinter.productId, vendorId: bluetoothPrinter.vendorId));
        pendingTask = null;
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address!,
                isBle: bluetoothPrinter.isBle ?? false,
                autoConnect: _reconnect));
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        connectedTCP = await printerManager.connect(type: bluetoothPrinter.typePrinter, model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!));
        if (!connectedTCP) print(' --- please review your connection ---');
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth && Platform.isAndroid) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    }
  }

  // conectar dispositivo
  _connectDevice() async {
    _isConnected = false;
    if (selectedPrinter == null) return;
    switch (selectedPrinter!.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: UsbPrinterInput(name: selectedPrinter!.deviceName, productId: selectedPrinter!.productId, vendorId: selectedPrinter!.vendorId));
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: BluetoothPrinterInput(
                name: selectedPrinter!.deviceName,
                address: selectedPrinter!.address!,
                isBle: selectedPrinter!.isBle ?? false,
                autoConnect: _reconnect));
        break;
      case PrinterType.network:
        await printerManager.connect(type: selectedPrinter!.typePrinter, model: TcpPrinterInput(ipAddress: selectedPrinter!.address!));
        _isConnected = true;
        break;
      default:
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 400,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          DropdownButtonFormField<PrinterType>(
                            value: defaultPrinterType,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.print,
                                size: 24,
                              ),
                              labelText: "Type Printer Device",
                              labelStyle: TextStyle(fontSize: 18.0),
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            items: <DropdownMenuItem<PrinterType>>[
                              if (Platform.isAndroid || Platform.isWindows)
                                const DropdownMenuItem(
                                  value: PrinterType.usb,
                                  child: Text("usb"),
                                ),
                            ],
                            onChanged: (PrinterType? value) {
                              setState(() {
                                if (value != null) {
                                  setState(() {
                                    defaultPrinterType = value;
                                    selectedPrinter = null;
                                    _isBle = false;
                                    _isConnected = false;
                                    _scan();
                                  });
                                }
                              });
                            },
                          ),
                          Column(
                            children: devices
                                .map((device) => ListTile(
                                      title: Text('${device.deviceName}'),
                                      subtitle: Platform.isAndroid && defaultPrinterType == PrinterType.usb
                                          ? Visibility(
                                              visible: !Platform.isWindows,
                                              child: Text("${device.vendorId} - ${device.productId}  "))
                                          : Visibility(
                                              visible: !Platform.isWindows,
                                              child: Text("${device.address}")),
                                      leading: selectedPrinter != null &&
                                              ((device.typePrinter ==
                                                              PrinterType.usb &&
                                                          Platform.isWindows
                                                      ? device.deviceName ==
                                                          selectedPrinter!
                                                              .deviceName
                                                      : device.vendorId !=
                                                              null &&
                                                          selectedPrinter!
                                                                  .vendorId ==
                                                              device
                                                                  .vendorId) ||
                                                  (device.address != null &&
                                                      selectedPrinter!
                                                              .address ==
                                                          device.address))
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                          : null,
                                      trailing: OutlinedButton(
                                        onPressed: selectedPrinter == null ||
                                                device.deviceName != selectedPrinter?.deviceName
                                            ?  null
                                            : () async {
                                                _printReceiveTest();
                                              },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 20),
                                          child: Text("Print test ticket",
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                      onTap: () async {
                                        // do something
                                       selectDevice(device);
                                        // Notifications.showSnackBar('Conectando dispositivo');
                                        _connectDevice();
                                      },
                                    )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                ),
                   ElevatedButton(
                        onPressed: () async {
                          await SunmiPrinter.lcdInitialize(); //Initialize the LCD
                          await SunmiPrinter.lcdWakeup(); //Turn the LCD ON
                          await SunmiPrinter.lcdSleep(); //Turn the LCD OFF
                          await SunmiPrinter.lcdClear(); //Clear LCD screen
                          await SunmiPrinter.lcdString(
                              'Hello'); //Write a simple line
                          await SunmiPrinter.lcdString(
                              'Hello'); //Write a simple line
                          await SunmiPrinter.lcdDoubleString(
                              'Hello', 'World'); //Wr
                        },
                        child: const Text('LCD Function')),
                
              ],
              
            ),
          ),
        ),
      ),
    );
  }
}




class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter(
      {this.deviceName,
      this.address,
      this.port,
      this.state,
      this.vendorId,
      this.productId,
      this.typePrinter = PrinterType.bluetooth,
      this.isBle = false});
}