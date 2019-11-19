import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'package:my_bluetooth_prototype/debug.dart';

import 'package:my_bluetooth_prototype/device_screen.dart';
import 'package:my_bluetooth_prototype/scan_result_tile.dart';

/// A display of all available bluetooth-connections in range
class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Matthias' Bluetooth Devices"),
      ),
      body: RefreshIndicator(
        onRefresh: _startScanRefresh,
        child: _buildDeviceList(context),
      ),
      floatingActionButton: _buildSearchForDevicesButton(),
    );
  }

  Future<dynamic> _startScanRefresh() {
    return FlutterBlue.instance.startScan(
      timeout: const Duration(seconds: 4),
    );
  }

  // A Scrollview with all discovered Bluetooth-Devices
  SingleChildScrollView _buildDeviceList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildListOfPreviouslyConnectedDevices(),
          _buildListOfUnconnectedDevices(),
        ],
      ),
    );
  }

  StreamBuilder<List<BluetoothDevice>>
      _buildListOfPreviouslyConnectedDevices() {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: Stream<dynamic>.periodic(
        const Duration(seconds: 2),
      ).asyncMap(
        (dynamic _) {
          return FlutterBlue.instance.connectedDevices;
        },
      ),
      initialData: const <BluetoothDevice>[],
      builder: (
        BuildContext context,
        AsyncSnapshot<List<BluetoothDevice>> snapshot,
      ) {
        return Column(
          children: snapshot.data.map(
            (BluetoothDevice device) {
              return _buildConnectedDeviceTile(device, context);
            },
          ).toList(),
        );
      },
    );
  }

  StreamBuilder<List<ScanResult>> _buildListOfUnconnectedDevices() {
    return StreamBuilder<List<ScanResult>>(
            stream: FlutterBlue.instance.scanResults,
            initialData: const <ScanResult>[],
            builder: (
              BuildContext context,
              AsyncSnapshot<List<ScanResult>> snapshot,
            ) {
              return Column(
                children: snapshot.data
                    .map(
                      (ScanResult result) =>
                          _buildScanResultTile(result, context),
                    )
                    .toList(),
              );
            },
          );
  }

  ScanResultTile _buildScanResultTile(ScanResult result, BuildContext context) {
    return ScanResultTile(
      result: result,
      onTap: () => Navigator.of(context).push<dynamic>(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) {
            result.device.connect();
            return DeviceScreen(device: result.device);
          },
        ),
      ),
    );
  }

  ListTile _buildConnectedDeviceTile(
    BluetoothDevice device,
    BuildContext context,
  ) {
    return ListTile(
      title: Text(device.name),
      subtitle: Text(device.id.toString()),
      trailing: StreamBuilder<BluetoothDeviceState>(
        stream: device.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (
          BuildContext context,
          AsyncSnapshot<BluetoothDeviceState> snapshot,
        ) {
          if (snapshot.data == BluetoothDeviceState.connected) {
            return RaisedButton(
              child: const Text('OPEN'),
              onPressed: () => Navigator.of(context).push<dynamic>(
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) {
                    return DeviceScreen(device: device);
                  },
                ),
              ),
            );
          }
          return Text(snapshot.data.toString());
        },
      ),
    );
  }

  StreamBuilder<bool> _buildSearchForDevicesButton() {
    return StreamBuilder<bool>(
      stream: FlutterBlue.instance.isScanning,
      initialData: false,
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshot,
      ) {
        if (snapshot.data) {
          return FloatingActionButton(
            child: Icon(Icons.stop),
            onPressed: _stopScanButton,
            backgroundColor: Colors.red,
          );
        } else {
          return FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: _startScanButton,
          );
        }
      },
    );
  }

  void _stopScanButton() {
    FlutterBlue.instance.stopScan();
  }

  void _startScanButton() {
    debugLog('Start Scan Pressed');
    FlutterBlue.instance.startScan(
      timeout: const Duration(seconds: 4),
    );
  }
}
