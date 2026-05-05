import 'package:flutter/material.dart';
import '../models/court.dart';
import '../services/api.dart';
class SlotAvail{final String hour;final bool avail;const SlotAvail(this.hour,this.avail);factory SlotAvail.fromJson(Map<String,dynamic> j)=>SlotAvail(j['hour'],j['isAvailable']);}
class CourtProv extends ChangeNotifier{
  List<Court> _courts=[];List<SlotAvail> _slots=[];bool _loading=false;String? _err;
  List<Court> get courts=>_courts; List<Court> get active=>_courts.where((c)=>c.isActive).toList();
  List<SlotAvail> get slots=>_slots; bool get loading=>_loading; String? get err=>_err;
  Future<void> fetch()async{_loading=true;_err=null;notifyListeners();try{_courts=(await api.courts()).map((j)=>Court.fromJson(j)).toList();}on Exception catch(e){_err=e.toString();}finally{_loading=false;notifyListeners();}}
  Future<void> fetchAvail(int id,String d)async{_slots=[];notifyListeners();try{_slots=(await api.avail(id,d)).map((j)=>SlotAvail.fromJson(j)).toList();}catch(_){}notifyListeners();}
  Future<Court?> add(Map<String,dynamic> d)async{try{final j=await api.createCourt(d);final c=Court.fromJson(j);_courts.add(c);notifyListeners();return c;}catch(_){return null;}}
  Future<Court?> update(int id,Map<String,dynamic> d)async{try{final j=await api.updateCourt(id,d);final c=Court.fromJson(j);final i=_courts.indexWhere((x)=>x.id==id);if(i>=0){_courts[i]=c;notifyListeners();}return c;}catch(_){return null;}}
  Future<bool> remove(int id)async{try{await api.deleteCourt(id);_courts.removeWhere((c)=>c.id==id);notifyListeners();return true;}catch(_){return false;}}
}