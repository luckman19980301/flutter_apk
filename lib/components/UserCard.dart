
import 'package:flutter/material.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/routes/UserProfile.dart';

class UserCard extends StatelessWidget {
  const UserCard({Key? key, required this.user}) : super(key: key);

  final UserModel user;

  Color backgroundImageColor() {
    return user.UserGender == Gender.Male ? Colors.blueAccent : Colors.pinkAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, UserProfile.route, arguments: user.Id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(user.ProfilePictureUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            user.Username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (user.Age != null)
                    Text(
                      '${user.Age} years',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  Icon(
                    Icons.favorite,
                    color: user.UserGender == Gender.Male ? Colors.blueAccent : Colors.pinkAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
