import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DescriptorTile extends StatelessWidget {
  const DescriptorTile({
    Key key,
    this.descriptor,
    this.onReadPressed,
    this.onWritePressed,
  }) : super(key: key);

  final BluetoothDescriptor descriptor;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).iconTheme.color.withOpacity(0.5);
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text(
            '0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
            style: _buildTextStyle(context),
          )
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) =>
            Text(snapshot.data.toString()),
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
          )
        ],
      ),
    );
  }

  TextStyle _buildTextStyle(BuildContext context) {
    return Theme.of(context)
        .textTheme
        .body1
        .copyWith(color: Theme.of(context).textTheme.caption.color);
  }
}
