import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class BouncingDVD extends StatefulWidget {
  final String text;

  final double height;
  final double width;

  const BouncingDVD({
    super.key,
    required this.text,
    required this.height,
    required this.width,
  });

  @override
  State<BouncingDVD> createState() => _BouncingDVDState();
}

class _BouncingDVDState extends State<BouncingDVD> {
  Random random = Random();
  Color? dvdColor;
  late double dvdWidth, dvdHeight;
  double x = 90, y = 30, xSpeed = 50, ySpeed = 50, speed = 150;

  pickColor() {
    Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      ColorScheme scheme = Theme.of(context).colorScheme;
      List<Color> colors = [
        scheme.primary,
        scheme.onSurface,
      ];

      var tmp = colors[random.nextInt(colors.length)];
      while (tmp == dvdColor) {
        tmp = colors[random.nextInt(colors.length)];
      }

      dvdColor = tmp;
    });
  }

  @override
  initState() {
    super.initState();

    Size textSize = _textSize(widget.text, const TextStyle(fontSize: 20));
    dvdWidth = textSize.width;
    dvdHeight = textSize.height;

    pickColor();
    update();
  }

  update() {
    Timer.periodic(Duration(milliseconds: speed.toInt()), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      double screenWidth = widget.width;
      double screenHeight = widget.height;
      x += xSpeed;
      y += ySpeed;

      if (x + dvdWidth >= screenWidth) {
        xSpeed = -xSpeed;
        x = screenWidth - dvdWidth;
        pickColor();
      } else if (x <= 0) {
        xSpeed = -xSpeed;
        x = 0;
        pickColor();
      }

      if (y + dvdHeight >= screenHeight) {
        ySpeed = -ySpeed;
        y = screenHeight - dvdHeight;
        pickColor();
      } else if (y <= 0) {
        ySpeed = -ySpeed;
        y = 0;
        pickColor();
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: speed.toInt()),
          left: x,
          top: y,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: dvdColor,
            ),
          ),
        ),
      ],
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );
    return textPainter.size;
  }
}
