class Setting {
  final String salonName;
  final String sms_pending;
  final String sms_confirm;
  final String email;

  Setting({
    required this.salonName,
    required this.sms_pending,
    required this.sms_confirm,
    required this.email,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      salonName: json['salon_name'] as String? ?? '',
      sms_pending: json['sms_pending'] as String? ?? '',
      sms_confirm: json['sms_confirm'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salonName': salonName,
      'sms_pending': sms_pending,
      'sms_confirm': sms_confirm,
      'email': email,
    };
  }

  Setting copyWith({
    String? salonName,
    String? sms_pending,
    String? sms_confirm,
    String? email,
  }) {
    return Setting(
      salonName: salonName ?? this.salonName,
      sms_pending: sms_pending ?? this.sms_pending,
      sms_confirm: sms_confirm ?? this.sms_confirm,
      email: email ?? this.email,
    );
  }
}
