import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:my_bluetooth_prototype/characteristic_tile.dart';
import 'package:my_bluetooth_prototype/descriptor_tile.dart';
import 'package:my_bluetooth_prototype/service_tile.dart';

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
            builder: (
              BuildContext context,
              AsyncSnapshot<BluetoothDeviceState> snapshot,
            ) {
              return _buildConnectDisconnectButton(context, snapshot);
            },
          )
        ],
      ),
      body: _buildScrollView(),
    );
  }

  // Connect / Disconnect Text-Button in the upper right corner
  FlatButton _buildConnectDisconnectButton(
    BuildContext context,
    AsyncSnapshot<BluetoothDeviceState> snapshot,
  ) {
    VoidCallback onPressed;
    String text;
    switch (snapshot.data) {
      case BluetoothDeviceState.connected:
        onPressed = () => device.disconnect();
        text = 'DISCONNECT DEV.';
        break;
      case BluetoothDeviceState.disconnected:
        onPressed = () => device.connect();
        text = 'CONNECT DEV.';
        break;
      default:
        onPressed = null;
        text = snapshot.data.toString().substring(21).toUpperCase();
        break;
    }
    return FlatButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: _buildTextStyle(context),
      ),
    );
  }

  SingleChildScrollView _buildScrollView() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (
              BuildContext context,
              AsyncSnapshot<BluetoothDeviceState> snapshot,
            ) {
              return ListTile(
                // Bluetooth active/inactive icon
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                // Device is connected / disconnected text on Device-Page
                title: Text(
                  'Device is ${snapshot.data.toString().split('.')[1]}.',
                ),
                subtitle: Text('${device.id}'),
                // Refresh/Loading-Button in upper right on device-page
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<bool> snapshot,
                  ) {
                    return IndexedStack(
                      index: snapshot.data ? 1 : 0,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => device.discoverServices(),
                        ),
                        IconButton(
                          icon: SizedBox(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                            width: 18.0,
                            height: 18.0,
                          ),
                          onPressed: null,
                        )
                      ],
                    );
                  },
                ),
              );
            },
          ),
          StreamBuilder<int>(
            stream: device.mtu,
            initialData: 0,
            builder: (
              BuildContext context,
              AsyncSnapshot<int> snapshot,
            ) {
              return ListTile(
                title: const Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              );
            },
          ),
          StreamBuilder<List<BluetoothService>>(
            stream: device.services,
            initialData: const <BluetoothService>[],
            builder: (
              BuildContext context,
              AsyncSnapshot<List<BluetoothService>> snapshot,
            ) {
              return Column(
                children: _buildServiceTiles(snapshot.data),
              );
            },
          ),
        ],
      ),
    );
  }

  List<int> _getRandomBytes() {
    final Random random = Random();
    return <int>[
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services.map(
      (BluetoothService service) {
        return ServiceTile(
          service: service,
          characteristicTiles: service.characteristics.map(
            (BluetoothCharacteristic characteristic) {
              return CharacteristicTile(
                characteristic: characteristic,
                onReadPressed: () => characteristic.read(),
                onWritePressed: () => characteristic.write(_getRandomBytes()),
                onNotificationPressed: () =>
                    characteristic.setNotifyValue(!characteristic.isNotifying),
                descriptorTiles: characteristic.descriptors.map(
                  (BluetoothDescriptor descriptor) {
                    return DescriptorTile(
                      descriptor: descriptor,
                      onReadPressed: () => descriptor.read(),
                      onWritePressed: () => descriptor.write(_getRandomBytes()),
                    );
                  },
                ).toList(),
              );
            },
          ).toList(),
        );
      },
    ).toList();
  }

  TextStyle _buildTextStyle(BuildContext context) {
    return Theme.of(context)
        .primaryTextTheme
        .button
        .copyWith(color: Colors.white);
  }
}
