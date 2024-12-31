class Customer {
  int customerkey;
  String fullname;
  String email;
  String phone;

  Customer({
    required this.customerkey,
    required this.fullname,
    required this.email,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerkey: json['customerkey'] ?? 0,
      fullname: json['fullname'] ?? 'Unknown',
      email: json['email'] ?? 'Unknown',
      phone: json['phone'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerkey': customerkey,
      'fullname': fullname,
      'email': email,
      'phone': phone,
    };
  }
}