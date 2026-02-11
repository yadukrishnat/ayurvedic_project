import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign? align;

  const AppText(
      this.text, {
        this.size = 14,
        this.weight = FontWeight.normal,
        this.color = Colors.black,
        this.align,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
      ),
    );
  }
}
