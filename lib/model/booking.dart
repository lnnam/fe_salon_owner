import 'package:intl/intl.dart';

class Booking {
  final String customerkey;
  final String customername;
  final DateTime datetimebooking;
  final String staffkey;
  final String staffname;
  final String servicename;
  final String servicekey;
  final String numbooked;
  final String customertype;
  final DateTime created_datetime;
  final String bookingdate;
  final String bookingtime;
  final String customerphoto;

  Booking({
    required this.customerkey,
    required this.customername,
    required this.datetimebooking,
    required this.staffkey,
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
    DateTime createdDateTime = DateTime.parse(json['dateactivated']);

    return Booking(
      customername: json['customername'] ?? 'Unknown',
      customerkey: json['customerkey'].toString() ?? 'Unknown',
      staffkey: json['staffkey'].toString() ?? 'Unknown',
      datetimebooking: bookingDateTime,
      staffname: json['staffname'] ?? 'N/A',
      servicename: json['servicename'] ?? 'N/A',
      servicekey: json['servicekey'].toString(),
      numbooked: json['pkey'].toString(),
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
  bool editMode;

  OnBooking({
    this.staff,
    this.customer,
    this.service,
    this.schedule,
    this.editMode = false, // default to false
  });
}

