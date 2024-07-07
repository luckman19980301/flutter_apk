import 'package:flutter/material.dart';

enum MessageType { error, info, warning }

class ErrorMessageWidget extends StatelessWidget {
  final String message;
  final MessageType type;

  const ErrorMessageWidget({super.key, required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    Color _getBackgroundColor() {
      switch (type) {
        case MessageType.error:
          return Colors.redAccent;
        case MessageType.info:
          return Colors.blueAccent;
        case MessageType.warning:
          return Colors.orangeAccent;
        default:
          return Colors.grey;
      }
    }

    IconData _getIconData() {
      switch (type) {
        case MessageType.error:
          return Icons.error_outline;
        case MessageType.info:
          return Icons.info_outline;
        case MessageType.warning:
          return Icons.warning_amber_outlined;
        default:
          return Icons.info_outline;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getIconData(),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
