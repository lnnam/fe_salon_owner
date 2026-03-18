import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:salonapp/config/app_config.dart';
import 'package:salonapp/model/service.dart';
import 'package:salonapp/api/http/http.dart';
import 'package:salonapp/services/helper.dart' show getCurrentUser;

class PosApi {
  final Set<String> _voidingSaleKeys = <String>{};

  Future<Map<String, dynamic>> getPosDailySummary({
    required String from,
    required String to,
  }) async {
    try {
      final uri = Uri.parse(AppConfig.api_url_pos_summary_daily).replace(
        queryParameters: <String, String>{
          'from': from,
          'to': to,
        },
      );

      print('[API] Loading POS  summary from: $uri');
      final response = await http.get(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }

      String message = 'Failed to load summary';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = (err['error'] ?? err['message'] ?? message).toString();
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body;
        }
      }

      throw ServerException(
        message: message,
        originalError: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Server connection issue',
        originalError: e,
      );
    }
  }

  Future<Map<String, dynamic>> getPosReceipts({
    String? date,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final effectiveLimit = limit > 100 ? 100 : limit;
      final params = <String, String>{
        'page': page.toString(),
        'limit': effectiveLimit.toString(),
      };
      if (date != null && date.isNotEmpty) {
        params['date'] = date;
      }

      final uri = Uri.parse(AppConfig.api_url_pos_receipt)
          .replace(queryParameters: params);

      print('[API] Loading POS receipts from: $uri');

      final response = await http.get(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }

      String message = 'Failed to load receipts';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = (err['error'] ?? err['message'] ?? message).toString();
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body;
        }
      }

      throw ServerException(
        message: message,
        originalError: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Server connection issue',
        originalError: e,
      );
    }
  }

  Future<Map<String, dynamic>> getPosReportDaily({
    required String from,
    required String to,
  }) async {
    try {
      final uri = Uri.parse(AppConfig.api_url_pos_report_daily).replace(
        queryParameters: <String, String>{
          'from': from,
          'to': to,
        },
      );



      final response = await http.get(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }

      String message = 'Failed to load daily report';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = (err['error'] ?? err['message'] ?? message).toString();
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body;
        }
      }

      throw ServerException(
        message: message,
        originalError: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Server connection issue',
        originalError: e,
      );
    }
  }

  Future<List<Service>> getPosServices() async {
    try {
      final uri = Uri.parse(AppConfig.api_url_pos_service);

      print('[API] Loading POS services from: $uri');

      final response = await http.get(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((item) => Service.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
        return <Service>[];
      }

      String message = 'Failed to load POS services';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = (err['error'] ?? err['message'] ?? message).toString();
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body;
        }
      }

      throw ServerException(
        message: message,
        originalError: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Server connection issue',
        originalError: e,
      );
    }
  }

  Future<Map<String, dynamic>> savePosSale({
    required List<int> serviceKeys,
    required String paymentMethod,
    required String dateActivated,
  }) async {
    try {
      final uri = Uri.parse(AppConfig.api_url_pos_sale);
      final body = jsonEncode(<String, dynamic>{
        'servicekey': serviceKeys,
        'payment_method': paymentMethod,
        'dateactivated': dateActivated,
      });

      print('[API] Saving POS sale to: $uri');

      final response = await http.post(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        return <String, dynamic>{};
      }

      String message = 'Failed to save sale';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = (err['error'] ?? err['message'] ?? message).toString();
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body;
        }
      }

      throw ServerException(
        message: message,
        originalError: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Server connection issue',
        originalError: e,
      );
    }
  }

  Future<bool> deletePosSale(String saleKey) async {
    final normalizedKey = saleKey.trim();

    if (normalizedKey.isEmpty) {
      throw ServerException(message: 'Invalid sale key');
    }
    if (_voidingSaleKeys.contains(normalizedKey)) {
      print(
          '[API] Skipping duplicate void request for sale key: $normalizedKey');
      return false;
    }

    _voidingSaleKeys.add(normalizedKey);
    try {
      final currentUser = await getCurrentUser();
      final token = currentUser.token;
      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final uri = Uri.parse(
        '${AppConfig.api_url_pos_sale}/${Uri.encodeComponent(normalizedKey)}',
      );
      print('[API] Voiding POS sale via DELETE: $uri');

      final response = await http.delete(uri, headers: headers);
      print('[API] Delete sale response status: ${response.statusCode}');
      print('[API] Delete sale response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      String message = 'Failed to delete sale';
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        message = (err['error'] ?? err['message'] ?? message).toString();
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body;
        }
      }

      throw ServerException(
        message: message,
        originalError: response.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Server connection issue',
        originalError: e,
      );
    } finally {
      _voidingSaleKeys.remove(normalizedKey);
    }
  }
}
