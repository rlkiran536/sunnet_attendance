class LogModel {
  String? uid;
  String? username;
  String? phone;
  double? lat;
  double? long;
  DateTime? time;
  String? address;

  LogModel(
      {this.uid,
      this.phone,
      this.username,
      this.lat,
      this.long,
      this.time,
      this.address});

  factory LogModel.fromMap(map) {
    return LogModel(
        uid: map['uid'],
        phone: map['phone'],
        username: map['username'],
        lat: map['lat'],
        long: map['long'],
        time: map['time'],
        address: map['address']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'username': username,
      'lat': lat,
      'long': long,
      'time': time,
      'address': address,
    };
  }
}
