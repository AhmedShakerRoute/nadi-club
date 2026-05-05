import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/court.dart';
import '../../models/reservation.dart';
import '../../providers/court_prov.dart';
import '../../providers/res_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';
import 'payment_screen.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});
  @override State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  int _step = 0;
  Court? _court;
  DateTime _date = DateTime.now();
  String? _startTime;
  int _hours = 1;
  List<Reservation> _booked = [];
  bool _saving = false;

  String get _ds =>
    '${_date.year}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}';

  bool get _isToday {
    final now = DateTime.now();
    return _date.year == now.year && _date.month == now.month && _date.day == now.day;
  }

  List<SlotAvail> get _filteredSlots {
    final slots = context.read<CourtProv>().slots;
    if (!_isToday) return slots;
    final next = DateTime.now().hour + 1;
    return slots.where((s) {
      final h = int.tryParse(s.hour.split(':')[0]) ?? 0;
      return h >= next;
    }).toList();
  }

  int _maxHours(String start) {
    final slots = context.read<CourtProv>().slots;
    final startH = int.parse(start.split(':')[0]);
    int max = 0;
    for (final s in slots) {
      final h = int.parse(s.hour.split(':')[0]);
      if (h < startH) continue;
      if (s.avail) max++;
      else break;
    }
    return max.clamp(1, 5);
  }

  String _endTime(String start, int hours) {
    final h = int.parse(start.split(':')[0]) + hours;
    return '${h.toString().padLeft(2,'0')}:00';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CourtProv>().fetch());
  }

  void _reset() => setState(() {
    _step = 0; _court = null; _startTime = null; _hours = 1; _booked = [];
  });

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;

    // Done — go to payment
    if (_step == 4 && _booked.isNotEmpty) {
      return _DoneView(
        reservations: _booked,
        onPay: () => Navigator.push(ctx, MaterialPageRoute(
          // ✅ FIXED: use PaymentScreen.fromGroup with ReservationGroup
          builder: (_) => PaymentScreen.fromGroup(group: ReservationGroup(_booked))))
            .then((_) => _reset()),
        onAnother: _reset,
      );
    }

    final steps = ['اختر الملعب', 'اختر التاريخ', 'اختر الوقت والمدة', 'تأكيد الحجز'];

    return Column(children: [
      Container(
        color: dark ? C.dSurf : C.lSurf,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('حجز ملعب', style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w800, color: C.gold)),
          const SizedBox(height: 10),
          Row(children: List.generate(4, (i) => Expanded(child: Container(
            height: 4, margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i <= _step ? C.gold : (dark ? C.dBdr : C.lBdr),
              borderRadius: BorderRadius.circular(2)))))),
          const SizedBox(height: 6),
          Text('الخطوة ${_step+1} من 4 – ${steps[_step.clamp(0,3)]}',
            style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 12)),
        ]),
      ),

      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (_step == 0) _Step1(onSel: (c) { setState(() { _court = c; _step = 1; }); }),
          if (_step == 1) _Step2(
            court: _court!, date: _date,
            onPickDate: () async {
              final d = await showDatePicker(
                context: ctx, initialDate: _date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                builder: (c, w) => Theme(
                  data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(primary: C.gold, surface: C.dCard)),
                  child: w!));
              if (d != null) {
                setState(() { _date = d; _startTime = null; _hours = 1; });
                await ctx.read<CourtProv>().fetchAvail(_court!.id, _ds);
                setState(() => _step = 2);
              }
            },
            onBack: () => setState(() => _step = 0),
          ),
          if (_step == 2) _Step3(
            slots: _filteredSlots,
            selTime: _startTime,
            hours: _hours,
            maxHours: _startTime != null ? _maxHours(_startTime!) : 1,
            isToday: _isToday,
            endTime: _startTime != null ? _endTime(_startTime!, _hours) : '',
            onSel: (t) => setState(() { _startTime = t; _hours = 1; }),
            onHoursChanged: (h) => setState(() => _hours = h),
            onBack: () => setState(() => _step = 1),
            onNext: () => setState(() => _step = 3),
          ),
          if (_step == 3) _Step4(
            court: _court!, date: _ds, startTime: _startTime!,
            hours: _hours, loading: _saving,
            endTime: _endTime(_startTime!, _hours),
            onBack: () => setState(() => _step = 2),
            onConfirm: () async {
              setState(() => _saving = true);
              final created = await ctx.read<ResProv>().createMulti(
                _court!.id, _ds, _startTime!, _hours);
              setState(() => _saving = false);
              if (created.isNotEmpty) {
                setState(() { _booked = created; _step = 4; });
              } else if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(ctx.read<ResProv>().err ?? 'موعد غير متاح',
                    style: GoogleFonts.tajawal()),
                  backgroundColor: C.err, behavior: SnackBarBehavior.floating));
              }
            },
          ),
        ]),
      )),
    ]);
  }
}

class _Step1 extends StatelessWidget {
  final void Function(Court) onSel;
  const _Step1({required this.onSel});
  @override
  Widget build(BuildContext ctx) {
    final cp = ctx.watch<CourtProv>();
    if (cp.loading) return const Center(child: CircularProgressIndicator(color: C.gold));
    if (cp.active.isEmpty) return const EmptyV(icon: Icons.sports_tennis, msg: 'لا توجد ملاعب متاحة');
    return Column(children: cp.active.map((c) => CourtCard(c, onTap: () => onSel(c))).toList());
  }
}

class _Step2 extends StatelessWidget {
  final Court court;
  final DateTime date;
  final VoidCallback onPickDate, onBack;
  const _Step2({required this.court, required this.date, required this.onPickDate, required this.onBack});

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Column(children: [
      CourtCard(court, sel: true),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: dark ? C.dCard : C.lCard,
          borderRadius: BorderRadius.circular(16), border: Border.all(color: dark ? C.dBdr : C.lBdr)),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Icon(Icons.calendar_month_outlined, color: C.gold, size: 44),
          const SizedBox(height: 10),
          Text('متى تريد اللعب؟', style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700, fontSize: 16, color: dark ? C.dTx : C.lTx)),
          const SizedBox(height: 6),
          Text('${date.day}/${date.month}/${date.year}',
            style: GoogleFonts.tajawal(color: C.gold, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GoldBtn(text: 'اختر التاريخ', onTap: onPickDate, icon: Icons.date_range),
        ]),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: onBack,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: dark ? C.dBdr : C.lBdr),
          foregroundColor: dark ? C.dTx : C.lTx),
        child: Text('→ رجوع', style: GoogleFonts.tajawal())),
    ]);
  }
}

class _Step3 extends StatelessWidget {
  final List<SlotAvail> slots;
  final String? selTime;
  final int hours, maxHours;
  final bool isToday;
  final String endTime;
  final void Function(String) onSel;
  final void Function(int) onHoursChanged;
  final VoidCallback onBack, onNext;
  const _Step3({
    required this.slots, this.selTime, required this.hours,
    required this.maxHours, required this.isToday, required this.endTime,
    required this.onSel, required this.onHoursChanged,
    required this.onBack, required this.onNext,
  });

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Column(children: [
      if (isToday) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: C.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.info.withOpacity(0.3))),
          child: Row(children: [
            const Icon(Icons.access_time, color: C.info, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text('تعرض المواعيد المتاحة من الساعة القادمة فصاعداً',
              style: GoogleFonts.tajawal(color: C.info, fontSize: 13))),
          ])),
        const SizedBox(height: 12),
      ],

      if (slots.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: dark ? C.dCard : C.lCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dark ? C.dBdr : C.lBdr)),
          child: Column(children: [
            const Icon(Icons.event_busy, color: C.warn, size: 40),
            const SizedBox(height: 10),
            Text('لا توجد مواعيد متاحة',
              style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 15)),
            Text('اختر تاريخاً آخر',
              style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 13)),
          ]))
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: 2.2,
            crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: slots.length,
          itemBuilder: (ctx, i) {
            final s = slots[i];
            final sel = selTime == s.hour;
            return GestureDetector(
              onTap: s.avail ? () => onSel(s.hour) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: sel ? C.gold
                    : s.avail ? (dark ? C.dCard : C.lCard)
                    : C.err.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? C.gold
                      : s.avail ? (dark ? C.dBdr : C.lBdr)
                      : C.err.withOpacity(0.3),
                    width: sel ? 2 : 0.8)),
                child: Center(child: Text(s.hour, style: GoogleFonts.tajawal(
                  color: sel ? C.dBg
                    : s.avail ? (dark ? C.dTx : C.lTx)
                    : C.err.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w800 : FontWeight.normal,
                  decoration: s.avail ? null : TextDecoration.lineThrough)))));
          }),

      // Hours selector
      if (selTime != null) ...[
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: dark ? C.dCard : C.lCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.gold.withOpacity(0.4))),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.timer_outlined, color: C.gold, size: 20),
              const SizedBox(width: 8),
              Text('عدد الساعات', style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w700, fontSize: 15, color: dark ? C.dTx : C.lTx)),
              const Spacer(),
              Text('$hours ${hours == 1 ? "ساعة" : "ساعات"}',
                style: GoogleFonts.tajawal(color: C.gold, fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            const SizedBox(height: 12),
            Row(children: List.generate(maxHours, (i) {
              final h = i + 1;
              final sel = hours == h;
              return Expanded(child: GestureDetector(
                onTap: () => onHoursChanged(h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? C.gold : (dark ? C.dSurf : C.lBg),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? C.gold : (dark ? C.dBdr : C.lBdr),
                      width: sel ? 2 : 0.8)),
                  child: Center(child: Text('$h',
                    style: GoogleFonts.tajawal(
                      color: sel ? C.dBg : (dark ? C.dTx : C.lTx),
                      fontWeight: sel ? FontWeight.w800 : FontWeight.normal,
                      fontSize: 16))))));
            })),
            const SizedBox(height: 8),
            Center(child: Text('من $selTime إلى $endTime',
              style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 13))),
          ])),
      ],

      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: onBack,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: BorderSide(color: dark ? C.dBdr : C.lBdr),
            foregroundColor: dark ? C.dTx : C.lTx),
          child: Text('→ رجوع', style: GoogleFonts.tajawal()))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: selTime != null ? onNext : null,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          child: Text('التالي ←', style: GoogleFonts.tajawal(fontWeight: FontWeight.w700)))),
      ]),
    ]);
  }
}

class _Step4 extends StatelessWidget {
  final Court court;
  final String date, startTime, endTime;
  final int hours;
  final bool loading;
  final VoidCallback onBack, onConfirm;
  const _Step4({
    required this.court, required this.date, required this.startTime,
    required this.endTime, required this.hours, required this.loading,
    required this.onBack, required this.onConfirm,
  });

  @override
  Widget build(BuildContext ctx) {
    final dark    = Theme.of(ctx).brightness == Brightness.dark;
    final total   = court.hourlyRate * hours;
    final deposit = total * 0.25;
    return Column(children: [
      Container(
        decoration: BoxDecoration(
          color: C.gold.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.gold.withOpacity(0.25))),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ملخص الحجز', style: GoogleFonts.tajawal(
            color: C.gold, fontSize: 20, fontWeight: FontWeight.w800)),
          const Divider(height: 20),
          for (final row in [
            ['الملعب',       '${court.icon} ${court.name}'],
            ['النوع',        court.typeAr],
            ['التاريخ',      date],
            ['من',           startTime],
            ['إلى',          endTime],
            ['المدة',        '$hours ${hours == 1 ? "ساعة" : "ساعات"}'],
            ['سعر الساعة',   '${court.hourlyRate.toStringAsFixed(0)} جنيه'],
            ['إجمالي السعر', '${total.toStringAsFixed(0)} جنيه'],
          ])
            Padding(padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(row[0], style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 13)),
                Text(row[1], style: GoogleFonts.tajawal(color: dark ? C.dTx : C.lTx, fontSize: 13)),
              ])),
          const Divider(),
          Padding(padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('الدفعة المقدمة (25%)', style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w800, fontSize: 15, color: dark ? C.dTx : C.lTx)),
              Text('${deposit.toStringAsFixed(0)} جنيه', style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w800, fontSize: 17, color: C.gold)),
            ])),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: C.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.info_outline, color: C.info, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'الباقي (${(total - deposit).toStringAsFixed(0)} جنيه) يُدفع عند الحضور',
                style: GoogleFonts.tajawal(color: C.info, fontSize: 12))),
            ])),
        ])),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: onBack,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: dark ? C.dBdr : C.lBdr),
            foregroundColor: dark ? C.dTx : C.lTx),
          child: Text('→ رجوع', style: GoogleFonts.tajawal()))),
        const SizedBox(width: 12),
        Expanded(child: GoldBtn(
          text: 'تأكيد الحجز ←', onTap: onConfirm, loading: loading, icon: Icons.check)),
      ]),
    ]);
  }
}

class _DoneView extends StatelessWidget {
  final List<Reservation> reservations;
  final VoidCallback onPay, onAnother;
  const _DoneView({required this.reservations, required this.onPay, required this.onAnother});

  @override
  Widget build(BuildContext ctx) {
    final main    = reservations.first;
    final hours   = reservations.length;
    final total   = reservations.fold(0.0, (s, r) => s + r.totalPrice);
    final deposit = reservations.fold(0.0, (s, r) => s + r.depositAmount);
    final end     = reservations.last.endTime;
    final dark    = Theme.of(ctx).brightness == Brightness.dark;

    return Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(
            color: C.pending.withOpacity(0.15), borderRadius: BorderRadius.circular(40)),
          child: const Icon(Icons.schedule, color: C.pending, size: 48)),
        const SizedBox(height: 20),
        Text('تم إنشاء الحجز!', style: GoogleFonts.tajawal(
          fontSize: 22, fontWeight: FontWeight.w800, color: C.gold),
          textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('${main.courtName}\n${main.startTime} – $end  •  $hours ${hours == 1 ? "ساعة" : "ساعات"}',
          style: GoogleFonts.tajawal(fontSize: 14, color: dark ? C.dMu : C.lMu),
          textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text('إجمالي: ${total.toStringAsFixed(0)} جنيه  •  مقدم: ${deposit.toStringAsFixed(0)} جنيه',
          style: GoogleFonts.tajawal(color: C.gold, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 24),
        GoldBtn(
          text: 'ادفع الآن – ${deposit.toStringAsFixed(0)} جنيه',
          onTap: onPay, icon: Icons.payment),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onAnother,
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          child: Text('حجز ملعب آخر', style: GoogleFonts.tajawal())),
      ])));
  }
}