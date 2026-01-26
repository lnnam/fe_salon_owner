class Customer {
  int customerkey;
  String fullname;
  String email;
  String phone;
  String photo;
  String birthday;
  int isvip;

  Customer({
    required this.customerkey,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.photo,
    this.birthday = '',
    this.isvip = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] Customer.fromJson input: $json');
    // Check for 'type' field from database (type = 1 means VIP)
    // Handle both string and int types from API
    int vipStatus = 0;

    if (json['type'] != null) {
      if (json['type'] is String) {
        vipStatus = int.tryParse(json['type']) ?? 0;
      } else {
        vipStatus = json['type'] as int;
      }
    } else if (json['isvip'] != null) {
      if (json['isvip'] is String) {
        vipStatus = int.tryParse(json['isvip']) ?? 0;
      } else {
        vipStatus = json['isvip'] as int;
      }
    }

    return Customer(
      customerkey: json['pkey'] ?? 0,
      fullname: json['fullname'] ?? 'Unknown',
      email: json['email'] ?? 'Unknown',
      phone: json['phone'] ?? 'Unknown',
      photo: json['photobase64'] != null && json['photobase64'] != ''
          ? json['photobase64']
          : 'Unknown',
      birthday: json['dob'] ?? json['birthday'] ?? '',
      isvip: vipStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerkey': customerkey,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'photo': photo,
      'dob': birthday,
      'isvip': isvip,
    };
  }
}
