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
    // Check for 'type' field from database (type = 1 means VIP)
    // Handle both string and int types from API
    int vipStatus = 0;

    if (json['type'] != null) {
      if (json['type'] is String) {
        vipStatus = int.tryParse(json['type']) ?? 0;
      } else if (json['type'] is int) {
        vipStatus = json['type'] as int;
      }
    } else if (json['isvip'] != null) {
      if (json['isvip'] is String) {
        vipStatus = int.tryParse(json['isvip']) ?? 0;
      } else if (json['isvip'] is int) {
        vipStatus = json['isvip'] as int;
      }
    }

    // Safely parse customerkey - handle both int and string
    int customerKey = 0;
    if (json['pkey'] != null) {
      if (json['pkey'] is int) {
        customerKey = json['pkey'] as int;
      } else if (json['pkey'] is String) {
        customerKey = int.tryParse(json['pkey']) ?? 0;
      }
    }

    return Customer(
      customerkey: customerKey,
      fullname: json['fullname']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? 'Unknown',
      photo: json['photobase64'] != null && json['photobase64'] != ''
          ? json['photobase64'].toString()
          : 'Unknown',
      birthday: (json['dob']?.toString() ?? json['birthday']?.toString() ?? ''),
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
