class Setting {
  final String salonName;
  final String sms;
  final String email;

  Setting({
    required this.salonName,
    required this.sms,
    required this.email,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      salonName: json['salon_name'] as String? ?? '',
      sms: json['sms'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'salonName': salonName,
      'sms': sms,
      'email': email,
    };
  }

  Setting copyWith({
    String? salonName,
    String? sms,
    String? email,
  }) {
    return Setting(
      salonName: salonName ?? this.salonName,
      sms: sms ?? this.sms,
      email: email ?? this.email,
    );
  }
}
