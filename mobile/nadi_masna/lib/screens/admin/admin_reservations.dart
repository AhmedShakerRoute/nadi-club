import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/reservation.dart';
import '../../providers/res_prov.dart';
import '../../services/api.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';
import '../../widgets/group_card.dart';

class AdminReservations extends StatefulWidget {
  const AdminReservations({super.key});
  @override State<AdminReservations> createState() => _S();
}

class _S extends State<AdminReservations> with SingleTickerProviderStateMixin {
  // ── 5 tabs now ────────────────────────────────────────────────────────────
  late final _tab = TabController(length: 5, vsync: this);
  String _q = '';
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) {
    final rp   = ctx.watch<ResProv>();
    final dark = Theme.of(ctx).brightness == Brightness.dark;

    final allGroups = ReservationGroup.group(rp.all);

    List<ReservationGroup> f(List<ReservationGroup> l) => _q.isEmpty ? l
      : l.where((g) =>
          g.userName.toLowerCase().contains(_q.toLowerCase()) ||
          g.courtName.toLowerCase().contains(_q.toLowerCase()) ||
          g.date.contains(_q)).toList();

    // ── Separated into 5 lists ─────────────────────────────────────────────
    final waitingScreenshot = f(allGroups.where((g) => g.isPendingScreenshot).toList());
    final waitingReview     = f(allGroups.where((g) => g.isPendingReview).toList());
    final confirmed         = f(allGroups.where((g) => g.isConfirmed && g.isUpcoming).toList());
    final past              = f(allGroups.where((g) => g.isConfirmed && !g.isUpcoming).toList());
    final cancelled         = f(allGroups.where((g) => g.isCancelled).toList());

    return Column(children: [
      // Search bar
      Container(
        color: dark ? C.dSurf : C.lSurf,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'بحث باسم العضو أو الملعب...',
            prefixIcon: const Icon(Icons.search, color: C.gold, size: 20),
            fillColor: dark ? C.dCard : C.lCard,
            contentPadding: const EdgeInsets.symmetric(vertical: 8)),
          onChanged: (v) => setState(() => _q = v),
        ),
      ),
      // ── 5 Tabs ─────────────────────────────────────────────────────────
      TabBar(
        controller: _tab,
        labelColor: C.gold,
        unselectedLabelColor: dark ? C.dMu : C.lMu,
        indicatorColor: C.gold,
        dividerColor: dark ? C.dBdr : C.lBdr,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: [
          Tab(text: '📤 بانتظار الإيصال (${waitingScreenshot.length})'),
          Tab(text: '⏳ بانتظار المراجعة (${waitingReview.length})'),
          Tab(text: '✓ مؤكدة (${confirmed.length})'),
          Tab(text: '📋 سابقة (${past.length})'),
          Tab(text: '✗ ملغاة (${cancelled.length})'),
        ],
      ),
      Expanded(child: rp.loading
        ? const Center(child: CircularProgressIndicator(color: C.gold))
        : TabBarView(controller: _tab, children: [
            _GroupList(waitingScreenshot, showActions: false, rp: rp),
            _GroupList(waitingReview,     showActions: true,  rp: rp),
            _GroupList(confirmed,         showActions: false, rp: rp),
            _GroupList(past,              showActions: false, rp: rp),
            _GroupList(cancelled,         showActions: false, rp: rp),
          ])),
    ]);
  }
}

// ── List of group cards ────────────────────────────────────────────────────────
class _GroupList extends StatelessWidget {
  final List<ReservationGroup> groups;
  final bool showActions;
  final ResProv rp;
  const _GroupList(this.groups, {required this.showActions, required this.rp});

  @override
  Widget build(BuildContext ctx) => groups.isEmpty
    ? const EmptyV(icon: Icons.list_alt_outlined, msg: 'لا توجد سجلات')
    : RefreshIndicator(
        color: C.gold,
        onRefresh: () => ctx.read<ResProv>().fetch(admin: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: groups.length,
          itemBuilder: (_, i) => _AdminGroupCard(
            group: groups[i], showActions: showActions, rp: rp),
        ),
      );
}

// ── Admin group card ──────────────────────────────────────────────────────────
class _AdminGroupCard extends StatelessWidget {
  final ReservationGroup group;
  final bool showActions;
  final ResProv rp;
  const _AdminGroupCard({required this.group, required this.showActions, required this.rp});

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    final g    = group;

    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => _DetailPage(group: g, rp: rp))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: dark ? C.dCard : C.lCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: g.isPendingReview
              ? C.gold.withOpacity(0.6)
              : g.isPendingScreenshot
                ? C.pending.withOpacity(0.5)
                : (dark ? C.dBdr : C.lBdr),
            width: (g.isPendingReview || g.isPendingScreenshot) ? 1.5 : 0.8)),
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: C.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(g.courtIcon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(g.courtName, style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w700, fontSize: 15, color: dark ? C.dTx : C.lTx)),
            Text(g.userName, style: GoogleFonts.tajawal(
              color: dark ? C.dMu : C.lMu, fontSize: 13)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: C.info.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(
                '${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}  •  ${g.startTime} – ${g.endTime}  •  ${g.date}',
                style: GoogleFonts.tajawal(
                  color: C.info, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(g.status),
            const SizedBox(height: 6),
            Text('${g.depositAmount.toStringAsFixed(0)} جنيه',
              style: GoogleFonts.tajawal(
                color: C.gold, fontSize: 13, fontWeight: FontWeight.w700)),
            if (g.hasScreenshot) ...[
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.image_outlined, color: C.ok, size: 13),
                const SizedBox(width: 3),
                Text('إيصال مرسل', style: GoogleFonts.tajawal(color: C.ok, fontSize: 10)),
              ]),
            ],
          ]),
        ]),
      ),
    );
  }
}

// ═══ Detail Page ══════════════════════════════════════════════════════════════
class _DetailPage extends StatefulWidget {
  final ReservationGroup group;
  final ResProv rp;
  const _DetailPage({required this.group, required this.rp});
  @override State<_DetailPage> createState() => _DetailState();
}

class _DetailState extends State<_DetailPage> {
  String? _screenshotBase64;
  bool _loadingShot = false;
  bool _reviewing   = false;

  ReservationGroup get g => widget.group;

  @override
  void initState() {
    super.initState();
    if (g.hasScreenshot) _loadShot();
  }

  Future<void> _loadShot() async {
    setState(() => _loadingShot = true);
    try {
      final data = await api.getScreenshot(g.first.id);
      setState(() => _screenshotBase64 = data['screenshot'] as String);
    } catch (_) {}
    setState(() => _loadingShot = false);
  }

  Future<void> _review(String action) async {
    String? note;
    if (action == 'reject') {
      final dark = Theme.of(context).brightness == Brightness.dark;
      final ctrl = TextEditingController();
      note = await showDialog<String>(context: context,
        builder: (_) => AlertDialog(
          backgroundColor: dark ? C.dCard : C.lCard,
          title: Text('سبب الرفض (اختياري)', style: GoogleFonts.tajawal()),
          content: TextField(controller: ctrl,
            decoration: const InputDecoration(hintText: 'الإيصال غير واضح...')),
          actions: [TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: Text('رفض', style: GoogleFonts.tajawal(color: C.err)))],
        ));
    }
    setState(() => _reviewing = true);
    if (g.slots.length > 1 && g.first.groupId != null) {
      await widget.rp.adminReviewGroup(g.first.groupId!, action, note: note);
    } else {
      await widget.rp.adminReview(g.first.id, action, note: note);
    }
    setState(() => _reviewing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(action == 'confirm' ? 'تم تأكيد الحجز ✓' : 'تم رفض الحجز',
          style: GoogleFonts.tajawal()),
        backgroundColor: action == 'confirm' ? C.ok : C.err));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الحجز', style: GoogleFonts.tajawal()),
        actions: [StatusBadge(g.status), const SizedBox(width: 12)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          _Card(dark, icon: g.courtIcon, title: g.courtName, subtitle: g.courtType,
            color: C.gold, rows: [
              _row(ctx, '📅 التاريخ', g.date, dark),
              _row(ctx, '🕐 من',      g.startTime, dark),
              _row(ctx, '🕐 إلى',     g.endTime, dark),
              _row(ctx, '⏱ المدة',
                '${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}', dark),
              _row(ctx, '💰 الإجمالي',
                '${g.totalPrice.toStringAsFixed(0)} جنيه', dark),
              _row(ctx, '💳 الدفعة (25%)',
                '${g.depositAmount.toStringAsFixed(0)} جنيه', dark, vc: C.gold),
            ]),
          const SizedBox(height: 12),

          _Card(dark, icon: '👤', title: g.userName, subtitle: g.userEmail,
            color: C.info, rows: [
              _row(ctx, '📧 البريد',  g.userEmail, dark),
              _row(ctx, '📱 الهاتف',
                g.userPhone.isEmpty ? 'غير محدد' : g.userPhone, dark),
              _row(ctx, '📆 تاريخ الطلب',
                '${g.bookedAt.day}/${g.bookedAt.month}/${g.bookedAt.year}', dark),
              _row(ctx, '🔢 عدد الساعات',
                '${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}', dark),
            ]),
          const SizedBox(height: 12),

          _Card(dark, icon: '💳', title: 'حالة الدفع',
            subtitle: g.hasScreenshot ? 'تم إرسال الإيصال' : 'لم يُرسل الإيصال',
            color: g.hasScreenshot ? C.ok : C.warn, rows: [
              _row(ctx, 'الإيصال',
                g.hasScreenshot ? 'مرسل ✓' : 'لم يُرسل بعد', dark,
                vc: g.hasScreenshot ? C.ok : C.warn),
              _row(ctx, 'الحالة', g.statusAr, dark),
              if (g.adminNote != null && g.adminNote!.isNotEmpty)
                _row(ctx, 'ملاحظة', g.adminNote!, dark, vc: C.err),
            ]),
          const SizedBox(height: 12),

          if (g.hasScreenshot)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: dark ? C.dCard : C.lCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dark ? C.dBdr : C.lBdr)),
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.image_outlined, color: C.gold, size: 20),
                  const SizedBox(width: 8),
                  Text('إيصال التحويل', style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: dark ? C.dTx : C.lTx)),
                ]),
                const SizedBox(height: 12),
                if (_loadingShot)
                  const Center(child: CircularProgressIndicator(color: C.gold))
                else if (_screenshotBase64 != null)
                  ClipRRect(borderRadius: BorderRadius.circular(10),
                    child: Image.memory(base64Decode(_screenshotBase64!),
                      width: double.infinity, fit: BoxFit.contain))
                else
                  Center(child: Text('تعذر تحميل الإيصال',
                    style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu))),
              ])),

          const SizedBox(height: 16),

          if (g.isPendingReview) ...[
            if (_reviewing)
              const Center(child: CircularProgressIndicator(color: C.gold))
            else
              Column(children: [
                SizedBox(width: double.infinity, height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _review('confirm'),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text('تأكيد الحجز وإغلاق الموعد',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.ok, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))))),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _review('reject'),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text('رفض الحجز',
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: C.err, side: const BorderSide(color: C.err),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))))),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: C.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: C.info.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: C.info, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'عند التأكيد سيُغلق الموعد لمدة ${g.hours} '
                      '${g.hours == 1 ? "ساعة" : "ساعات"} ولن يتمكن أحد من حجزه',
                      style: GoogleFonts.tajawal(color: C.info, fontSize: 13))),
                  ])),
              ]),
          ],

          if (g.isConfirmed)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.ok.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.ok.withOpacity(0.4))),
              child: Row(children: [
                const Icon(Icons.check_circle, color: C.ok, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text('تم تأكيد هذا الحجز — الموعد محجوز ومغلق',
                  style: GoogleFonts.tajawal(color: C.ok, fontWeight: FontWeight.w700))),
              ])),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _row(BuildContext ctx, String l, String v, bool dark, {Color? vc}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 13)),
        Text(v, style: GoogleFonts.tajawal(
          color: vc ?? (dark ? C.dTx : C.lTx),
          fontWeight: FontWeight.w600, fontSize: 13)),
      ]));
}

// ── Reusable section card ─────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final bool dark;
  final String icon, title, subtitle;
  final Color color;
  final List<Widget> rows;
  const _Card(this.dark, {required this.icon, required this.title,
    required this.subtitle, required this.color, required this.rows});

  @override
  Widget build(BuildContext ctx) => Container(
    decoration: BoxDecoration(
      color: dark ? C.dCard : C.lCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: dark ? C.dBdr : C.lBdr)),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 42, height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 22)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700, fontSize: 15, color: dark ? C.dTx : C.lTx)),
          Text(subtitle, style: GoogleFonts.tajawal(
            color: dark ? C.dMu : C.lMu, fontSize: 12)),
        ])),
      ]),
      const SizedBox(height: 12),
      const Divider(),
      const SizedBox(height: 8),
      ...rows,
    ]));
}