import 'package:intl/intl.dart';

class Booking {
  final int pkey; // <-- Add this line as int
  final String customerkey;
  final String customername;
  final String customerphone;
  final String customeremail;
  final DateTime datetimebooking;
  final String staffkey;
  final String staffname;
  final String servicename;
  final String servicekey;
  final String numbooked;
  final String customertype;
  final DateTime created_datetime;
  final String bookingdate;
  final DateTime bookingtime;
  final DateTime bookingstart;
  final String customerphoto;
  final String note;
  final String? createdby;
  final String status;

  Booking({
    required this.pkey, // <-- Add this line
    required this.customerkey,
    required this.customername,
    required this.customerphone,
    required this.customeremail,
    required this.datetimebooking,
    required this.staffkey,
    required this.staffname,
    required this.servicename,
    required this.servicekey,
    required this.numbooked,
    required this.customertype,
    required this.created_datetime,
    required this.bookingstart,
    required this.bookingdate,
    required this.bookingtime,
    required this.customerphoto,
    required this.note,
    this.createdby,
    this.status = '',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime bookingDateTime;
    String formattedBookingDate = '';

    // Use 'bookingstart' if available, otherwise use 'date' field
    if (json['bookingstart'] != null && json['bookingstart'] != '') {
      bookingDateTime = DateTime.parse(json['bookingstart']);
      formattedBookingDate = DateFormat('yyyy-MM-dd').format(bookingDateTime);
    } else if (json['date'] != null && json['date'] != '') {
      // Use the 'date' field from server
      formattedBookingDate = json['date'];
      bookingDateTime = DateTime.parse('${formattedBookingDate}T00:00:00.000Z');
    } else if (json['dateactivated'] != null && json['dateactivated'] != '') {
      bookingDateTime = DateTime.parse(json['dateactivated']);
      formattedBookingDate = DateFormat('yyyy-MM-dd').format(bookingDateTime);
    } else {
      bookingDateTime = DateTime.now();
      formattedBookingDate = DateFormat('yyyy-MM-dd').format(bookingDateTime);
    }

    DateTime createdDateTime =
        json['dateactivated'] != null && json['dateactivated'] != ''
            ? DateTime.parse(json['dateactivated'])
            : DateTime.now();

    final String parsedPhone = json['customerphone']?.toString() ?? '';
    final String parsedEmail = json['customeremail']?.toString() ?? '';

    return Booking(
      pkey: json['pkey'] is int
          ? json['pkey']
          : int.tryParse(json['pkey']?.toString() ?? '') ??
              0, // <-- Parse as int
      customername: json['customername'] ?? 'Unknown',
      customerkey: json['customerkey']?.toString() ?? 'Unknown',
      customerphone: parsedPhone,
      customeremail: parsedEmail,
      staffkey: json['staffkey']?.toString() ?? 'Unknown',
      datetimebooking: bookingDateTime,
      staffname: json['staffname'] ?? 'N/A',
      servicename: json['servicename'] ?? 'N/A',
      servicekey: json['servicekey']?.toString() ?? 'Unknown',
      numbooked: (() {
        final dynamic v = json['numbooking'] ??
            json['num_booked'] ??
            json['numbooking'] ??
            json['num'];
        final s = v?.toString() ?? '';
        return s.isEmpty ? '1' : s;
      })(),
      customertype: json['customertype'] ?? 'N/A',
      created_datetime: createdDateTime,
      bookingdate: formattedBookingDate,
      bookingtime: bookingDateTime,
      bookingstart: json['bookingstart'] != null && json['bookingstart'] != ''
          ? DateTime.parse(json['bookingstart'])
          : DateTime.now(),
      customerphoto: json['photobase64'] != null && json['photobase64'] != ''
          ? json['photobase64']
          : 'Unknown',
      note: json['note'] ?? '',
      createdby: json['createdby'],
      status: json['status'] ??
          json['bookingstatus'] ??
          json['statusbooking'] ??
          (json['statuskey'] != null ? json['statuskey'].toString() : ''),
    );
  }

  /// Friendly display label for status values returned by backend.
  /// Maps numeric codes and common keywords to human-readable labels.
  String get displayStatus {
    final s = status.trim().toLowerCase();
    if (s.isEmpty) return 'Unknown';

    // Numeric codes commonly used by some backends
    if (s == '0' || s == '1' || s.contains('pending') || s.contains('wait')) {
      return 'Pending';
    }
    if (s == '2' ||
        s.contains('confirm') ||
        s.contains('booked') ||
        s.contains('confirmed')) {
      return 'Confirmed';
    }
    if (s == '3' || s.contains('cancel') || s.contains('void')) {
      return 'Cancelled';
    }
    if (s == '4' || s.contains('done') || s.contains('completed')) {
      return 'Completed';
    }

    // Fallback: return original (but nicely cased)
    return status;
  }
}

class OnBooking {
  Map<String, dynamic>? staff;
  Map<String, dynamic>? customer;
  Map<String, dynamic>? service;
  Map<String, dynamic>? schedule;
  bool editMode;
  String note;
  int bookingkey;

  OnBooking({
    this.staff,
    this.customer,
    this.service,
    this.schedule,
    this.editMode = false, // default to false
    this.note = '',
    this.bookingkey = 0,
  });
}
