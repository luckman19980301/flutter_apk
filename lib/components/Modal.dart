import 'package:flutter/material.dart';

class Modal extends StatefulWidget {
  const Modal({super.key, required this.icon, required this.buttonTitle});

  final IconData icon;
  final String buttonTitle;

  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  void _showInfoModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Information'),
          content: const Text(
              'This is a chat application where you can sign in or create a new account to start chatting with your friends.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _showInfoModal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Icon(
              widget.icon,
              size: 20.0,
              color: Colors.white,
            ),
          ),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(widget.buttonTitle))
        ],
      ),
    );
  }
}
