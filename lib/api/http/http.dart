import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:salonapp/config/app_config.dart';
import 'package:salonapp/model/user.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/model/staff.dart';
import 'package:salonapp/model/service.dart';
import 'package:salonapp/model/customer.dart';
import 'package:salonapp/services/helper.dart';

/// Custom exception for server/network errors
class ServerException implements Exception {
  final String message;
  final dynamic originalError;

  ServerException({required this.message, this.originalError});

  @override
  String toString() => message;
}

class MyHttp {
    Future<dynamic> saveBooking(Map<String, dynamic> bookingData) async {
      final String url = AppConfig.api_url_booking_save;
      print('[API] Booking Save URL: ' + url);
      // ...existing code for making the request...
      // You can implement the actual request logic here or add this print to your existing save method.
    }
  /// @param username user salonkey
  /// @param password user username
  /// @param password user password
  Future<dynamic> salonLogin(
      String salonkey, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.api_url_login),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'salonkey': salonkey,
          'username': username,
          'password': password,
        }),
      );

      // Map<String, dynamic> response = {};

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        // then throw an exception.
        //throw Exception('Login Fail !');
        return null;
      }
    } catch (e) {
      // debugPrint(e.toString() + '$s');
      return e;
    }
  }

  Future<dynamic> fetchFromServer(String apiEndpoint) async {
    try {
      // Constructing options for HTTP request
      final Uri uri = Uri.parse(apiEndpoint);

      final User currentUser = await getCurrentUser();

      final String token = currentUser.token;

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('[HTTP] Making GET request to: $apiEndpoint');
      
      // Making the HTTP GET request with timeout
      final http.Response response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out after 30 seconds'),
      );
      
      print('[HTTP] Response status: ${response.statusCode}');
      
      // Handling response
      if (response.statusCode == 200) {
        print(
            '[HTTP] fetchFromServer: Success (200), Response length: ${response.body.length}');
        // Request successful, parse and return response data
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw ServerException(
          message: 'Your session has expired. Please log in again.',
          originalError: response.statusCode,
        );
      } else {
        // Request failed, throw error
        print(
            '[HTTP] fetchFromServer: Failed with status ${response.statusCode}');
        throw ServerException(
          message: 'Server error (${response.statusCode}). Please try again later.',
          originalError: response.statusCode,
        );
      }
    } on ServerException {
      rethrow; // Re-throw our custom exception as-is
    } catch (e) {
      print('[HTTP] Error in fetchFromServer: $e');
      String userMessage = 'An unexpected error occurred. Please try again later.';
      
      if (e.toString().contains('Connection refused')) {
        userMessage = 'Cannot connect to server. Please check your network connection.';
      } else if (e.toString().contains('timed out') || e is TimeoutException) {
        userMessage = 'Request timeout. Please check your network and try again.';
      } else if (e.toString().contains('Connection refused') || 
                 e.toString().contains('Failed to connect') ||
                 e.toString().contains('Network unreachable')) {
        userMessage = 'Cannot connect to server. Please check your network connection.';
      }
      
      throw ServerException(
        message: userMessage,
        originalError: e,
      );
    }
  }

  Future<List<Booking>> ListBooking({String? opt}) async {
    try {
      String endpoint = AppConfig.api_url_booking_home;
      if (opt != null && opt.isNotEmpty) {
        endpoint = '$endpoint?opt=$opt';
      }

      final response = await fetchFromServer(endpoint);

      List<Booking> bookings = [];

      // Handle response as Map (object with numeric keys) or List
      if (response is Map) {
        response.forEach((key, value) {
          if (value is Map) {
            bookings.add(Booking.fromJson(Map<String, dynamic>.from(value)));
          }
        });
      } else if (response is List) {
        response.asMap().forEach((index, item) {});
        bookings =
            response.map<Booking>((item) => Booking.fromJson(item)).toList();
      }

      return bookings;
    } catch (error) {
      print('[HTTP] ListBooking: ERROR - $error');
      rethrow;
    }
  }

  Future<List<Staff>> ListStaff() async {
    try {
      final response = await fetchFromServer(AppConfig.api_url_booking_staff);
      List<dynamic> data = response;
      return data.map<Staff>((item) => Staff.fromJson(item)).toList();
    } catch (error) {
      // Handle error
      print(error);

      rethrow;
    }
  }

  Future<List<Customer>> ListCustomer() async {
    try {
      final response =
          await fetchFromServer(AppConfig.api_url_booking_customer);
      List<dynamic> data = response;
      return data.map<Customer>((item) => Customer.fromJson(item)).toList();
    } catch (error) {
      // Handle error
      print(error);

      rethrow;
    }
  }

  Future<dynamic> AddCustomer({
    required String name,
    required String email,
    required String phone,
    required String dob,
  }) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final requestBody = <String, String>{
        'fullname': name,
        'email': email,
        'phone': phone,
        'dob': dob,
      };

      print('AddCustomer request body: $requestBody');

      final response = await http.post(
        Uri.parse(AppConfig.api_url_booking_customer_add),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        // Customer already exists - extract and return the customer data
        print(
            'Customer already exists: ${response.statusCode}, Response: ${response.body}');
        final responseData = jsonDecode(response.body);
        // Return the customer data from the response
        return responseData['customer'] ?? responseData;
      } else {
        print('Error: ${response.statusCode}, Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error adding customer: $e');
      return null;
    }
  }

  Future<List<Service>> ListServices() async {
    try {
      final response = await fetchFromServer(AppConfig.api_url_booking_service);
      List<dynamic> data = response;
      return data.map<Service>((item) => Service.fromJson(item)).toList();
    } catch (error) {
      // Handle error
      print(error);
      rethrow;
    }
  }

  //BOOKING

  Future<dynamic> SaveBooking(
    int bookingKey,
    String customerKey,
    String serviceKey,
    String staffKey,
    String date,
    String schedule,
    String note,
    String customerName,
    String staffName,
    String serviceName,
  ) async {
    //  print('url test: ${AppConfig.api_url_booking_add}');
    try {
      // Get current user and token
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final requestBody = <String, String>{
        'bookingkey': bookingKey.toString(),
        'customerkey': customerKey,
        'servicekey': serviceKey,
        'staffkey': staffKey,
        'date': date,
        'datetime': schedule,
        'note': note,
        'customername': customerName,
        'customeremail': '', // Add missing field
        'customerphone': '', // Add missing field
        'staffname': staffName,
        'servicename': serviceName,
        'userkey': '1',
      };

      print('SaveBooking request body: $requestBody');

      final response = await http.post(
        Uri.parse(AppConfig.api_url_booking_save),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode}, Response: ${response.body}');
        return null;
      }
    } catch (e) {
      return e; // Return error for debugging
    }
  }

  Future<bool> deleteBooking(int bookingId) async {
    try {
      // Get current user and token
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final response = await http.delete(
        Uri.parse('${AppConfig.api_url_booking_del}/$bookingId'),
        headers: <String, String>{
          'Authorization': 'Bearer $token', // <-- Add token here
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Successfully deleted
        return true;
      } else {
        print('Delete failed: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  /// Confirm booking as owner
  Future<bool> confirmBookingOwner(int bookingKey) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final Uri uri = Uri.parse(
        '${AppConfig.api_url_booking_confirm}?bookingkey=$bookingKey&token=${Uri.encodeComponent(token)}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Confirm failed: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Confirm booking error: $e');
      return false;
    }
  }

// MyHttp: returns list of simple maps (slot_time, available, available_staffs)
  Future<List<Map<String, dynamic>>> fetchAvailability({
    required DateTime date,
    String staffKey = 'any',
    int serviceDuration = 45,
  }) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final String formattedDate = date.toIso8601String().substring(0, 10);
      final Uri uri = Uri.parse(
        '${AppConfig.api_url_booking_getavailability}?date=$formattedDate&staffkey=$staffKey&service_duration=$serviceDuration',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        // print('Raw API data: $data');

        // If the response is a List, return as before
        if (data is List) {
          return data
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        }

        // If the response is a Map, extract 'slots' as a list
        if (data is Map && data['slots'] != null) {
          final slotsData = data['slots'];
          if (slotsData is List) {
            return slotsData
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }

        // fallback
        return [];
      } else {
        print('Fetch availability failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching availability: $e');
      return [];
    }
  }

  Future<String> getSMSMessage() async {
    try {
      final response = await fetchFromServer(AppConfig.api_url_booking_setting);

      // Extract sms message and salon_name from response
      if (response is Map) {
        String smsMessage = response['sms'] ?? 'Hello I am from USA Nail';
        String salonName = response['salon_name'] ?? 'USA Nail';
        final finalMessage = '$smsMessage\nThank you\n$salonName';
        print('[HTTP] getSMSMessage: Successfully fetched from backend');
        print('[HTTP] getSMSMessage: SMS = "$smsMessage"');
        print('[HTTP] getSMSMessage: Salon = "$salonName"');
        print('[HTTP] getSMSMessage: Final Message = "$finalMessage"');
        return finalMessage;
      }

      // Fallback to default message if no response
      print('[HTTP] getSMSMessage: No data in response, using fallback');
      return 'Hello I am from USA Nail\nThank you\nUSA Nail';
    } catch (e) {
      print('[HTTP] getSMSMessage: ERROR - $e');
      // Return fallback value on error
      return 'Hello I am from USA Nail\nThank you\nUSA Nail';
    }
  }

  /// Fetch app settings from the booking/setting endpoint
  Future<Map<String, dynamic>?> fetchAppSettings(String? token) async {
    try {
      print('[HTTP] fetchAppSettings: Starting with token: $token');
      final response = await http.get(
        Uri.parse(AppConfig.api_url_booking_setting),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('[HTTP] fetchAppSettings: Response status: ${response.statusCode}');
      print('[HTTP] fetchAppSettings: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('[HTTP] fetchAppSettings: Decoded response: $responseData');
        
        // Extract settings array
        if (responseData.containsKey('settings') && responseData['settings'] is List) {
          final settingsList = responseData['settings'] as List;
          if (settingsList.isNotEmpty) {
            final settings = settingsList[0] as Map<String, dynamic>;
            print('[HTTP] fetchAppSettings: Successfully extracted settings: $settings');
            return settings;
          }
        }
        
        print('[HTTP] fetchAppSettings: Invalid response structure');
        return null;
      } else {
        print('[HTTP] fetchAppSettings: Failed with status ${response.statusCode}');
        return null;
      }
    } catch (e) {
        print('[HTTP] fetchAppSettings: ERROR - $e');
      return null;
    }
  }

  /// Save booking settings to the backend
  /// POST to /api/booking/setting/update with booking settings data
  Future<bool> saveBookingSetting(Map<String, dynamic> settingsData) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;
      
      final Uri uri = Uri.parse(AppConfig.api_url_booking_setting_update);
      
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('[HTTP] saveBookingSetting: POST to $uri');
      print('[HTTP] saveBookingSetting: Data: $settingsData');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(settingsData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out after 30 seconds'),
      );

      print('[HTTP] saveBookingSetting: Response status: ${response.statusCode}');
      print('[HTTP] saveBookingSetting: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[HTTP] saveBookingSetting: Success');
        return true;
      } else {
        print('[HTTP] saveBookingSetting: Failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[HTTP] saveBookingSetting: ERROR - $e');
      return false;
    }
  }
}
