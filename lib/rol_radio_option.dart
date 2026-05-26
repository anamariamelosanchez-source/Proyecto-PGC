import 'package:flutter/material.dart';

class RolRadioOption extends StatelessWidget {
  final String label;
  final int value;

  const RolRadioOption({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<int>(title: Text(label), value: value);
  }
}
