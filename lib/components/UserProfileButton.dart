
import 'package:flutter/material.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/routes/UserProfile.dart';

class UserProfileButton extends StatelessWidget {
  const UserProfileButton(
      {Key? key,
        required this.user,
        this.backgroundColor,
        this.isCurrentUser = false})
      : super(key: key);

  final UserModel user;
  final Color? backgroundColor;
  final bool isCurrentUser;

  Color backgroundImageColor() {
    return user.UserGender == Gender.Male
        ? Colors.blueAccent
        : Colors.pinkAccent;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, UserProfile.route, arguments: user.Id);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    blurRadius: 10,
                    color: backgroundImageColor(),
                    spreadRadius: 1)
              ],
            ),
            child: CircleAvatar(
              radius: 30.0,
              backgroundImage: NetworkImage(user.ProfilePictureUrl),
            ),
          ),
          Text(
            user.Username,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
