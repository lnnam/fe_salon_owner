import 'package:intl/intl.dart';

class Booking {
  final String customername;
  final DateTime datetimebooking;
  final String staffname;
  final String servicename;
  final int servicekey;
  final int numbooked;
  final String customertype;
  final DateTime created_datetime;
  final String bookingdate;
  final String bookingtime;
  final String customerphoto;

  Booking({
    required this.customername,
    required this.datetimebooking,
    required this.staffname,
    required this.servicename,
    required this.servicekey,
    required this.numbooked,
    required this.customertype,
    required this.created_datetime,
    required this.bookingdate,
    required this.bookingtime,
    required this.customerphoto,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime bookingDateTime = DateTime.parse(json['datetime']);
    String formattedBookingDate = DateFormat('yyyy-MM-dd').format(bookingDateTime);
    String formattedBookingTime = DateFormat('HH:mm').format(bookingDateTime);
    //String createdDateTime = DateFormat('HH:mm yyyy-MM-dd').format(DateTime.parse(json['dateactivated']));
    String createdDateTime = DateTime.parse(json['dateactivated']);

    return Booking(
      customername: json['customername'] ?? 'Unknown',
      datetimebooking: bookingDateTime,
      staffname: json['staffname'] ?? 'N/A',
      servicename: json['servicename'] ?? 'N/A',
      servicekey: json['servicekey'] is int ? json['servicekey'] : int.tryParse(json['servicekey'].toString()) ?? 0,
      numbooked: json['pkey'] is int ? json['pkey'] : int.tryParse(json['pkey'].toString()) ?? 0,
      customertype: json['customertype'] ?? 'N/A',
      created_datetime: createdDateTime,
      bookingdate: formattedBookingDate,
      bookingtime: formattedBookingTime,
      customerphoto: json['photobase64'] != null && json['photobase64'] != ''
          ? json['photobase64']
          : 'Unknown',
    );
  }
}

class OnBooking {
  Map<String, dynamic>? staff;
  Map<String, dynamic>? customer;
  Map<String, dynamic>? service;
  Map<String, dynamic>? schedule;

  OnBooking({
    this.staff,
    this.customer,
    this.service,
    this.schedule,
  });
}
