import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:my_bluetooth_prototype/characteristic_tile.dart';
import 'package:my_bluetooth_prototype/debug.dart';
import 'package:my_bluetooth_prototype/descriptor_tile.dart';
import 'package:my_bluetooth_prototype/service_tile.dart';

/// Screen that shows the Bluetooth-Status of a single device/connection
class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildScrollView(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
        onPressed = () => _deviceDisconnect(device);
        text = 'DISCONNECT Device';
        break;
      case BluetoothDeviceState.disconnected:
        onPressed = () => _deviceConnect(device);
        text = 'CONNECT Device';
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

  void _deviceConnect(BluetoothDevice device) {
    debugLog('CONNECT Device');
    device.connect();
  }

  void _deviceDisconnect(BluetoothDevice device) {
    debugLog('DISCONNECT Device');
    device.disconnect();
  }

  SingleChildScrollView _buildScrollView() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildBluetoothInfoTile(),
          _buildMTUTile(),
          _buildCharacteristicTiles(),
        ],
      ),
    );
  }

  // Build a single tile with Bluetooth-connection icon, Device-Name, Device-ID, Refresh-Button
  StreamBuilder<BluetoothDeviceState> _buildBluetoothInfoTile() {
    return StreamBuilder<BluetoothDeviceState>(
      stream: device.state,
      initialData: BluetoothDeviceState.connecting,
      builder: (
        BuildContext context,
        AsyncSnapshot<BluetoothDeviceState> snapshot,
      ) {
        return ListTile(
          leading: _buildBluetoothConnectedDisabledIcon(snapshot),
          title: _buildDeviceConnectedHeader(snapshot),
          subtitle: _buildDeviceIDSubtitle(device),
          trailing: _buildRefreshConnectionButton(),
        );
      },
    );
  }

  // Build a single tile with the MTU Unit Size (Maximum Transmission Unit) & Edit-Button
  StreamBuilder<int> _buildMTUTile() {
    return StreamBuilder<int>(
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
            onPressed: _requestMTUSize,
          ),
        );
      },
    );
  }

  void _requestMTUSize() {
    debugLog('Requested MTU Size Change to 223 Bytes');
    device.requestMtu(223);
  }

  // Build tiles with Available Bluetooth-Characteristics
  StreamBuilder<List<BluetoothService>> _buildCharacteristicTiles() {
    return StreamBuilder<List<BluetoothService>>(
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
    );
  }

  Icon _buildBluetoothConnectedDisabledIcon(
    AsyncSnapshot<BluetoothDeviceState> snapshot,
  ) {
    return (snapshot.data == BluetoothDeviceState.connected)
        ? Icon(Icons.bluetooth_connected)
        : Icon(Icons.bluetooth_disabled);
  }

  Text _buildDeviceConnectedHeader(
    AsyncSnapshot<BluetoothDeviceState> snapshot,
  ) {
    return Text(
      'Device is ${snapshot.data.toString().split('.')[1]}.',
    );
  }

  Text _buildDeviceIDSubtitle(BluetoothDevice device) {
    return Text('ID: ${device.id}');
  }

  StreamBuilder<bool> _buildRefreshConnectionButton() {
    return StreamBuilder<bool>(
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
              onPressed: () => _discoverServices(),
            ),
            IconButton(
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
        );
      },
    );
  }

  Future<List<BluetoothService>> _discoverServices() {
    debugLog('Discovering Services');
    return device.discoverServices();
  }

  List<int> _getUnlockCode() {
    // Create unlock code as array of ints representing the characters
    // as ascii-codes in hexadecimal, followed by the unlock-mode (default 31).
    // 1, 2, 3, 4, 0, 0
    // -> 31, 32, 33, 34, 30, 30, 31
    return <int>[31, 32, 33, 34, 30, 30, 31];
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
    debugLog('Available Services: ${services.length}');
    return services.map(
      (BluetoothService service) {
        return ServiceTile(
          service: service,
          characteristicTiles: service.characteristics.map(
            (BluetoothCharacteristic characteristic) {
              return CharacteristicTile(
                characteristic: characteristic,
                onReadPressed: () => _onReadPressed(characteristic),
                onWritePressed: () => _onWritePressed(
                  characteristic,
                  _getUnlockCode(),
                ),
                onNotificationPressed: () =>
                    _onNotificationPressed(characteristic),
                descriptorTiles: _buildDescriptorTiles(characteristic),
              );
            },
          ).toList(),
        );
      },
    ).toList();
  }

  void _onReadPressed(BluetoothCharacteristic characteristic) {
    debugLog('READ CHARACTERISTIC');
    debugLogCharacteristics(characteristic);
    characteristic.read();
  }

  void _onWritePressed(
    BluetoothCharacteristic characteristic,
    List<int> payload,
  ) {
    debugLog('WRITE CHARACTERISTIC');
    debugLog(payload.toString());
    debugLogCharacteristics(characteristic);
    characteristic.write(payload);
  }

  void _onNotificationPressed(BluetoothCharacteristic characteristic) {
    debugLog('NOTIFICATION CHARACTERISTIC');
    debugLogCharacteristics(characteristic);
    characteristic.setNotifyValue(!characteristic.isNotifying);
  }

  List<DescriptorTile> _buildDescriptorTiles(
    BluetoothCharacteristic characteristic,
  ) {
    return characteristic.descriptors.map(
      (BluetoothDescriptor descriptor) {
        return DescriptorTile(
          descriptor: descriptor,
          onReadPressed: () => descriptor.read(),
          onWritePressed: () => descriptor.write(_getRandomBytes()),
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
