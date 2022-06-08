class UserModel {
  String? uid;
  String? username;
  String? phone;

  UserModel({this.uid, this.phone, this.username});

  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      phone: map['phone'],
      username: map['username'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'username': username,
    };
  }
}
