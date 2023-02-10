// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.black, thickness: 1);
  }
}
