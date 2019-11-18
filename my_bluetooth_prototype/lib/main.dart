// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:my_bluetooth_prototype/bluetooth_off_screen.dart';
import 'package:my_bluetooth_prototype/find_devices_screen.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (
          BuildContext context,
          AsyncSnapshot<BluetoothState> snapshot,
        ) {
          final BluetoothState state = snapshot.data;
          return state == BluetoothState.on
              ? FindDevicesScreen()
              : BluetoothOffScreen(state: state);
        },
      ),
    );
  }
}
