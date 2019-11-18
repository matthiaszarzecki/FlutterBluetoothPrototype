import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';

/// A Screen that displays a Bluetooth-Icon with a text saying "Bluetooth is off"
class BluetoothIsOffScreen extends StatelessWidget {
  const BluetoothIsOffScreen({Key key, this.state}) : super(key: key);

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
              // Full String is: "Bluetooth Adapter is BluetoothState.off"
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: _buildStyle(context),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _buildStyle(BuildContext context) {
    return Theme.of(context)
        .primaryTextTheme
        .subhead
        .copyWith(color: Colors.white);
  }
}
