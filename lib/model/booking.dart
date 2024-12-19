import 'package:intl/intl.dart';

class Booking {
  final String customername;
  final DateTime datetimebooking;
  final String staffname;
  final String servicename;
  final int servicekey;
  final int numbooked;
  final String customertype;
  final String created_datetime;
  final String bookingdate;
  final String bookingtime;
  String customerphoto;

  Booking({
    required this.customername,
    required this.datetimebooking,
    required this.customerphoto,
    required this.staffname,
    required this.servicename,
    required this.servicekey,
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
      customerphoto: json['photobase64'] != null && json['photobase64'] != '' ? json['photobase64'] : 'Unknown',
      datetimebooking: bookingDateTime,
      staffname: json['staffname'],
      servicekey: json['servicekey'],
      servicename: json['servicename'],
      numbooked: json['pkey'],
      customertype: 'cxsdsd',
      created_datetime: created_datetime,
      bookingdate: formattedBookingDate,
      bookingtime: formattedBookingTime,
    );
  }
}

class OnBooking {
   String staffkey; // Unique identifier for the booking
 //  String cusomterkey; // ID of the staff assigned to the booking
   String servicekey; // ID of the customer who made the booking
  // DateTime dateTime; // Date and time of the booking

  // Constructor
  OnBooking({
    required this.staffkey,
   // required this.cusomterkey,
    required this.servicekey,
   // required this.dateTime,
  });

}
