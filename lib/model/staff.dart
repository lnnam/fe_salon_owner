class Staff {
  String fullname;
  String position;
  String photo;

  Staff({
    required this.fullname,
    required this.position,
    required this.photo,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      fullname: json['fullname'] ?? 'Unknown',
      position: json['position'] ?? 'Unknown',
      //photo: json['photobase64'] ?? 'Unknown',
      photo: json['photobase64'] != null && json['photobase64'] != '' ? json['photobase64'] : 'Unknown',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'position': position,
      'photo': photo,
    };
  }
}
