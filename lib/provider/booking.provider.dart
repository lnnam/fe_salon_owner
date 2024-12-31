import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';

class BookingProvider with ChangeNotifier {
  
  final OnBooking _onbooking = OnBooking(staffkey:0, servicekey: 0, cusomterkey: 0);

  OnBooking get onbooking => _onbooking;

  void setStaff(int staffkey) {
    _onbooking.staffkey = staffkey;
    notifyListeners();
  }

  void setService(int servicekey) {
    _onbooking.servicekey = servicekey;
    //print('servicekey: ${_onbooking.servicekey}');
    notifyListeners();
  }

  int getStaff() {
    return _onbooking.staffkey;
  }

  void setSchedule(Map<String, dynamic> schedule) {
    _onbooking.schedule = schedule;
    print('kekekee: ${_onbooking.schedule}');
    notifyListeners();
  }


  void setCustomerDetails(String name, String email) {
    // _onbooking.customerName // = name;
    // _onbooking.customerEmail = email;
    notifyListeners();
  }
}
