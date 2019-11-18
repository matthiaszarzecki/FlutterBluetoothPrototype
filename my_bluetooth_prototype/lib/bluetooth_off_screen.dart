import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';

/// A screen that displays that the bluetooth-connectivity is off
class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              _getBluetoothStateString(state),
              style: _buildStyle(context),
            ),
          ],
        ),
      ),
    );
  }

  String _getBluetoothStateString(BluetoothState state) {
    String stateString = 'Bluetooth Adapter is ';
    if (state == BluetoothState.on) {
      stateString += 'on.';
    } else {
      stateString += 'off.';
    }
    return stateString;
  }

  TextStyle _buildStyle(BuildContext context) {
    return Theme.of(context)
        .primaryTextTheme
        .subhead
        .copyWith(color: Colors.white);
  }
}
