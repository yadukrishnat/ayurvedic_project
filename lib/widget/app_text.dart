import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? size;         // optional
  final FontWeight? weight;   // optional
  final Color? color;         // optional
  final TextAlign? align;     // optional
  final double? height;       // optional line height

  const AppText(
      this.text, {
        this.size,
        this.weight,
        this.color,
        this.align,
        this.height,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: size ?? 14,               // default size if not provided
        fontWeight: weight ?? FontWeight.normal, // default weight
        color: color ?? Colors.black,       // default color
        height: height,                     // optional line height
      ),
    );
  }
}
