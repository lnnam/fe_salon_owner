import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class BookingProvider with ChangeNotifier {
  final OnBooking _onbooking = OnBooking();
  late StreamController<List<Booking>> _bookingStreamController;
  late Stream<List<Booking>> _bookingStreamBroadcast;
  Timer? _debounceTimer;
  final bool _suppressEmissions =
      false; // Prevent stream updates during UI-sensitive periods
  String?
      _currentViewOption; // Track current view being displayed (e.g., 'pending', 'thisweek')
  static const int DEBOUNCE_MS =
      300; // Reduced debounce for faster response while preventing rapid updates
  final String _salonName = 'Salon'; // Store salon name from backend
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

  void manualRefresh() async {
    try {
      print('[BookingProvider] Manual refresh triggered');
      // Load bookings based on current view option or all if not set
      final bookings = _currentViewOption != null
          ? await apiManager.ListBooking(opt: _currentViewOption)
          : await apiManager.ListBooking();
      if (!_bookingStreamController.isClosed && !_suppressEmissions) {
        // Schedule update for next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_bookingStreamController.isClosed && !_suppressEmissions) {
            _bookingStreamController.add(bookings);
          }
        });
      }
    } catch (e) {
      print('[BookingProvider] Error during manual refresh: $e');
    }
  }

  Stream<List<Booking>> get bookingStream => _bookingStreamBroadcast;

  OnBooking get onbooking => _onbooking;

  Future<void> loadBookingsWithDate(String date) async {
    try {
      print('[BookingProvider] Loading bookings for date: $date');
      final startTime = DateTime.now();
      final bookings = await apiManager.ListBooking(opt: date);
      final duration = DateTime.now().difference(startTime);
      print(
          '[BookingProvider] Loaded ${bookings.length} bookings in ${duration.inMilliseconds}ms');

      if (!_bookingStreamController.isClosed && !_suppressEmissions) {
        // Emit immediately for date-based loads
        _bookingStreamController.add(bookings);
      }
    } catch (e) {
      print('[BookingProvider] Error loading bookings with date $date: $e');
    }
  }

  Future<void> loadBookingsWithOption(String option) async {
    try {
      print('[BookingProvider] Loading bookings with option: $option');
      final startTime = DateTime.now();
      final bookings = await apiManager.ListBooking(opt: option);
      final duration = DateTime.now().difference(startTime);
      print(
          '[BookingProvider] Loaded ${bookings.length} bookings in ${duration.inMilliseconds}ms');

      if (!_bookingStreamController.isClosed && !_suppressEmissions) {
        // Emit immediately without debounce for manual option-based loads
        _bookingStreamController.add(bookings);
      }
    } catch (e) {
      print('[BookingProvider] Error loading bookings with option $option: $e');
    }
  }

  void setCurrentViewOption(String? option) {
    _currentViewOption = option;
    print('[BookingProvider] Current view option set to: $_currentViewOption');
  }

  String? get currentViewOption => _currentViewOption;

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
    _debounceTimer?.cancel();
    _bookingStreamController.close();
    super.dispose();
  }
}
