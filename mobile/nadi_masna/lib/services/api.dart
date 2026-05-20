import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiErr implements Exception {
  final String msg;
  final int? code;

  ApiErr(this.msg, [this.code]);

  @override
  String toString() => msg;
}

class Api {
  String? _token;

  void setToken(String t) => _token = t;

  void clear() => _token = null;

  Map<String, String> get _h => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static const _timeout = Duration(seconds: 15);

  Future<dynamic> _wrap(http.Response r) {
    debugPrint('STATUS CODE: ${r.statusCode}');
    debugPrint('RESPONSE BODY: ${r.body}');

    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return Future.value(null);
      return Future.value(json.decode(r.body));
    }

    String m = 'حدث خطأ';

    try {
      if (r.body.isNotEmpty) {
        final decoded = json.decode(r.body);

        if (decoded is Map<String, dynamic>) {
          if (decoded['message'] != null) {
            m = decoded['message'].toString();
          } else if (decoded['detail'] != null) {
            m = decoded['detail'].toString();
          } else if (decoded['title'] != null) {
            m = decoded['title'].toString();
          } else if (decoded['error'] != null) {
            m = decoded['error'].toString();
          } else if (decoded['errors'] != null) {
            final errors = decoded['errors'];

            if (errors is Map && errors.isNotEmpty) {
              final firstError = errors.values.first;

              if (firstError is List && firstError.isNotEmpty) {
                m = firstError.first.toString();
              } else {
                m = firstError.toString();
              }
            } else {
              m = errors.toString();
            }
          }
        } else if (decoded is String) {
          m = decoded;
        }
      }
    } catch (e) {
      debugPrint('ERROR PARSING RESPONSE BODY: $e');
    }

    throw ApiErr(m, r.statusCode);
  }

  Future<dynamic> get(String p) async {
    try {
      final url = Uri.parse('${K.baseUrl}$p');

      debugPrint('GET URL: $url');

      final r = await http
          .get(
            url,
            headers: _h,
          )
          .timeout(_timeout);

      return _wrap(r);
    } on TimeoutException {
      throw ApiErr('انتهت مهلة الاتصال');
    } catch (e) {
      debugPrint('GET ERROR: $e');

      if (e is ApiErr) rethrow;

      throw ApiErr('تعذر الاتصال');
    }
  }

  Future<dynamic> post(String p, Map<String, dynamic> b) async {
    try {
      final url = Uri.parse('${K.baseUrl}$p');

      debugPrint('POST URL: $url');
      debugPrint('POST BODY: ${json.encode(b)}');

      final r = await http
          .post(
            url,
            headers: _h,
            body: json.encode(b),
          )
          .timeout(_timeout);

      return _wrap(r);
    } on TimeoutException {
      throw ApiErr('انتهت مهلة الاتصال');
    } catch (e) {
      debugPrint('POST ERROR: $e');

      if (e is ApiErr) rethrow;

      throw ApiErr('تعذر الاتصال');
    }
  }

  Future<dynamic> put(String p, [Map<String, dynamic>? b]) async {
    try {
      final url = Uri.parse('${K.baseUrl}$p');

      debugPrint('PUT URL: $url');
      debugPrint('PUT BODY: ${b != null ? json.encode(b) : null}');

      final r = await http
          .put(
            url,
            headers: _h,
            body: b != null ? json.encode(b) : null,
          )
          .timeout(_timeout);

      return _wrap(r);
    } on TimeoutException {
      throw ApiErr('انتهت مهلة الاتصال');
    } catch (e) {
      debugPrint('PUT ERROR: $e');

      if (e is ApiErr) rethrow;

      throw ApiErr('تعذر الاتصال');
    }
  }

  Future<dynamic> del(String p) async {
    try {
      final url = Uri.parse('${K.baseUrl}$p');

      debugPrint('DELETE URL: $url');

      final r = await http
          .delete(
            url,
            headers: _h,
          )
          .timeout(_timeout);

      return _wrap(r);
    } on TimeoutException {
      throw ApiErr('انتهت مهلة الاتصال');
    } catch (e) {
      debugPrint('DELETE ERROR: $e');

      if (e is ApiErr) rethrow;

      throw ApiErr('تعذر الاتصال');
    }
  }

  // Auth
  Future<Map<String, dynamic>> login(String e, String p) async {
    final result = await post('/api/auth/login', {
      'email': e,
      'password': p,
    });

    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> register(
    String n,
    String e,
    String p,
    String ph,
  ) async {
    final result = await post('/api/auth/register', {
      'name': n,
      'email': e,
      'password': p,
      'phone': ph,
    });

    return Map<String, dynamic>.from(result);
  }

  // Courts
  Future<List> courts() async {
    final result = await get('/api/courts');
    return List.from(result);
  }

  Future<List> avail(int id, String d) async {
    final result = await get('/api/courts/$id/availability?date=$d');
    return List.from(result);
  }

  Future<dynamic> createCourt(Map<String, dynamic> d) async {
    return await post('/api/courts', d);
  }

  Future<dynamic> updateCourt(int id, Map<String, dynamic> d) async {
    return await put('/api/courts/$id', d);
  }

  Future<void> deleteCourt(int id) async {
    await del('/api/courts/$id');
  }

  // Reservations
  Future<List> allRes() async {
    final result = await get('/api/reservations');
    return List.from(result);
  }

  Future<List> myRes() async {
    final result = await get('/api/reservations/mine');
    return List.from(result);
  }

  // Create single slot with optional groupId for multi-hour
  Future<dynamic> createRes(
    int cId,
    String date,
    String start, {
    String? groupId,
  }) async {
    return await post('/api/reservations', {
      'courtId': cId,
      'date': date,
      'startTime': start,
      'groupId': groupId,
    });
  }

  Future<void> cancelRes(int id) async {
    await put('/api/reservations/$id/cancel');
  }

  Future<void> cancelGroup(String gId) async {
    await put('/api/reservations/cancel-group?groupId=$gId');
  }

  // Screenshot
  Future<void> uploadScreenshot(int resId, String base64) async {
    await post('/api/reservations/screenshot', {
      'reservationId': resId,
      'screenshotBase64': base64,
    });
  }

  Future<void> uploadGroupScreenshot(String gId, String base64) async {
    await post('/api/reservations/group-screenshot', {
      'groupId': gId,
      'screenshotBase64': base64,
    });
  }

  Future<Map<String, dynamic>> getScreenshot(int id) async {
    final result = await get('/api/reservations/$id/screenshot');
    return Map<String, dynamic>.from(result);
  }

  // Admin review
  Future<void> adminReview(
    int resId,
    String action, {
    String? note,
  }) async {
    await put('/api/reservations/review', {
      'reservationId': resId,
      'action': action,
      'note': note,
    });
  }

  Future<void> adminReviewGroup(
    String gId,
    String action, {
    String? note,
  }) async {
    await put('/api/reservations/review-group', {
      'groupId': gId,
      'action': action,
      'note': note,
    });
  }

  // Notifications
  Future<List> notifs() async {
    final result = await get('/api/notifications');
    return List.from(result);
  }

  Future<Map<String, dynamic>> unreadCount() async {
    final result = await get('/api/notifications/unread');
    return Map<String, dynamic>.from(result);
  }

  Future<void> markRead(int id) async {
    await put('/api/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await put('/api/notifications/read-all');
  }

  // Users
  Future<List> users() async {
    final result = await get('/api/users');
    return List.from(result);
  }

  Future<dynamic> updateProfile(
    int id,
    String n,
    String p,
    String? pw,
  ) async {
    return await put('/api/users/$id/profile', {
      'name': n,
      'phone': p,
      'newPassword': pw,
    });
  }

  Future<void> toggleUser(int id) async {
    await put('/api/users/$id/toggle');
  }
}

final api = Api();