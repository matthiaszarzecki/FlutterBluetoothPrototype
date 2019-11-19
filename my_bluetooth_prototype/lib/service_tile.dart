import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:my_bluetooth_prototype/characteristic_tile.dart';

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
    if (characteristicTiles.isNotEmpty) {
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Service'),
            Text(
              '0x${service.uuid.toString().toUpperCase().substring(4, 8)}, UUID: ${service.uuid.toString().toUpperCase()}',
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
