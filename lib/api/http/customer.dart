import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salonapp/config/app_config.dart';
import 'package:salonapp/model/user.dart';
import 'package:salonapp/model/customer.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/api/http/http.dart';
import 'package:salonapp/services/helper.dart' show getCurrentUser;

class CustomerApi {
  final MyHttp _http;

  CustomerApi(this._http);

  Future<List<Customer>> listCustomer() async {
    try {
      final currentUser = await getCurrentUser();
      final storeName = Uri.encodeComponent(currentUser.salonname);
      final url = '${AppConfig.api_url}/api/getdata?storename=$storeName';
      final response = await _http.fetchFromServer(url);
      List<dynamic> data = response;
      return data.map<Customer>((item) => Customer.fromJson(item)).toList();
    } catch (error) {
      // Handle error
      print(error);
      rethrow;
    }
  }

  Future<dynamic> addCustomer({
    required String name,
    required String email,
    required String phone,
    required String birthday,
  }) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final requestBody = <String, String>{
        'fullname': name,
        'email': email,
        'phone': phone,
        'dob': birthday,
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

  Future<bool> deleteCustomer(int customerKey) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      print('[API] Delete customer $customerKey');

      final response = await http.delete(
        Uri.parse('${AppConfig.api_url_customer_delete}/$customerKey'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('[API] Customer deletion successful');
        return true;
      } else {
        print(
            '[HTTP] deleteCustomer: Failed with status ${response.statusCode}');
        print('[HTTP] Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[HTTP] deleteCustomer: ERROR - $e');
      return false;
    }
  }

  Future<Customer?> getCustomer(int customerKey) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      print('[API] Get customer $customerKey');

      final response = await http.get(
        Uri.parse('${AppConfig.api_url_customer_get}/$customerKey'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[API] Customer data received: $data');

        if (data is Map && data.containsKey('pkey')) {
          return Customer.fromJson(data as Map<String, dynamic>);
        } else if (data is List && data.isNotEmpty && data[0] is Map) {
          return Customer.fromJson(data[0] as Map<String, dynamic>);
        }
        return null;
      } else {
        print('[HTTP] getCustomer: Failed with status ${response.statusCode}');
        print('[HTTP] Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[HTTP] getCustomer: ERROR - $e');
      return null;
    }
  }

  Future<dynamic> updateCustomer({
    required int customerKey,
    required String name,
    required String email,
    required String phone,
    required String birthday,
  }) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final requestBody = <String, String>{
        'fullname': name,
        'email': email,
        'phone': phone,
        'dob': birthday,
      };

      print('[API] Update customer $customerKey with: $requestBody');

      final response = await http.put(
        Uri.parse('${AppConfig.api_url_customer_update}/$customerKey'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[API] Customer update successful');
        return jsonDecode(response.body);
      } else {
        print(
            '[HTTP] updateCustomer: Failed with status ${response.statusCode}');
        print('[HTTP] Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[HTTP] updateCustomer: ERROR - $e');
      return null;
    }
  }

  Future<bool> setVip({
    required int customerId,
    required int isVip,
  }) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      final requestBody = <String, int>{
        'isvip': isVip,
      };

      print('[API] Setting VIP status for customer $customerId: $requestBody');

      final response = await http.post(
        Uri.parse('${AppConfig.api_url}/api/customer/setvip/$customerId'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[API] VIP status set successfully');
        return true;
      } else {
        print('[HTTP] setVip: Failed with status ${response.statusCode}');
        print('[HTTP] Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[HTTP] setVip: ERROR - $e');
      return false;
    }
  }

  Future<List<Booking>> getCustomerBookings(int customerKey) async {
    try {
      final User currentUser = await getCurrentUser();
      final String token = currentUser.token;

      print('[API] Fetching bookings for customer $customerKey');

      final response = await http.get(
        Uri.parse('${AppConfig.api_url}/api/customer/$customerKey/listbooking'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[API] Customer bookings fetched successfully');
        final dynamic data = jsonDecode(response.body);
        print('[API] Raw response data: $data');
        print('[API] Response data type: ${data.runtimeType}');

        // Handle both list and map responses
        List<dynamic> bookingList = [];
        if (data is List) {
          print('[API] Response is a List with ${data.length} items');
          bookingList = data;
        } else if (data is Map && data.containsKey('bookings')) {
          print('[API] Response is a Map with bookings key');
          bookingList = data['bookings'] ?? [];
        } else if (data is Map) {
          print('[API] Response is a Map, extracting values');
          bookingList = data.values.toList();
        }

        print('[API] Processing ${bookingList.length} bookings');
        final result = bookingList.map<Booking>((item) {
          print('[API] Parsing booking: $item');
          return Booking.fromJson(item as Map<String, dynamic>);
        }).toList();
        print('[API] Successfully parsed ${result.length} bookings');
        return result;
      } else {
        print(
            '[HTTP] getCustomerBookings: Failed with status ${response.statusCode}');
        print('[HTTP] Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('[HTTP] getCustomerBookings: ERROR - $e');
      return [];
    }
  }
}
