import 'package:flutter/material.dart';
import '../models/notif.dart';
import '../services/api.dart';
class NotifProv extends ChangeNotifier{
  List<AppNotif> _items=[];int _unread=0;bool _loading=false;
  List<AppNotif> get items=>_items; int get unread=>_unread; bool get loading=>_loading;
  Future<void> fetch()async{_loading=true;notifyListeners();try{_items=(await api.notifs()).map((j)=>AppNotif.fromJson(j)).toList();_unread=_items.where((n)=>!n.isRead).length;}catch(_){}finally{_loading=false;notifyListeners();}}
  Future<void> fetchCount()async{try{final d=await api.unreadCount();_unread=d['count']??0;notifyListeners();}catch(_){}}
  void addLive(Map<String,dynamic> j){final n=AppNotif.fromJson({...j,'isRead':false});_items.insert(0,n);_unread++;notifyListeners();}
  Future<void> markRead(int id)async{try{await api.markRead(id);_items=_items.map((n)=>n.id==id?AppNotif(id:n.id,title:n.title,body:n.body,type:n.type,isRead:true,reservationId:n.reservationId,createdAt:n.createdAt):n).toList();_unread=_items.where((n)=>!n.isRead).length;notifyListeners();}catch(_){}}
  Future<void> markAll()async{try{await api.markAllRead();_items=_items.map((n)=>AppNotif(id:n.id,title:n.title,body:n.body,type:n.type,isRead:true,reservationId:n.reservationId,createdAt:n.createdAt)).toList();_unread=0;notifyListeners();}catch(_){}}
}