import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:my_bluetooth_prototype/characteristic_tile.dart';
import 'package:my_bluetooth_prototype/descriptor_tile.dart';
import 'package:my_bluetooth_prototype/service_tile.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

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
    return services
        .map(
          (BluetoothService service) => ServiceTile(
            service: service,
            characteristicTiles: service.characteristics
                .map(
                  (BluetoothCharacteristic characteristic) =>
                      CharacteristicTile(
                    characteristic: characteristic,
                    onReadPressed: () => characteristic.read(),
                    onWritePressed: () =>
                        characteristic.write(_getRandomBytes()),
                    onNotificationPressed: () => characteristic
                        .setNotifyValue(!characteristic.isNotifying),
                    descriptorTiles: characteristic.descriptors
                        .map(
                          (BluetoothDescriptor descriptor) => DescriptorTile(
                            descriptor: descriptor,
                            onReadPressed: () => descriptor.read(),
                            onWritePressed: () =>
                                descriptor.write(_getRandomBytes()),
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
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
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
              builder: (
                BuildContext context,
                AsyncSnapshot<BluetoothDeviceState> snapshot,
              ) =>
                  ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                  'Device is ${snapshot.data.toString().split('.')[1]}.',
                ),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<bool> snapshot,
                  ) =>
                      IndexedStack(
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
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (
                BuildContext context,
                AsyncSnapshot<int> snapshot,
              ) =>
                  ListTile(
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
              initialData: <BluetoothService>[],
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
      ),
    );
  }

  TextStyle _buildTextStyle(BuildContext context) {
    return Theme.of(context)
        .primaryTextTheme
        .button
        .copyWith(color: Colors.white);
  }
}
