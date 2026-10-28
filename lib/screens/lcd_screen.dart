import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dart_periphery/dart_periphery.dart';

class LcdScreen extends StatefulWidget {
  static const String routeName = 'lcd';
  const LcdScreen({super.key});

  @override
  State<LcdScreen> createState() => _LcdScreen();
}

class _LcdScreen extends State<LcdScreen> {
  // Variables para mostrar la respuesta
  String _serialResponse = '';
  String _gpioStatus = 'OFF';
  String _i2cResponse = '';
  String _spiResponse = '';

  // Control de GPIO
  void _toggleGPIO() {
    final gpio = GPIO(17, GPIOdirection.gpioDirOut);
    setState(() {
      if (_gpioStatus == 'OFF') {
        gpio.write(true); // Activa GPIO
        _gpioStatus = 'ON';
      } else {
        gpio.write(false); // Desactiva GPIO
        _gpioStatus = 'OFF';
      }
    });
    gpio.dispose();
  }

  // Comunicación Serial
  void _sendSerialCommand() async {
    final serial = Serial('/dev/ttyUSB0', Baudrate.b9600);
    serial.writeString('Comando a la pantalla LCD\n');
     // Leer los bytes recibidos
    // Leer el evento SerialReadEvent
    SerialReadEvent event = serial.read(100,100); // Este devuelve un SerialReadEventLee hasta 100 bytes
   // Extraer los datos en bytes
    List<int> responseBytes = event.data; // Extraer los bytes del evento
    
    // Convertir bytes a String
    String response = utf8.decode(responseBytes);
    setState(() {
      _serialResponse = response;
    });
    serial.dispose();
  }

  // Comunicación I2C
  void _sendI2CCommand() async {
    final i2c = I2C(1);
    const address = 0x27;  // Dirección del dispositivo I2C
    i2c.writeByte(address, 0x80);  // Enviar comando
    final data = i2c.readByte(address);
    setState(() {
      _i2cResponse = 'Datos recibidos: $data';
    });
    i2c.dispose();
  }

  // Comunicación SPI
  void _sendSPICommand() async {
     var spi = SPI(0, 0, SPImode.mode0, 1000000);
    final writeData = [0x01, 0x02, 0x03];
    spi.transfer(writeData,true);
    setState(() {
      _spiResponse = 'Datos enviados por SPI: $writeData';
    });
    spi.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Hardware'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Botón para GPIO
            ElevatedButton(
              onPressed: _toggleGPIO,
              child: Text('Toggle GPIO (LED $_gpioStatus)'),
            ),
            const SizedBox(height: 20),

            // Botón para Serial
            ElevatedButton(
              onPressed: _sendSerialCommand,
              child: const Text('Enviar Comando Serial'),
            ),
            const SizedBox(height: 10),
            Text('Respuesta Serial: $_serialResponse'),

            const SizedBox(height: 20),

            // Botón para I2C
            ElevatedButton(
              onPressed: _sendI2CCommand,
              child: const Text('Enviar Comando I2C'),
            ),
            const SizedBox(height: 10),
            Text('Respuesta I2C: $_i2cResponse'),

            const SizedBox(height: 20),

            // Botón para SPI
            ElevatedButton(
              onPressed: _sendSPICommand,
              child: const Text('Enviar Comando SPI'),
            ),
            const SizedBox(height: 10),
            Text('Respuesta SPI: $_spiResponse'),
          ],
        ),
      ),
    );
  }
}
