import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, Timestamp;

enum Gender {
  Male,
  Female,
}

class UserModel {
  String? Id;
  String? FirstName;
  String? LastName;
  String Username;
  String ProfilePictureUrl;
  String Email;
  String? AboutMe;
  Gender UserGender;
  String? PhoneNumber;
  List<String>? Friends;
  DateTime? DateOfBirth;

  final DocumentSnapshot? documentSnapshot;

  UserModel({
    this.Id,
    required this.Username,
    required this.ProfilePictureUrl,
    required this.UserGender,
    required this.Email,
    this.FirstName,
    this.LastName,
    this.PhoneNumber,
    this.Friends = const [],
    this.documentSnapshot,
    this.AboutMe,
    this.DateOfBirth,
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
      AboutMe: data['aboutMe'],
      UserGender: _genderFromString(data['gender']),
      PhoneNumber: data['phoneNumber'],
      Friends: List<String>.from(data['friends'] ?? []),
      documentSnapshot: doc,  // Store the original document snapshot
      DateOfBirth: (data['dateOfBirth'] != null) ? (data['dateOfBirth'] as Timestamp).toDate() : null,
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
      'UserGender': _genderToString(UserGender),
      'PhoneNumber': PhoneNumber,
      'Friends': Friends,
      'AboutMe': AboutMe,
      'DateOfBirth': DateOfBirth != null ? Timestamp.fromDate(DateOfBirth!) : null,
    };
  }

  static String _genderToString(Gender gender) {
    return gender == Gender.Male ? 'Male' : 'Female';
  }

  static Gender _genderFromString(String gender) {
    return gender == 'Male' ? Gender.Male : Gender.Female;
  }

  int? calculateAge() {
    if (this.DateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - this.DateOfBirth!.year;
    if (now.month < this.DateOfBirth!.month || (now.month == this.DateOfBirth!.month && now.day < this.DateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}
