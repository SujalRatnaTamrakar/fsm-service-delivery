import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StylesOption extends StatefulWidget {
  final Function onPressed;
  final String optionName;
  final DecorationImage image;
  final ValueListenable color;
  StylesOption(
      {@required this.onPressed, this.optionName, this.image, this.color});
  @override
  _StylesOptionState createState() => _StylesOptionState(
      onPressed: onPressed, optionName: optionName, image: image, color: color);
}

class _StylesOptionState extends State<StylesOption> {
  final Function onPressed;
  final String optionName;
  final DecorationImage image;
  final ValueListenable color;
  _StylesOptionState(
      {this.optionName, @required this.onPressed, this.image, this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.black,
                  image: image,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: color.value,
                    width: 3.0,
                  ) // button text
                  )),
          onTap: onPressed,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            optionName,
            style: TextStyle(fontSize: 15.0),
          ),
        ),
      ],
    );
  }
}
