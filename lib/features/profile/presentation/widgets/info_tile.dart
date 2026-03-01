import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const InfoTile(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), subtitle: Text(value));
  }
}
