import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue_example/characteristic_tile.dart';

/// A Display-Tile for a Bluetooth-Device that HAS been
/// previously Connected to the app.
class ServiceTile extends StatelessWidget {
  const ServiceTile({
    Key key,
    this.service,
    this.characteristicTiles,
  }) : super(key: key);

  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.length > 0) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Service'),
            Text(
              '0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
              //'0x${service.uuid.toString().toUpperCase()}',
              style: _buildTextStyle(context),
            )
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Service'),
        subtitle: Text(
          '0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
          //'0x${service.uuid.toString().toUpperCase()}',
        ),
      );
    }
  }

  TextStyle _buildTextStyle(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .body1
        .copyWith(color: Theme.of(context).textTheme.caption.color);
  }
}
