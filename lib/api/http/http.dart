import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:salonapp/config/app_config.dart';
import 'package:salonapp/model/user.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/services/helper.dart';

class MyHttp {
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
    // Constructing options for HTTP request
    final Uri uri = Uri.parse(apiEndpoint);

    final User currentUser = await getCurrentUser();

    final String token = currentUser.token;

    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Making the HTTP GET request
    final http.Response response = await http.get(uri, headers: headers);

    // Handling response
    if (response.statusCode == 200) {
      // Request successful, parse and return response data
      return json.decode(response.body);
    } else {
      // Request failed, throw error
      throw 'Request failed with status: ${response.statusCode}';
    }
  }

  Future<List<Booking>> ListBooking() async {
    final response = await fetchFromServer(AppConfig.api_url_booking_home);
      List<dynamic> data = response;
      return data.map<Booking>((item) => Booking.fromJson(item)).toList();
     //return response;
  }
}
