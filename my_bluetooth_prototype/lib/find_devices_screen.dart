import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:my_bluetooth_prototype/device_screen.dart';
import 'package:my_bluetooth_prototype/scan_result_tile.dart';

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBlue.instance.startScan(
          timeout: const Duration(seconds: 4),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream<dynamic>.periodic(const Duration(seconds: 2))
                    .asyncMap(
                  (dynamic _) => FlutterBlue.instance.connectedDevices,
                ),
                initialData: <BluetoothDevice>[],
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<BluetoothDevice>> snapshot,
                ) =>
                    Column(
                  children: snapshot.data
                      .map(
                        (BluetoothDevice device) => ListTile(
                          title: Text(device.name),
                          subtitle: Text(device.id.toString()),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: device.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<BluetoothDeviceState> snapshot,
                            ) {
                              if (snapshot.data ==
                                  BluetoothDeviceState.connected) {
                                return RaisedButton(
                                  child: const Text('OPEN'),
                                  onPressed: () =>
                                      Navigator.of(context).push<dynamic>(
                                    MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          DeviceScreen(device: device),
                                    ),
                                  ),
                                );
                              }
                              return Text(snapshot.data.toString());
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<ScanResult>> snapshot,
                ) =>
                    Column(
                  children: snapshot.data
                      .map(
                        (ScanResult result) => ScanResultTile(
                          result: result,
                          onTap: () => Navigator.of(context).push<dynamic>(
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) {
                                result.device.connect();
                                return DeviceScreen(device: result.device);
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: () => FlutterBlue.instance.startScan(
                timeout: const Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }
}
