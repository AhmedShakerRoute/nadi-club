class Reservation {
  final int id, userId, courtId;
  final String userName, userEmail, userPhone, courtName, courtType;
  final String date, startTime, endTime, status;
  final double totalPrice, depositAmount;
  final bool hasScreenshot;
  final DateTime bookedAt;
  final String? adminNote, groupId;

  const Reservation({
    required this.id, required this.userId, required this.userName,
    required this.userEmail, required this.userPhone, required this.courtId,
    required this.courtName, required this.courtType, required this.date,
    required this.startTime, required this.endTime, required this.status,
    required this.totalPrice, required this.depositAmount,
    required this.hasScreenshot, required this.bookedAt,
    this.adminNote, this.groupId,
  });

  bool get isPendingScreenshot => status == 'pending_screenshot';
  bool get isPendingReview     => status == 'pending_review';
  bool get isConfirmed         => status == 'confirmed';
  bool get isCancelled         => status == 'cancelled';
  bool get isPending           => isPendingScreenshot || isPendingReview;
  bool get depositPaid         => isConfirmed;

  bool get isUpcoming =>
    (isConfirmed || isPendingScreenshot || isPendingReview) &&
    date.compareTo(DateTime.now().toIso8601String().substring(0,10)) >= 0;

  String get statusAr => const {
    'pending_screenshot': 'بانتظار الإيصال 📤',
    'pending_review':     'بانتظار المراجعة ⏳',
    'confirmed':          'مؤكد ✓',
    'cancelled':          'ملغى ✗',
  }[status] ?? status;

  String get icon => const {
    'Tennis':'🎾','Padel':'🏓','Squash':'🟡',
    'Basketball':'🏀','Volleyball':'🏐','Badminton':'🏸',
  }[courtType] ?? '🏟️';

  factory Reservation.fromJson(Map<String,dynamic> j) => Reservation(
    id: j['id'], userId: j['userId'], userName: j['userName'],
    userEmail: j['userEmail'], userPhone: j['userPhone'] ?? '',
    courtId: j['courtId'], courtName: j['courtName'], courtType: j['courtType'],
    date: j['date'], startTime: j['startTime'], endTime: j['endTime'],
    status: j['status'],
    totalPrice: (j['totalPrice'] as num).toDouble(),
    depositAmount: (j['depositAmount'] as num).toDouble(),
    hasScreenshot: j['hasScreenshot'] ?? false,
    bookedAt: DateTime.tryParse(j['bookedAt'] ?? '') ?? DateTime.now(),
    adminNote: j['adminNote'], groupId: j['groupId'],
  );
}

// ── Grouped reservation ───────────────────────────────────────────────────────
class ReservationGroup {
  final List<Reservation> slots;
  const ReservationGroup(this.slots);

  Reservation get first => slots.first;
  Reservation get last  => slots.last;

  String get groupId      => first.groupId ?? '${first.id}';
  String get courtName    => first.courtName;
  String get courtType    => first.courtType;
  String get courtIcon    => first.icon;
  String get userName     => first.userName;
  String get userEmail    => first.userEmail;
  String get userPhone    => first.userPhone;   // ← single definition
  String get date         => first.date;
  String get startTime    => first.startTime;
  String get endTime      => last.endTime;
  int    get hours        => slots.length;
  String get status       => first.status;
  String get statusAr     => first.statusAr;
  bool   get hasScreenshot => first.hasScreenshot;
  String? get adminNote   => first.adminNote;
  DateTime get bookedAt   => first.bookedAt;

  double get totalPrice    => slots.fold(0, (s, r) => s + r.totalPrice);
  double get depositAmount => slots.fold(0, (s, r) => s + r.depositAmount);
  double get remaining     => totalPrice - depositAmount;

  bool get isPendingScreenshot => status == 'pending_screenshot';
  bool get isPendingReview     => status == 'pending_review';
  bool get isConfirmed         => status == 'confirmed';
  bool get isCancelled         => status == 'cancelled';
  bool get isUpcoming =>
    (isConfirmed || isPendingScreenshot || isPendingReview) &&
    date.compareTo(DateTime.now().toIso8601String().substring(0,10)) >= 0;

  List<int> get allIds => slots.map((r) => r.id).toList();

  static List<ReservationGroup> group(List<Reservation> all) {
    final Map<String, List<Reservation>> map = {};
    for (final r in all) {
      final key = r.groupId ?? '${r.id}';
      map.putIfAbsent(key, () => []).add(r);
    }
    return map.values.map((slots) {
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));
      return ReservationGroup(slots);
    }).toList()
      ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
  }
}