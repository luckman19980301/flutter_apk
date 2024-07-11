import 'package:flutter/material.dart';

class BottomAppBarComponent extends StatelessWidget {
  final List<Widget> buttons;

  const BottomAppBarComponent({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF5F6D), Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent, // Make the BottomAppBar transparent to show the gradient
        shape: const CircularNotchedRectangle(),
        notchMargin: 5, // Adjusted margin for better spacing
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: buttons,
        ),
      ),
    );
  }
}

Widget buildIconButton({
  required IconData icon,
  required Color startColor,
  required Color endColor,
  required VoidCallback? onPressed,
}) {
  return Material(
    elevation: 10,
    shadowColor: Colors.black45,
    shape: const CircleBorder(),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        disabledColor: Colors.grey, // Change color for disabled state
      ),
    ),
  );
}