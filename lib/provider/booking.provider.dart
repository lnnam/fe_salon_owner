import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';

class BookingProvider with ChangeNotifier {
  
  final OnBooking _onbooking = OnBooking(staffkey: '');

  OnBooking get onbooking => _onbooking;

  void setStaff(int staffkey) {
    _onbooking.staffkey = staffkey.toString();
    notifyListeners();
  }

  String getStaff() {
    return _onbooking.staffkey;
  }

  void setSchedule(DateTime schedule) {
    // _onbooking.schedule = schedule;
    notifyListeners();
  }

  void setService(String service) {
    // _onbooking.service = service;
    notifyListeners();
  }

  void setCustomerDetails(String name, String email) {
    // _onbooking.customerName = name;
    // _onbooking.customerEmail = email;
    notifyListeners();
  }
}
