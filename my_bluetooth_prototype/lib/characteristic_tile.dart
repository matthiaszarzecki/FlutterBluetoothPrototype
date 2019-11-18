// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue_example/descriptor_tile.dart';

class CharacteristicTile extends StatelessWidget {
  const CharacteristicTile({
    Key key,
    this.characteristic,
    this.descriptorTiles,
    this.onReadPressed,
    this.onWritePressed,
    this.onNotificationPressed,
  }) : super(key: key);

  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        final List<int> value = snapshot.data;
        Color iconColor = Theme.of(context).iconTheme.color.withOpacity(0.5);
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Characteristic'),
                Text(
                  '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
                  //'0x${characteristic.uuid.toString().toUpperCase()}',
                  style: _buildStyle(context),
                )
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: iconColor,
                ),
                onPressed: onReadPressed,
              ),
              IconButton(
                icon: Icon(
                  Icons.file_upload,
                  color: iconColor,
                ),
                onPressed: onWritePressed,
              ),
              IconButton(
                icon: Icon(
                  characteristic.isNotifying ? Icons.sync_disabled : Icons.sync,
                  color: iconColor,
                ),
                onPressed: onNotificationPressed,
              )
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
  }

  TextStyle _buildStyle(BuildContext context) {
    return Theme.of(context).textTheme.body1.copyWith(
          color: Theme.of(context).textTheme.caption.color,
        );
  }
}
