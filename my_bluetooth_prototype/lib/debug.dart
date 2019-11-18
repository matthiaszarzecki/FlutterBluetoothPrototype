import 'package:flutter_blue/flutter_blue.dart';

/// Offers various bluetooth-related debug-messages
void debugLog(String message) {
  String _printMarker = '';
  for (int i = 0; i < message.length; i++) {
    _printMarker += '#';
  }

  print(_printMarker);
  print(_printMarker);
  print(message);
  print(_printMarker);
  print(_printMarker);
}

void debugLogCharacteristics(BluetoothCharacteristic characteristic) {
  String _printMarker = '############################################################';
  print(_printMarker);
  print(_printMarker);
  print('uuid:                 ${characteristic.uuid}');
  print('deviceId:             ${characteristic.deviceId}');
  print('serviceUuid:          ${characteristic.serviceUuid}');
  print('secondaryServiceUuid: ${characteristic.secondaryServiceUuid}');
  print('properties:           ${characteristic.properties}');
  print('descriptors:          ${characteristic.descriptors}');
  print(_printMarker);
  print(_printMarker);
}

void debugDevice(BluetoothDevice device) {
  String _printMarker = '############################################################';

  print(_printMarker);
  print(_printMarker);

  print(device.name);
  print(device.id);
  print(device.state);
  print(device.isDiscoveringServices);
  print(device.mtu);
  print(device.services);

  print(_printMarker);
  print(_printMarker);
}
