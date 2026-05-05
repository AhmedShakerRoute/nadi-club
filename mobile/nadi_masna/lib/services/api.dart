import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiErr implements Exception {
  final String msg; final int? code;
  ApiErr(this.msg, [this.code]);
  @override String toString() => msg;
}

class Api {
  String? _token;
  void setToken(String t) => _token = t;
  void clear() => _token = null;
  Map<String,String> get _h => {'Content-Type':'application/json', if(_token!=null)'Authorization':'Bearer $_token'};
  static const _timeout = Duration(seconds: 15);

  Future<dynamic> _wrap(http.Response r) {
    if(r.statusCode>=200&&r.statusCode<300){if(r.body.isEmpty)return Future.value(null);return Future.value(json.decode(r.body));}
    String m='حدث خطأ';try{m=json.decode(r.body)['message']??m;}catch(_){}throw ApiErr(m,r.statusCode);
  }
  Future<dynamic> get(String p) async {
    try{final r=await http.get(Uri.parse('${K.baseUrl}$p'),headers:_h).timeout(_timeout);return _wrap(r);}
    on TimeoutException{throw ApiErr('انتهت مهلة الاتصال');}catch(e){if(e is ApiErr)rethrow;throw ApiErr('تعذر الاتصال');}
  }
  Future<dynamic> post(String p,Map<String,dynamic> b) async {
    try{final r=await http.post(Uri.parse('${K.baseUrl}$p'),headers:_h,body:json.encode(b)).timeout(_timeout);return _wrap(r);}
    on TimeoutException{throw ApiErr('انتهت مهلة الاتصال');}catch(e){if(e is ApiErr)rethrow;throw ApiErr('تعذر الاتصال');}
  }
  Future<dynamic> put(String p,[Map<String,dynamic>? b]) async {
    try{final r=await http.put(Uri.parse('${K.baseUrl}$p'),headers:_h,body:b!=null?json.encode(b):null).timeout(_timeout);return _wrap(r);}
    on TimeoutException{throw ApiErr('انتهت مهلة الاتصال');}catch(e){if(e is ApiErr)rethrow;throw ApiErr('تعذر الاتصال');}
  }
  Future<dynamic> del(String p) async {
    try{final r=await http.delete(Uri.parse('${K.baseUrl}$p'),headers:_h).timeout(_timeout);return _wrap(r);}
    on TimeoutException{throw ApiErr('انتهت مهلة الاتصال');}catch(e){if(e is ApiErr)rethrow;throw ApiErr('تعذر الاتصال');}
  }

  // Auth
  Future<Map<String,dynamic>> login(String e,String p) async => await post('/api/auth/login',{'email':e,'password':p});
  Future<Map<String,dynamic>> register(String n,String e,String p,String ph) async => await post('/api/auth/register',{'name':n,'email':e,'password':p,'phone':ph});

  // Courts
  Future<List> courts() async => await get('/api/courts');
  Future<List> avail(int id,String d) async => await get('/api/courts/$id/availability?date=$d');
  Future<dynamic> createCourt(Map<String,dynamic> d) async => await post('/api/courts',d);
  Future<dynamic> updateCourt(int id,Map<String,dynamic> d) async => await put('/api/courts/$id',d);
  Future<void> deleteCourt(int id) async => await del('/api/courts/$id');

  // Reservations
  Future<List> allRes() async => await get('/api/reservations');
  Future<List> myRes() async => await get('/api/reservations/mine');
  // Create single slot (with optional groupId for multi-hour)
  Future<dynamic> createRes(int cId,String date,String start,{String? groupId}) async =>
    await post('/api/reservations',{'courtId':cId,'date':date,'startTime':start,'groupId':groupId});
  Future<void> cancelRes(int id) async => await put('/api/reservations/$id/cancel');
  Future<void> cancelGroup(String gId) async => await put('/api/reservations/cancel-group?groupId=$gId');

  // Screenshot
  Future<void> uploadScreenshot(int resId,String base64) async =>
    await post('/api/reservations/screenshot',{'reservationId':resId,'screenshotBase64':base64});
  Future<void> uploadGroupScreenshot(String gId,String base64) async =>
    await post('/api/reservations/group-screenshot',{'groupId':gId,'screenshotBase64':base64});
  Future<Map<String,dynamic>> getScreenshot(int id) async => await get('/api/reservations/$id/screenshot');

  // Admin review
  Future<void> adminReview(int resId,String action,{String? note}) async =>
    await put('/api/reservations/review',{'reservationId':resId,'action':action,'note':note});
  Future<void> adminReviewGroup(String gId,String action,{String? note}) async =>
    await put('/api/reservations/review-group',{'groupId':gId,'action':action,'note':note});

  // Notifications
  Future<List> notifs() async => await get('/api/notifications');
  Future<Map<String,dynamic>> unreadCount() async => await get('/api/notifications/unread');
  Future<void> markRead(int id) async => await put('/api/notifications/$id/read');
  Future<void> markAllRead() async => await put('/api/notifications/read-all');

  // Users
  Future<List> users() async => await get('/api/users');
  Future<dynamic> updateProfile(int id,String n,String p,String? pw) async =>
    await put('/api/users/$id/profile',{'name':n,'phone':p,'newPassword':pw});
  Future<void> toggleUser(int id) async => await put('/api/users/$id/toggle');
}
final api = Api();
