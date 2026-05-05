import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api.dart';
import '../utils/constants.dart';
class AuthProv extends ChangeNotifier{
  AppUser? _u; bool _loading=false; String? _err;
  AppUser? get user=>_u; bool get loading=>_loading; String? get err=>_err;
  bool get ok=>_u!=null; bool get isAdmin=>_u?.isAdmin??false;
  Future<void> restore()async{final p=await SharedPreferences.getInstance();final d=p.getString(K.userKey);final t=p.getString(K.tokenKey);if(d!=null&&t!=null){_u=AppUser.fromJson(json.decode(d),token:t);api.setToken(t);notifyListeners();}}
  Future<bool> login(String e,String pw)async{_loading=true;_err=null;notifyListeners();try{final d=await api.login(e,pw);await _save(d);return true;}on ApiErr catch(e){_err=e.msg;}catch(_){_err='تعذر الاتصال بالخادم';}finally{_loading=false;notifyListeners();}return false;}
  Future<bool> register(String n,String e,String pw,String ph)async{_loading=true;_err=null;notifyListeners();try{final d=await api.register(n,e,pw,ph);await _save(d);return true;}on ApiErr catch(x){_err=x.msg;}catch(_){_err='تعذر الاتصال';}finally{_loading=false;notifyListeners();}return false;}
  Future<void> updateProfile(int id,String n,String ph,String? pw)async{final d=await api.updateProfile(id,n,ph,pw);await _save({...d,'token':_u!.token});}
  Future<void> logout()async{final p=await SharedPreferences.getInstance();await p.remove(K.tokenKey);await p.remove(K.userKey);api.clear();_u=null;notifyListeners();}
  Future<void> _save(Map<String,dynamic> d)async{final t=d['token']as String;_u=AppUser.fromJson(d,token:t);api.setToken(t);final p=await SharedPreferences.getInstance();await p.setString(K.tokenKey,t);await p.setString(K.userKey,json.encode(d));}
}