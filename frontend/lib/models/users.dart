class User {
  final int idUser;
  final String name;
  final String lastname;
  final String username;
  final String? email;
  final String? phone;
  final String? profilePicture;
  final String? description;
  final bool privateProfile;
  final int fointsSeason;
  final int fointsTotal;
  final int idRole;
  final String createdAt;
  final bool active;

  User({
    required this.idUser,
    required this.name,
    required this.lastname,
    required this.username,
    this.email,
    this.phone,
    this.profilePicture,
    this.description,
    required this.privateProfile,
    required this.fointsSeason,
    required this.fointsTotal,
    required this.idRole,
    required this.createdAt,
    required this.active,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser:         json['id_user'],
      name:           json['name'],
      lastname:       json['lastname'],
      username:       json['username'],
      email:          json['email'],
      phone:          json['phone'],
      profilePicture: json['profile_picture'],
      description:    json['description'],
      privateProfile: json['private_profile'],
      fointsSeason:   json['foints_season'],
      fointsTotal:    json['foints_total'],
      idRole:         json['id_role'],
      createdAt:      json['created_at'],
      active:         json['active'],
    );
  }

  String get fullName => '$name $lastname';
}