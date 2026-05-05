import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/api.dart';

class ResProv extends ChangeNotifier {
  List<Reservation> _all = [];
  bool _loading = false;
  String? _err;

  List<Reservation> get all => _all;
  bool get loading => _loading;
  String? get err => _err;

  List<Reservation> get upcoming =>
    _all.where((r) => r.isUpcoming).toList()..sort((a, b) => a.date.compareTo(b.date));
  List<Reservation> get past =>
    _all.where((r) => r.isConfirmed && !r.isUpcoming).toList()..sort((a, b) => b.date.compareTo(a.date));
  List<Reservation> get cancelled =>
    _all.where((r) => r.isCancelled).toList()..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));

  List<ReservationGroup> get groups => ReservationGroup.group(_all);

  List<ReservationGroup> get upcomingGroups =>
    groups.where((g) => g.isUpcoming).toList()..sort((a, b) => a.date.compareTo(b.date));
  List<ReservationGroup> get pastGroups =>
    groups.where((g) => g.isConfirmed && !g.isUpcoming).toList()..sort((a, b) => b.date.compareTo(a.date));
  List<ReservationGroup> get cancelledGroups =>
    groups.where((g) => g.isCancelled).toList()..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
  List<ReservationGroup> get pendingGroups =>
    groups.where((g) => g.isPendingReview || g.isPendingScreenshot).toList()
      ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
  List<ReservationGroup> get confirmedGroups =>
    groups.where((g) => g.isConfirmed && g.isUpcoming).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

  Future<void> fetch({bool admin = false}) async {
    _loading = true; _err = null; notifyListeners();
    try {
      _all = (admin ? await api.allRes() : await api.myRes())
          .map((j) => Reservation.fromJson(j)).toList();
    } on ApiErr catch (e) { _err = e.msg; }
    catch (_) { _err = 'فشل تحميل الحجوزات'; }
    finally { _loading = false; notifyListeners(); }
  }

  Future<Reservation?> create(int cId, String date, String start) async {
    try {
      final j = await api.createRes(cId, date, start);
      final r = Reservation.fromJson(j);
      _all.insert(0, r);
      notifyListeners();
      return r;
    } on ApiErr catch (e) { _err = e.msg; notifyListeners(); return null; }
  }

  Future<List<Reservation>> createMulti(int cId, String date, String startTime, int hours) async {
    final groupId = hours > 1
      ? '${cId}_${date}_${startTime}_${DateTime.now().millisecondsSinceEpoch}'
      : null;
    final List<Reservation> created = [];
    for (int i = 0; i < hours; i++) {
      final h    = int.parse(startTime.split(':')[0]) + i;
      final slot = '${h.toString().padLeft(2, '0')}:00';
      try {
        final j = await api.createRes(cId, date, slot, groupId: groupId);
        final r = Reservation.fromJson(j);
        _all.insert(0, r);
        created.add(r);
      } on ApiErr catch (e) { _err = e.msg; break; }
    }
    notifyListeners();
    return created;
  }

  void updateStatus(int id, String status) {
    final i = _all.indexWhere((r) => r.id == id);
    if (i < 0) return;
    final r = _all[i];
    _all[i] = Reservation(
      id: r.id, userId: r.userId, userName: r.userName,
      userEmail: r.userEmail, userPhone: r.userPhone,   // ← added
      courtId: r.courtId, courtName: r.courtName, courtType: r.courtType,
      date: r.date, startTime: r.startTime, endTime: r.endTime,
      status: status, totalPrice: r.totalPrice,
      depositAmount: r.depositAmount,
      hasScreenshot: r.hasScreenshot || status == 'pending_review',
      bookedAt: r.bookedAt, adminNote: r.adminNote, groupId: r.groupId,
    );
    notifyListeners();
  }

  void updateGroupStatus(String groupId, String status) {
    for (int i = 0; i < _all.length; i++) {
      if ((_all[i].groupId ?? '${_all[i].id}') == groupId) {
        final r = _all[i];
        _all[i] = Reservation(
          id: r.id, userId: r.userId, userName: r.userName,
          userEmail: r.userEmail, userPhone: r.userPhone,   // ← added
          courtId: r.courtId, courtName: r.courtName, courtType: r.courtType,
          date: r.date, startTime: r.startTime, endTime: r.endTime,
          status: status, totalPrice: r.totalPrice,
          depositAmount: r.depositAmount,
          hasScreenshot: r.hasScreenshot || status == 'pending_review',
          bookedAt: r.bookedAt, adminNote: r.adminNote, groupId: r.groupId,
        );
      }
    }
    notifyListeners();
  }

  Future<void> adminReview(int id, String action, {String? note}) async {
    await api.adminReview(id, action, note: note);
    await fetch(admin: true);
  }

  Future<void> adminReviewGroup(String groupId, String action, {String? note}) async {
    await api.adminReviewGroup(groupId, action, note: note);
    await fetch(admin: true);
  }

  Future<bool> cancel(int id) async {
    try {
      await api.cancelRes(id);
      updateStatus(id, 'cancelled');
      return true;
    } catch (_) { return false; }
  }

  Future<bool> cancelGroup(String groupId) async {
    try {
      await api.cancelGroup(groupId);
      updateGroupStatus(groupId, 'cancelled');
      return true;
    } catch (_) { return false; }
  }
}