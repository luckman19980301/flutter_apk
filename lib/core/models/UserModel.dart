import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, Timestamp;

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
  String? AboutMe;
  Gender UserGender;
  int? PhoneNumber;
  List<String>? Friends;
  DateTime? DateOfBirth;
  int? Age;

  // Add a DocumentSnapshot field to store the original document snapshot
  final DocumentSnapshot? documentSnapshot;

  UserModel({
    required this.Id,
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
    this.Age,
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
      Age: data['age'],
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
      'age': Age,
    };
  }

  static String _genderToString(Gender gender) {
    return gender == Gender.Male ? 'Male' : 'Female';
  }

  static Gender _genderFromString(String gender) {
    return gender == 'Male' ? Gender.Male : Gender.Female;
  }

  void calculateAge() {
    if (DateOfBirth != null) {
      DateTime today = DateTime.now();
      int age = today.year - DateOfBirth!.year;
      if (today.month < DateOfBirth!.month || (today.month == DateOfBirth!.month && today.day < DateOfBirth!.day)) {
        age--;
      }
      Age = age;
    }
  }
}
