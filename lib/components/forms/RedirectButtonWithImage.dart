import 'package:flutter/material.dart';

class RedirectButtonWithImage extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onPressed;
  final double size;

  const RedirectButtonWithImage({
    Key? key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.size = 24.0,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white24,
      ),
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, color: Colors.white, size: size),
            onPressed: onPressed,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
