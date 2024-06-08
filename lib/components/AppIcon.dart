import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show BuildContext, Colors, Column, EdgeInsets, Icon, MainAxisAlignment, MainAxisSize, Padding, StatelessWidget, Widget;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'appLogo',
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          FontAwesomeIcons.peopleGroup,
          size: size,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
