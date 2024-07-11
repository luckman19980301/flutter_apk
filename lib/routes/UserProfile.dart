import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet_chat/components/AppHeader.dart';
import 'package:meet_chat/components/BottomAppBarComponent.dart';
import 'package:meet_chat/components/ErrorMessageWidget.dart';
import 'package:meet_chat/components/UploadPhotosWidget.dart';
import 'package:meet_chat/core/globals.dart';
import 'package:meet_chat/core/models/UserModel.dart';
import 'package:meet_chat/core/services/DatabaseService.dart';
import 'package:meet_chat/core/services/StorageService.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure to include FirebaseAuth package

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
  List<String> userPhotos = [];
  bool isSelectionMode = false;
  Set<String> selectedPhotos = Set<String>();
  String selectionError = '';

  final IDatabaseService _databaseService = INJECTOR<IDatabaseService>();
  final IStorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final databaseResponse = await _databaseService.getUser(widget.userId);
      if (databaseResponse.success == true) {
        final photosResponse = await _storageService.getUserPhotos(widget.userId);
        if (photosResponse.success == true) {
          setState(() {
            user = databaseResponse.data;
            userPhotos = photosResponse.data ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = photosResponse.message ?? "Error loading user photos";
            isLoading = false;
          });
        }
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

  Future<void> _refreshPhotos() async {
    try {
      final photosResponse = await _storageService.getUserPhotos(widget.userId);
      if (photosResponse.success == true) {
        setState(() {
          userPhotos = photosResponse.data ?? [];
          selectedPhotos.clear();
        });
      } else {
        setState(() {
          errorMessage = photosResponse.message ?? "Error loading user photos";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading user photos: $e";
      });
    }
  }

  Future<void> _deleteSelectedPhotos() async {
    try {
      for (String photoUrl in selectedPhotos) {
        await _storageService.deleteFile(photoUrl);
      }
      _refreshPhotos();
      setState(() {
        isSelectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected photos deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting photos: $e')),
      );
    }
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedPhotos.clear();
    });
  }

  Future<void> _changeProfilePicture() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Select from uploaded photos'),
              onTap: () {
                Navigator.pop(context);
                _showSelectProfilePictureDialog();
              },
            ),
            ListTile(
              title: Text('Upload new photo'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final File file = File(pickedFile.path);
                  final uploadResponse = await _storageService.uploadFile(file, widget.userId,
                      DateTime.now().millisecondsSinceEpoch.toString());
                  if (uploadResponse.success == true) {
                    final updateResponse = await _databaseService.updateProfilePicture(widget.userId, uploadResponse.data!);
                    if (updateResponse.success == true) {
                      await FIREBASE_INSTANCE.currentUser?.updatePhotoURL(uploadResponse.data!); // Update Firebase profile picture URL
                      setState(() {
                        user!.ProfilePictureUrl = uploadResponse.data!;
                      });
                      await _refreshPhotos(); // Refresh photos after successful profile picture upload
                    } else {
                      setState(() {
                        errorMessage = updateResponse.message ?? "Error updating profile picture";
                      });
                    }
                  } else {
                    setState(() {
                      errorMessage = uploadResponse.message ?? "Error uploading profile picture";
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSelectProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Profile Picture'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: userPhotos.length,
              itemBuilder: (context, index) {
                final photoUrl = userPhotos[index];
                return GestureDetector(
                  onTap: () async {
                    final updateResponse = await _databaseService.updateProfilePicture(widget.userId, photoUrl);
                    if (updateResponse.success == true) {
                      await FIREBASE_INSTANCE.currentUser?.updatePhotoURL(photoUrl); // Update Firebase profile picture URL
                      setState(() {
                        user!.ProfilePictureUrl = photoUrl;
                      });
                      Navigator.pop(context);
                      await _refreshPhotos(); // Refresh photos after successful profile picture update
                    } else {
                      setState(() {
                        errorMessage = updateResponse.message ?? "Error updating profile picture";
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: "${user?.Username}'s Profile",
      ),
      body: Container(
        color: const Color(0xFFF0F0F0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : Column(
          children: [
            if (selectionError.isNotEmpty)
              ErrorMessageWidget(
                message: selectionError,
                type: MessageType.error,
                canClose: true,
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildCard(_buildUserInfo(), "User Info"),
                    _buildCard(_buildAdditionalInfo(), "About Me"),
                    _buildCard(_buildPhotoGallery(), "Photos"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBarComponent(
        buttons: [
          buildIconButton(
            icon: Icons.home,
            startColor: const Color.fromRGBO(43, 217, 254, 1.0),
            endColor: Colors.lightBlueAccent,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          buildIconButton(
            icon: Icons.person_add,
            startColor: const Color(0xFFFF5F6D),
            endColor: Colors.pinkAccent,
            onPressed: () {
              // Add friend request logic here
            },
          ),
          buildIconButton(
            icon: Icons.message,
            startColor: Colors.red,
            endColor: Colors.deepOrange,
            onPressed: () {
              // Redirect to messages page
            },
          ),
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
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${user!.Username}, ${user!.calculateAge() ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 30),
              onPressed: _changeProfilePicture,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Widget content, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  if (isSelectionMode && title == "Photos")
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.pinkAccent),
                      onPressed: _exitSelectionMode,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user!.FirstName != null && user!.LastName != null)
          _buildUserInfoRow(Icons.person, "Name: ${user!.FirstName} ${user!.LastName}"),
        if (user!.PhoneNumber != null)
          _buildUserInfoRow(Icons.phone, "Phone: ${user!.PhoneNumber}"),
        _buildUserInfoRow(Icons.email, "Email: ${user!.Email}"),
        _buildUserInfoRow(Icons.cake, "Age: ${user!.calculateAge() ?? ''}"),
        if (user!.DateOfBirth != null)
          _buildUserInfoRow(Icons.calendar_today, "Date of Birth: ${_formatDate(user!.DateOfBirth!)}"),
      ],
    );
  }

  Widget _buildUserInfoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pinkAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        user!.AboutMe ?? "No additional information",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: userPhotos.length + 1,
          itemBuilder: (context, index) {
            if (index == userPhotos.length) {
              return GestureDetector(
                onTap: () async {
                  UploadPhotosWidget(
                    userId: widget.userId,
                    onUploadComplete: _refreshPhotos,
                  ).pickAndUploadImages(context);
                },
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 50,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
              );
            }
            final photoUrl = userPhotos[index];
            final isSelected = selectedPhotos.contains(photoUrl);
            return GestureDetector(
              onTap: () {
                if (isSelectionMode) {
                  setState(() {
                    if (photoUrl == user!.ProfilePictureUrl) {
                      selectionError = "Profile picture cannot be deleted.";
                    } else {
                      selectionError = '';
                      if (isSelected) {
                        selectedPhotos.remove(photoUrl);
                      } else {
                        selectedPhotos.add(photoUrl);
                      }
                    }
                  });
                } else {
                  _showPhotoDialog(photoUrl);
                }
              },
              onLongPress: () {
                if (photoUrl != user!.ProfilePictureUrl) {
                  setState(() {
                    isSelectionMode = true;
                    selectedPhotos.add(photoUrl);
                  });
                } else {
                  setState(() {
                    selectionError = "Profile picture cannot be deleted.";
                  });
                }
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isSelectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: Colors.pinkAccent,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (isSelectionMode)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedPhotos.isEmpty ? null : _deleteSelectedPhotos,
              child: Text('Delete Selected Photos'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
              ),
            ),
          ),
      ],
    );
  }

  void _showPhotoDialog(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}
