import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:flutter_blue_example/characteristic_tile.dart';
import 'package:flutter_blue_example/debug.dart';
import 'package:flutter_blue_example/descriptor_tile.dart';
import 'package:flutter_blue_example/service_tile.dart';

/// Screen that shows the Bluetooth-Status of a single device/connection
class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (BuildContext context, AsyncSnapshot<BluetoothDeviceState> snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = _connectToDevice;
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  //text = snapshot.data.toString().toUpperCase();
                  break;
              }
              // Connect / Disconnect Button
              return FlatButton(
                onPressed: onPressed,
                child: Text(
                  text,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (BuildContext context, AsyncSnapshot<BluetoothDeviceState> snapshot) => ListTile(
                // Bluetooth active/inactive icon
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                // Device is connected / disconnected text on Device-Page
                title: Text(
                  'Device is ${snapshot.data.toString().split('.')[1]}.',
                ),
                //
                subtitle: Text('ID: ${device.id}'),
                // Refresh/Loading-Button in upper right on device-page
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) => IndexedStack(
                    index: snapshot.data ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        color: Colors.green,
                        icon: Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      IconButton(
                        color: Colors.green,
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) => ListTile(
                title: const Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (BuildContext context, AsyncSnapshot<List<BluetoothService>> snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onReadPressed(BluetoothCharacteristic characteristic) {
    characteristic.read();
    debugLog('Read Pressed');
    debugLogCharacteristics(characteristic);
  }

  void _onWritePressed(BluetoothCharacteristic characteristic) {
    characteristic.write(<int>[13, 24]);
    debugLog('Write Pressed');
    debugLogCharacteristics(characteristic);
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (BluetoothService service) => ServiceTile(
            service: service,
            characteristicTiles: service.characteristics
                .map(
                  (BluetoothCharacteristic characteristic) => CharacteristicTile(
                    characteristic: characteristic,
                    onReadPressed: () => _onReadPressed(characteristic),
                    onWritePressed: () => _onWritePressed(characteristic),
                    onNotificationPressed: () => characteristic
                        .setNotifyValue(!characteristic.isNotifying),
                    descriptorTiles: characteristic.descriptors
                        .map(
                          (BluetoothDescriptor descriptor) => DescriptorTile(
                            descriptor: descriptor,
                            onReadPressed: () => descriptor.read(),
                            onWritePressed: () => descriptor.write(<int>[11, 12]),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  void _connectToDevice() {
    device.connect();
    debugLog('Connecting to Device');
    debugDevice(device);
  }
}
