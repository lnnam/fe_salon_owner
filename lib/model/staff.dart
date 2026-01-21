class Staff {
  int staffkey;
  String fullname;
  String position;
  String photo;
  bool active;
  String? datelastactivated;

  Staff({
    required this.staffkey,
    required this.fullname,
    required this.position,
    required this.photo,
    this.datelastactivated,
    bool? active,
  }) : active = active ?? (datelastactivated == null);

  factory Staff.fromJson(Map<String, dynamic> json) {
    final datelastactivated = json['datelastactivated'];
    return Staff(
      staffkey: json['pkey'] ?? 0,
      fullname: json['fullname'] ?? 'Unknown',
      position: json['position'] ?? 'Unknown',
      photo: json['photobase64'] != null && json['photobase64'] != ''
          ? json['photobase64']
          : 'Unknown',
      datelastactivated: datelastactivated,
      active: datelastactivated == null ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffkey': staffkey,
      'fullname': fullname,
      'position': position,
      'photo': photo,
      'active': active,
      'datelastactivated': datelastactivated,
    };
  }
}
