enum Gender {
  Male,
  Female,
}

class UserModel {
  String Id;
  String FirstName;
  String LastName;
  String Username;
  String ProfilePictureUrl;
  String Email;
  int Age;
  Gender UserGender;
  List<String> Friends = const [];

  UserModel({
    required this.Id,
    required this.Username,
    required this.ProfilePictureUrl,
    required this.Age,
    required this.UserGender,
    required this.FirstName,
    required this.LastName,
    required this.Email
  });
}