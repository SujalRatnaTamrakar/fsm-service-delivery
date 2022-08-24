import 'package:flutter/material.dart';

class MyFormField extends StatelessWidget {
  final String fieldLabel;
  final widget;

  MyFormField({this.fieldLabel, this.widget});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.0,
        ),
        Text(
          '$fieldLabel',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(
          height: 20.0,
        ),
        widget,
      ],
    );
  }
}
