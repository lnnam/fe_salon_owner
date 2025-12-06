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
  Timer? _debounceTimer;
  bool _isVisible = false; // Track if the page is currently visible
  bool _suppressEmissions =
      false; // Prevent stream updates during UI-sensitive periods
  static const int POLLING_INTERVAL = 10; // seconds
  static const int DEBOUNCE_MS =
      1000; // Increased debounce to prevent rapid updates
  String _salonName = 'Salon'; // Store salon name from backend
  Map<String, dynamic>? _appSettings;

  BookingProvider() {
    _initializeBookingStream();
    _loadSalonName(); // Load salon name on initialization
  }

  // Getter for salon name
  String get salonName => _salonName;

  // Method to load salon name from backend
  void _loadSalonName() {
    // Placeholder for loading salon name logic
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
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isVisible = false;
  }

  void pauseAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isVisible = false;
    _suppressEmissions = true;
    _debounceTimer?.cancel();
  }

  void resumeAutoRefresh() {
    _isVisible = true;
    _suppressEmissions = false;
    // Restart the timer
    if (_refreshTimer == null) {
      _loadBookings();
      _refreshTimer = Timer.periodic(
        Duration(seconds: POLLING_INTERVAL),
        (_) {
          if (_isVisible && !_suppressEmissions) {
            _loadBookings();
          }
        },
      );
    }
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await apiManager.ListBooking();
      for (int i = 0; i < bookings.length; i++) {}

      // Debounce the stream update to prevent rapid consecutive updates
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: DEBOUNCE_MS), () {
        if (!_bookingStreamController.isClosed && !_suppressEmissions) {
          // Schedule the update for the next frame to avoid interrupting current frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_bookingStreamController.isClosed && !_suppressEmissions) {
              _bookingStreamController.add(bookings);
            }
          });
        }
      });
    } catch (e) {}
  }

  void manualRefresh() async {
    try {
      final bookings = await apiManager.ListBooking();
      if (!_bookingStreamController.isClosed && !_suppressEmissions) {
        // Schedule update for next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_bookingStreamController.isClosed && !_suppressEmissions) {
            _bookingStreamController.add(bookings);
          }
        });
      }
    } catch (e) {}
  }

  Stream<List<Booking>> get bookingStream => _bookingStreamBroadcast;

  OnBooking get onbooking => _onbooking;

  Future<void> loadBookingsWithDate(String date) async {
    try {
      final bookings = await apiManager.ListBooking(opt: date);
      if (!_bookingStreamController.isClosed && !_suppressEmissions) {
        // Schedule update for next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_bookingStreamController.isClosed && !_suppressEmissions) {
            _bookingStreamController.add(bookings);
          }
        });
      }
    } catch (e) {}
  }

  Future<void> loadBookingsWithOption(String option) async {
    try {
      final bookings = await apiManager.ListBooking(opt: option);

      if (!_bookingStreamController.isClosed && !_suppressEmissions) {
        // Schedule update for next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_bookingStreamController.isClosed && !_suppressEmissions) {
            _bookingStreamController.add(bookings);
          }
        });
      }
    } catch (e) {}
  }

  void resetBooking() {
    _onbooking
      ..bookingkey = 0
      ..note = ''
      ..staff = {}
      ..service = {}
      ..schedule = {}
      ..editMode = false;

    notifyListeners();
  }

  void setEditMode(bool mode) {
    _onbooking.editMode = mode;
    notifyListeners();
  }

  void setBookingKey(int pkey) {
    _onbooking.bookingkey = pkey;
    notifyListeners();
  }

  void setNote(String note) {
    _onbooking.note = note;
    notifyListeners();
  }

  void setStaff(Map<String, dynamic> staff) {
    _onbooking.staff = staff;
    //   print('Staff: ${_onbooking.staff}');
    notifyListeners();
  }

  void setService(Map<String, dynamic> service) {
    _onbooking.service = service;
    notifyListeners();
  }

  void setSchedule(Map<String, dynamic> schedule) {
    _onbooking.schedule = schedule;
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
      } catch (e) {}
    }
    return {
      'bookingkey': _onbooking.bookingkey,
      'date': ScheduleDate,
      'schedule': _onbooking.schedule?['bookingStart'],
      'formattedschedule': formattedSchedule,
      'customername': _onbooking.customer?['fullname'],
      'customerkey': _onbooking.customer?['customerkey'].toString(),
      'customerphone': _onbooking.customer?['customerphone'] ?? 'N/A',
      'customeremail': _onbooking.customer?['customeremail'] ?? 'N/A',
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
      'customerphone': booking.customerphone,
      'customeremail': booking.customeremail,
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

  // Getter for app settings
  Map<String, dynamic>? get appSettings => _appSettings;

  // Method to update app settings
  void updateAppSettings(Map<String, dynamic> settings) {
    _appSettings = settings;
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _debounceTimer?.cancel();
    _bookingStreamController.close();
    super.dispose();
  }
}
