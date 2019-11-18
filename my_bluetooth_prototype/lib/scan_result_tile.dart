import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// A Display-Tile for a Bluetooth-Device that HAS NOT been
/// previously Connected to the app.
class ScanResultTile extends StatelessWidget {
  const ScanResultTile({
    Key key,
    this.result,
    this.onTap,
  }) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              value,
              style: _buildTextStyle(context),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _buildTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.caption.apply(color: Colors.black);
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((int i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = <String>[];
    data.forEach(
      (int id, List<int> bytes) {
        res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}',
        );
      },
    );
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = <String>[];
    data.forEach(
      (String id, List<int> bytes) {
        res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
      },
    );
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: RaisedButton(
        child: const Text('CONNECT'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: (result.advertisementData.connectable) ? onTap : null,
      ),
      children: <Widget>[
        _buildAdvRow(
          context,
          'Complete Local Name',
          result.advertisementData.localName,
        ),
        _buildAdvRow(
          context,
          'Tx Power Level',
          '${result.advertisementData.txPowerLevel ?? 'N/A'}',
        ),
        _buildAdvRow(
          context,
          'Manufacturer Data',
          getNiceManufacturerData(result.advertisementData.manufacturerData) ??
              'N/A',
        ),
        _buildAdvRow(
          context,
          'Service UUIDs',
          (result.advertisementData.serviceUuids.isNotEmpty)
              ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
              : 'N/A',
        ),
        _buildAdvRow(
          context,
          'Service Data',
          getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A',
        ),
      ],
    );
  }
}
