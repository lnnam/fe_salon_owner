import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';
import 'package:intl/intl.dart';

class BookingProvider with ChangeNotifier {
  
  final OnBooking _onbooking = OnBooking();

  OnBooking get onbooking => _onbooking;

  /* void setStaff(int staffkey) {
    _onbooking.staffkey = staffkey;
    notifyListeners();
  } */

  void setStaff(Map<String, dynamic> staff) {
     _onbooking.staff  = staff;
 //   print('Staff: ${_onbooking.staff}');
    notifyListeners();
  }

  void setService(Map<String, dynamic> service) {
    _onbooking.service = service;
    print('service: ${_onbooking.service}');
    notifyListeners();
  }


  void setSchedule(Map<String, dynamic> schedule) {
    _onbooking.schedule = schedule;
    print('schedule: ${_onbooking.schedule}');
    notifyListeners();
  }

void setCustomerDetails(Map<String, dynamic> customer) {
 _onbooking.customer  = customer;
  //   _onbooking.customerName  = name;
   //  _onbooking.customerEmail = email;
   // print('customer: ${_onbooking.customer}');
    notifyListeners();
  }

  // Mapping OnBooking data to bookingDetails
  Map<String, dynamic> get bookingDetails {
    String formattedSchedule = 'Not Available';
    if (_onbooking.schedule != null && _onbooking.schedule?['bookingStart'] != null) {
      try {
        DateTime dateTime = DateTime.parse(_onbooking.schedule?['bookingStart']);
        formattedSchedule = DateFormat('HH:mm, dd/MM/yyyy').format(dateTime);
      } catch (e) {
        print('Error parsing schedule date: $e');
      }
    }
    return {
      'schedule': formattedSchedule,
      'customerName': _onbooking.customer?['fullname'],
      'customerKey': _onbooking.staff?['customerkey'].toString(),
      'staffName': _onbooking.staff?['fullname'].toString(),
      'staffKey': _onbooking.staff?['staffkey'].toString(),
      'serviceName': _onbooking.service?['name'].toString(),
      'serviceKey': _onbooking.service?['servicekey'].toString(),
    };
  }
}
