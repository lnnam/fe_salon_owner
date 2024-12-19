import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';

class BookingProvider with ChangeNotifier {
  
  final OnBooking _onbooking = OnBooking(staffkey: '', servicekey: '');

  OnBooking get onbooking => _onbooking;

  void setStaff(int staffkey) {
    _onbooking.staffkey = staffkey.toString();
    notifyListeners();
  }

  void setService(int servicekey) {
    _onbooking.servicekey = servicekey.toString();
    notifyListeners();
  }

  String getStaff() {
    return _onbooking.staffkey;
  }

  void setSchedule(DateTime schedule) {
    // _onbooking.schedule = schedule;
    notifyListeners();
  }


  void setCustomerDetails(String name, String email) {
    // _onbooking.customerName = name;
    // _onbooking.customerEmail = email;
    notifyListeners();
  }
}
