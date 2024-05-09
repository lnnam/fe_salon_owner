import 'package:intl/intl.dart';

class Booking {
  final String customername;
  final DateTime datetimebooking;
  final String staffname;
  final String servicename;
  final int numbooked;
  final String customertype;
  final String created_datetime;
  final String bookingdate;
  final String bookingtime;

  Booking({
    required this.customername,
    required this.datetimebooking,
    required this.staffname,
    required this.servicename,
    required this.numbooked,
    required this.customertype,
    required this.created_datetime,
    required this.bookingdate,
    required this.bookingtime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse datetimebooking string to DateTime object
    DateTime bookingDateTime = DateTime.parse(json['datetime']);

    // Format bookingDateTime to date string and time string
    String formattedBookingDate = DateFormat('yyyy-MM-dd').format(bookingDateTime);
    String formattedBookingTime = DateFormat('HH:mm').format(bookingDateTime);

    String created_datetime = DateFormat('HH:mm yyyy-MM-dd').format(DateTime.parse(json['dateactivated']));

    return Booking(
      customername: json['customername'],
      datetimebooking: bookingDateTime,
      staffname: json['staffname'],
      servicename: json['servicename'],
      numbooked: json['pkey'],
      customertype: 'cxsdsd',
      created_datetime: created_datetime,
      bookingdate: formattedBookingDate,
      bookingtime: formattedBookingTime,
    );
  }
}
