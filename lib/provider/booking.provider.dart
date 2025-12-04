import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class BookingProvider with ChangeNotifier {
  final OnBooking _onbooking = OnBooking();
  late StreamController<List<Booking>> _bookingStreamController;
  late Stream<List<Booking>> _bookingStreamBroadcast;
  Timer? _refreshTimer;
  bool _isVisible = false; // Track if the page is currently visible
  static const int POLLING_INTERVAL = 3; // seconds

  BookingProvider() {
    _initializeBookingStream();
  }

  void _initializeBookingStream() {
    _bookingStreamController = StreamController<List<Booking>>();
    _bookingStreamBroadcast =
        _bookingStreamController.stream.asBroadcastStream();
  }

  void startAutoRefresh() {
    _isVisible = true;
    // Avoid starting multiple timers
    if (_refreshTimer != null) {
      return;
    }

    // Load initial data immediately
    _loadBookings();

    _refreshTimer = Timer.periodic(
      Duration(seconds: POLLING_INTERVAL),
      (_) {
        // Only load if the page is still visible
        if (_isVisible) {
          _loadBookings();
        }
      },
    );
    print('[BookingProvider] Auto-refresh started');
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isVisible = false;
    print('[BookingProvider] Auto-refresh stopped (timer cancelled)');
  }

  void pauseAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isVisible = false;
    print('[BookingProvider] Auto-refresh paused');
  }

  void resumeAutoRefresh() {
    _isVisible = true;
    // Restart the timer
    if (_refreshTimer == null) {
      _loadBookings();
      _refreshTimer = Timer.periodic(
        Duration(seconds: POLLING_INTERVAL),
        (_) {
          if (_isVisible) {
            _loadBookings();
          }
        },
      );
    }
    print('[BookingProvider] Auto-refresh resumed');
  }

  Future<void> _loadBookings() async {
    try {
      print('[BookingProvider] Fetching bookings...');
      final bookings = await apiManager.ListBooking();
      print('[BookingProvider] Received ${bookings.length} bookings');
      for (int i = 0; i < bookings.length; i++) {
        print(
            '[BookingProvider] Booking $i: pkey=${bookings[i].pkey}, customer=${bookings[i].customername}, staff=${bookings[i].staffname}, service=${bookings[i].servicename}, status=${bookings[i].displayStatus}, time=${bookings[i].bookingstart}');
      }
      if (!_bookingStreamController.isClosed) {
        _bookingStreamController.add(bookings);
      }
    } catch (e) {
      print('[BookingProvider] Error fetching bookings: $e');
    }
  }

  void manualRefresh() async {
    try {
      print('[BookingProvider] Manual refresh: Fetching bookings...');
      final bookings = await apiManager.ListBooking();
      print(
          '[BookingProvider] Manual refresh: Received ${bookings.length} bookings');
      for (int i = 0; i < bookings.length; i++) {
        print(
            '[BookingProvider] Booking $i: pkey=${bookings[i].pkey}, customer=${bookings[i].customername}, staff=${bookings[i].staffname}, service=${bookings[i].servicename}, status=${bookings[i].displayStatus}, time=${bookings[i].bookingstart}');
      }
      if (!_bookingStreamController.isClosed) {
        _bookingStreamController.add(bookings);
      }
    } catch (e) {
      print('[BookingProvider] Error refreshing bookings: $e');
    }
  }

  Stream<List<Booking>> get bookingStream => _bookingStreamBroadcast;

  OnBooking get onbooking => _onbooking;

  void resetBooking() {
    _onbooking
      ..bookingkey = 0
      ..note = ''
      ..staff = {}
      ..service = {}
      ..schedule = {}
      ..editMode = false;

    print('BookingProvider reset: booking cleared');
    notifyListeners();
  }

  void setEditMode(bool mode) {
    _onbooking.editMode = mode;
    notifyListeners();
  }

  void setBookingKey(int pkey) {
    _onbooking.bookingkey = pkey;
    print('bookingkey: ${_onbooking.bookingkey}');
    notifyListeners();
  }

  void setNote(String note) {
    _onbooking.note = note;
    print('note: ${_onbooking.note}');
    notifyListeners();
  }

  void setStaff(Map<String, dynamic> staff) {
    _onbooking.staff = staff;
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
    _onbooking.customer = customer;
    //   _onbooking.customerName  = name;
    //  _onbooking.customerEmail = email;
//   print('customer: ${_onbooking.customer}');
    notifyListeners();
  }

  // Mapping OnBooking data to bookingDetails
  Map<String, dynamic> get bookingDetails {
    String formattedSchedule = 'Not Available';
    String ScheduleDate = 'Not Available';
    if (_onbooking.schedule != null &&
        _onbooking.schedule?['bookingStart'] != null) {
      try {
        DateTime dateTime =
            DateTime.parse(_onbooking.schedule?['bookingStart']);
        formattedSchedule = DateFormat('HH:mm, dd/MM/yyyy').format(dateTime);
        ScheduleDate = DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        print('Error parsing schedule date: $e');
      }
    }
    return {
      'bookingkey': _onbooking.bookingkey,
      'date': ScheduleDate,
      'schedule': _onbooking.schedule?['bookingStart'],
      'formattedschedule': formattedSchedule,
      'customername': _onbooking.customer?['fullname'],
      'customerkey': _onbooking.customer?['customerkey'].toString(),
      'staffname': _onbooking.staff?['fullname'].toString(),
      'staffkey': _onbooking.staff?['staffkey'].toString(),
      'servicename': _onbooking.service?['name'].toString(),
      'servicekey': _onbooking.service?['servicekey'].toString(),
      'note': _onbooking.note,
    };
  }

  void setBookingFromModel(Booking booking) {
    _onbooking.customer = {
      'customerkey': booking.customerkey,
      'fullname': booking.customername,
    };
    _onbooking.staff = {
      'staffkey': booking.staffkey,
      'fullname': booking.staffname,
    };
    _onbooking.service = {
      'servicekey': booking.servicekey,
      'name': booking.servicename,
    };
    _onbooking.schedule = {
      'bookingStart': '${booking.bookingtime}',
    };

    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bookingStreamController.close();
    super.dispose();
  }
}
