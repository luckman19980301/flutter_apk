import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;

enum Gender {
  Male,
  Female,
}

class UserModel {
  String Id;
  String? FirstName;
  String? LastName;
  String Username;
  String ProfilePictureUrl;
  String Email;
  int? Age;
  Gender UserGender;
  int? PhoneNumber;
  List<String>? Friends;

  // Add a DocumentSnapshot field to store the original document snapshot
  final DocumentSnapshot? documentSnapshot;

  UserModel({
    required this.Id,
    required this.Username,
    required this.ProfilePictureUrl,
    this.Age,
    required this.UserGender,
    this.FirstName,
    this.LastName,
    required this.Email,
    this.PhoneNumber,
    this.Friends = const [],
    this.documentSnapshot,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      Id: doc.id,
      FirstName: data['firstName'],
      LastName: data['lastName'],
      Username: data['username'],
      ProfilePictureUrl: data['profilePictureUrl'],
      Email: data['email'],
      Age: data['age'],
      UserGender: _genderFromString(data['gender']),
      PhoneNumber: data['phoneNumber'],
      Friends: List<String>.from(data['friends'] ?? []),
      documentSnapshot: doc,  // Store the original document snapshot
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': Id,
      'FirstName': FirstName,
      'LastName': LastName,
      'Username': Username,
      'ProfilePictureUrl': ProfilePictureUrl,
      'Email': Email,
      'Age': Age,
      'UserGender': _genderToString(UserGender),
      'PhoneNumber': PhoneNumber,
      'Friends': Friends,
    };
  }

  static String _genderToString(Gender gender) {
    return gender == Gender.Male ? 'Male' : 'Female';
  }

  static Gender _genderFromString(String gender) {
    return gender == 'Male' ? Gender.Male : Gender.Female;
  }
}
