import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/reservation.dart';
import '../../providers/auth_prov.dart';
import '../../providers/court_prov.dart';
import '../../providers/res_prov.dart';
import '../../providers/theme_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';
import '../../widgets/group_card.dart';
import 'payment_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) goTo;
  const HomeScreen({super.key, required this.goTo});
  @override State<HomeScreen> createState() => _S();
}

class _S extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtProv>().fetch();
      context.read<ResProv>().fetch();
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final user    = ctx.watch<AuthProv>().user!;
    final courts  = ctx.watch<CourtProv>().active;
    final rp      = ctx.watch<ResProv>();
    final dark    = ctx.watch<ThemeProv>().isDark;
    final sw      = MediaQuery.of(ctx).size.width;
    final isSmall = sw < 360;

    final upcomingGroups = rp.upcomingGroups;
    final needsPayment   = upcomingGroups.where((g) => g.isPendingScreenshot).length;
    final waitingAdmin   = upcomingGroups.where((g) => g.isPendingReview).length;

    return RefreshIndicator(
      color: C.gold,
      onRefresh: () async {
        await ctx.read<CourtProv>().fetch();
        await ctx.read<ResProv>().fetch();
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          isSmall ? 12 : 16, 16, isSmall ? 12 : 16, 24),
        children: [

          // ── Header ───────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('مرحباً،',
                style: GoogleFonts.tajawal(
                  color: dark ? C.dMu : C.lMu,
                  fontSize: isSmall ? 12 : 14)),
              Text(user.name,
                style: GoogleFonts.tajawal(
                  fontSize: isSmall ? 18 : 22,
                  fontWeight: FontWeight.w800,
                  color: C.gold),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => ctx.read<ThemeProv>().toggle(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: dark ? C.dCard : C.lCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dark ? C.dBdr : C.lBdr)),
                child: Icon(
                  dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: C.gold, size: isSmall ? 18 : 22)),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Stats ────────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: StatCard(
              label: 'حجوزاتي القادمة',
              value: '${upcomingGroups.length}',
              sub: 'مؤكدة + معلقة',
              color: C.info, icon: Icons.event_available_outlined)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(
              label: 'ملاعب متاحة',
              value: '${courts.length}',
              sub: 'الآن',
              color: C.ok, icon: Icons.sports_tennis_outlined)),
          ]),

          // ── Alert: needs screenshot ───────────────────────────────────────
          if (needsPayment > 0) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => widget.goTo(2),
              child: Container(
                padding: EdgeInsets.all(isSmall ? 10 : 14),
                decoration: BoxDecoration(
                  color: C.pending.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.pending.withOpacity(0.4))),
                child: Row(children: [
                  Icon(Icons.upload_file_outlined,
                    color: C.pending, size: isSmall ? 18 : 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'لديك $needsPayment ${needsPayment == 1 ? "حجز" : "حجوزات"} بانتظار إرسال الإيصال',
                    style: GoogleFonts.tajawal(
                      color: C.pending,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmall ? 11 : 13),
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                  const Icon(Icons.arrow_forward_ios, color: C.pending, size: 12),
                ]),
              ),
            ),
          ],

          // ── Alert: waiting admin ──────────────────────────────────────────
          if (waitingAdmin > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(isSmall ? 10 : 14),
              decoration: BoxDecoration(
                color: C.warn.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.warn.withOpacity(0.4))),
              child: Row(children: [
                Icon(Icons.hourglass_top, color: C.warn, size: isSmall ? 18 : 22),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  '$waitingAdmin ${waitingAdmin == 1 ? "حجز" : "حجوزات"} بانتظار مراجعة الإدارة',
                  style: GoogleFonts.tajawal(
                    color: C.warn,
                    fontWeight: FontWeight.w700,
                    fontSize: isSmall ? 11 : 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          ],

          const SizedBox(height: 20),

          // ── Upcoming bookings ─────────────────────────────────────────────
          SecHead('الحجوزات القادمة',
            action: 'عرض الكل', onAction: () => widget.goTo(2)),
          const SizedBox(height: 12),

          if (upcomingGroups.isEmpty)
            Container(
              decoration: BoxDecoration(
                color: dark ? C.dCard : C.lCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dark ? C.dBdr : C.lBdr)),
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Icon(Icons.event_busy_outlined, size: 44,
                  color: dark ? C.dMu : C.lMu),
                const SizedBox(height: 10),
                Text('لا توجد حجوزات قادمة',
                  style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu),
                  textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => widget.goTo(1),
                  child: Text('احجز الآن', style: GoogleFonts.tajawal())),
              ]))
          else
            ...upcomingGroups.take(2).map((g) => GroupCard(
              g,
              showTracker: true,
              onPay: g.isPendingScreenshot
                ? () => Navigator.push(ctx, MaterialPageRoute(
                    builder: (_) => PaymentScreen.fromGroup(group: g)))
                : null,
              onCancel: g.isPendingScreenshot
                ? () => _confirmCancel(ctx, g, dark)
                : null,
            )),

          const SizedBox(height: 20),

          // ── Available courts ──────────────────────────────────────────────
          SecHead('الملاعب المتاحة',
            action: 'احجز', onAction: () => widget.goTo(1)),
          const SizedBox(height: 12),
          ...courts.map((c) => CourtCard(c, onTap: () => widget.goTo(1))),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext ctx, ReservationGroup g, bool dark) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: dark ? C.dCard : C.lCard,
        title: Text('إلغاء الحجز؟',
          style: GoogleFonts.tajawal(color: dark ? C.dTx : C.lTx)),
        content: Text(
          '${g.courtName}\n${g.date}  •  ${g.startTime} – ${g.endTime}',
          style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('لا', style: GoogleFonts.tajawal())),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: Text('نعم، ألغِ',
              style: GoogleFonts.tajawal(color: C.err))),
        ],
      ),
    );
    if ((ok ?? false) && ctx.mounted) {
      await ctx.read<ResProv>().cancelGroup(g.groupId);
    }
  }
}