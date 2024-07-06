import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';

class UserProfile extends StatefulWidget {
  static const String route = "profile";

  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  UserModel? user;
  bool isLoading = true;
  String errorMessage = '';

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final databaseResponse = await _databaseService.getUser(widget.userId);
      if (databaseResponse.success == true) {
        setState(() {
          user = databaseResponse.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = databaseResponse.message ?? "Error loading user data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading user data: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: "${user?.Username}'s Profile",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildDivider(),
                  _buildUserInfo(),
                  _buildDivider(),
                  _buildAdditionalInfo(),
                  _buildDivider(),
                  _buildPhotoGallery(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(user!.ProfilePictureUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${user!.Username}, ${user!.Age ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 1,
      color: Colors.pinkAccent,
      height: 40,
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user!.FirstName != null && user!.LastName != null)
            _buildUserInfoRow(Icons.person, "Name: ${user!.FirstName} ${user!.LastName}"),
          if (user!.PhoneNumber != null)
            _buildUserInfoRow(Icons.phone, "Phone: ${user!.PhoneNumber}"),
          _buildUserInfoRow(Icons.email, "Email: ${user!.Email}"),
          _buildUserInfoRow(Icons.cake, "Age: ${user!.Age ?? ''}"),
          if (user!.DateOfBirth != null)
            _buildUserInfoRow(Icons.calendar_today, "Date of Birth: ${_formatDate(user!.DateOfBirth!)}"),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pinkAccent),
          const SizedBox(width: 10),
          Text(
            info,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About Me",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user!.AboutMe ?? "No additional information",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    final List<String> photos = [
      user!.ProfilePictureUrl,
      // Add more photo URLs here
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Photos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _showPhotoDialog(photos[index]);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photos[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPhotoDialog(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(photoUrl),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFooterButton(
            icon: Icons.close,
            color: Colors.redAccent,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          _buildFooterButton(
            icon: Icons.person_add,
            color: Colors.blueAccent,
            onPressed: () {
              // Add friend request logic here
            },
          ),
          _buildFooterButton(
            icon: Icons.message,
            color: Colors.greenAccent,
            onPressed: () {
              // Redirect to messages page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Material(
      elevation: 5,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(15),
          elevation: 5,
          shadowColor: Colors.black26,
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}
