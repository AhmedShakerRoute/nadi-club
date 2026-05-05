import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
class ThemeProv extends ChangeNotifier{
  bool _dark=true; bool get isDark=>_dark; ThemeMode get mode=>_dark?ThemeMode.dark:ThemeMode.light;
  Future<void> load()async{final p=await SharedPreferences.getInstance();_dark=p.getBool(K.themeKey)??true;notifyListeners();}
  Future<void> toggle()async{_dark=!_dark;final p=await SharedPreferences.getInstance();await p.setBool(K.themeKey,_dark);notifyListeners();}
}