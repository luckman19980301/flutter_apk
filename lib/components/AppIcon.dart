import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.size,
    this.title = 'Timber',
    this.color = Colors.white,
    this.horizontal = false,
  });

  final double size;
  final String title;
  final Color color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'appLogo',
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: horizontal
            ? Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.tree,
              size: size,
              color: color,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: size * 0.4,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.tree,
              size: size,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: size * 0.4,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
