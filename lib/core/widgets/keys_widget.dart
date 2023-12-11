import 'package:cursova/core/rsa/rsa_key_pair.dart';
import 'package:flutter/material.dart';

class KeysWidget extends StatefulWidget {
  const KeysWidget({super.key, required this.keys});
  final RSAKeyPair keys;

  @override
  State<KeysWidget> createState() => _KeysWidgetState();
}

class _KeysWidgetState extends State<KeysWidget> {
  bool _canSeeKeys = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: double.maxFinite,
        ),
        TextButton(
          onPressed: () {
            _canSeeKeys = !_canSeeKeys;
            setState(() {});
          },
          child: Text(_canSeeKeys ? 'Hide keys' : 'Show keys'),
        ),
        if (_canSeeKeys) const Text('Public keys'),
        if (_canSeeKeys)
          Text(
            widget.keys.publicKey.toString(),
          )
      ],
    );
  }
}
