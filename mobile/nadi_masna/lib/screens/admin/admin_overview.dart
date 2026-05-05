import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/reservation.dart';
import '../../providers/court_prov.dart';
import '../../providers/notif_prov.dart';
import '../../providers/res_prov.dart';
import '../../providers/theme_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';

class AdminOverview extends StatelessWidget {
  const AdminOverview({super.key});

  @override
  Widget build(BuildContext ctx) {
    final courts = ctx.watch<CourtProv>().courts;
    final rp     = ctx.watch<ResProv>();
    final np     = ctx.watch<NotifProv>();
    final dark   = ctx.watch<ThemeProv>().isDark;
    final today  = DateTime.now().toIso8601String().substring(0, 10);

    final allGroups       = ReservationGroup.group(rp.all);
    final confirmedGroups = allGroups.where((g) => g.isConfirmed).toList();
    final todayGroups     = confirmedGroups.where((g) => g.date == today).toList();
    final revenue         = confirmedGroups.fold(0.0, (s, g) => s + g.totalPrice);
    final pendingCount    = allGroups.where((g) => g.isPendingReview || g.isPendingScreenshot).length;
    final recentGroups    = allGroups.take(5).toList();

    return RefreshIndicator(
      color: C.gold,
      onRefresh: () async {
        await ctx.read<CourtProv>().fetch();
        await ctx.read<ResProv>().fetch(admin: true);
        await ctx.read<NotifProv>().fetchCount();
      },
      child: ListView(padding: const EdgeInsets.all(16), children: [

        // ── Stats grid ─────────────────────────────────────────────────────
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.45,
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          children: [
            // ← Tappable today card
            GestureDetector(
              onTap: () => _showTodaySheet(ctx, todayGroups, courts, dark),
              child: _StatCardTappable(
                label: 'حجوزات اليوم',
                value: '${todayGroups.length}',
                sub: 'مؤكدة — اضغط للتفاصيل',
                color: C.info,
                icon: Icons.today_outlined,
                hasTap: true,
              ),
            ),
            StatCard(label: 'إجمالي الملاعب',
              value: '${courts.length}',
              sub: '${courts.where((c) => c.isActive).length} نشطة',
              color: C.gold, icon: Icons.sports_tennis_outlined),
            StatCard(label: 'إجمالي الإيرادات',
              value: revenue.toStringAsFixed(0),
              sub: 'جنيه',
              color: C.ok, icon: Icons.attach_money),
            StatCard(label: 'بانتظار المراجعة',
              value: '$pendingCount',
              sub: 'حجز',
              color: C.pending, icon: Icons.pending_actions),
          ],
        ),

        // ── Notification alert ─────────────────────────────────────────────
        if (np.unread > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.gold.withOpacity(0.4))),
            child: Row(children: [
              const Icon(Icons.notifications_active, color: C.gold, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text('لديك ${np.unread} إشعار جديد غير مقروء',
                style: GoogleFonts.tajawal(color: C.gold, fontWeight: FontWeight.w700, fontSize: 14))),
              const Icon(Icons.arrow_forward_ios, color: C.gold, size: 14),
            ]),
          ),
        ],

        // ── Courts status ──────────────────────────────────────────────────
        const SizedBox(height: 24),
        SecHead('حالة الملاعب'),
        const SizedBox(height: 12),
        ...courts.map((c) {
          // Find today's bookings for this court
          final courtToday = todayGroups.where((g) => g.courtName == c.name).toList();
          return GestureDetector(
            onTap: courtToday.isNotEmpty
              ? () => _showCourtTodaySheet(ctx, c.name, c.icon, courtToday, dark)
              : null,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: dark ? C.dCard : C.lCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dark ? C.dBdr : C.lBdr, width: 0.8)),
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                // Court icon with color based on type
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _courtColor(c.type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(c.icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700, color: dark ? C.dTx : C.lTx)),
                  Text('${c.typeAr} · ${c.hourlyRate.toStringAsFixed(0)} جنيه/ساعة',
                    style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 12)),
                  if (courtToday.isNotEmpty)
                    Text('${courtToday.length} حجز اليوم — اضغط للتفاصيل',
                      style: GoogleFonts.tajawal(color: C.info, fontSize: 11, fontWeight: FontWeight.w600)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusBadge(c.status),
                  if (courtToday.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ],
                ]),
              ]),
            ),
          );
        }),

        // ── Recent activity ────────────────────────────────────────────────
        const SizedBox(height: 24),
        SecHead('آخر النشاطات'),
        const SizedBox(height: 12),
        if (recentGroups.isEmpty)
          Center(child: Text('لا توجد نشاطات بعد',
            style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu)))
        else
          ...recentGroups.map((g) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: dark ? C.dCard : C.lCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dark ? C.dBdr : C.lBdr, width: 0.8)),
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _courtColor(g.courtType).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(g.courtIcon, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.userName, style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700, fontSize: 13, color: dark ? C.dTx : C.lTx)),
                Text('${g.courtName}  •  ${g.date}',
                  style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 12)),
                Text('${g.startTime} – ${g.endTime}  •  ${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}',
                  style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                StatusBadge(g.status),
                const SizedBox(height: 4),
                Text('${g.depositAmount.toStringAsFixed(0)} جنيه',
                  style: GoogleFonts.tajawal(
                    color: C.gold, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ]),
          )),

        const SizedBox(height: 8),
      ]),
    );
  }

  // ── Color per court type ───────────────────────────────────────────────────
  Color _courtColor(String type) {
    switch (type) {
      case 'Tennis':     return const Color(0xFF27AE60);
      case 'Padel':      return const Color(0xFF2980B9);
      case 'Squash':     return const Color(0xFFE67E22);
      case 'Basketball': return const Color(0xFFE74C3C);
      case 'Volleyball': return const Color(0xFF8E44AD);
      case 'Badminton':  return const Color(0xFF16A085);
      default:           return C.gold;
    }
  }

  // ── Today's bookings bottom sheet ─────────────────────────────────────────
  void _showTodaySheet(BuildContext ctx, List<ReservationGroup> groups,
      dynamic courts, bool dark) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: dark ? C.dCard : C.lCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _TodaySheet(groups: groups, dark: dark),
    );
  }

  // ── Court-specific today sheet ─────────────────────────────────────────────
  void _showCourtTodaySheet(BuildContext ctx, String courtName, String icon,
      List<ReservationGroup> groups, bool dark) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: dark ? C.dCard : C.lCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _TodaySheet(
        groups: groups, dark: dark,
        title: '$icon $courtName — اليوم'),
    );
  }
}

// ── Today sheet widget ────────────────────────────────────────────────────────
class _TodaySheet extends StatelessWidget {
  final List<ReservationGroup> groups;
  final bool dark;
  final String title;
  const _TodaySheet({required this.groups, required this.dark, this.title = 'حجوزات اليوم'});

  Color _courtColor(String type) {
    switch (type) {
      case 'Tennis':     return const Color(0xFF27AE60);
      case 'Padel':      return const Color(0xFF2980B9);
      case 'Squash':     return const Color(0xFFE67E22);
      case 'Basketball': return const Color(0xFFE74C3C);
      case 'Volleyball': return const Color(0xFF8E44AD);
      case 'Badminton':  return const Color(0xFF16A085);
      default:           return C.gold;
    }
  }

  @override
  Widget build(BuildContext ctx) => DraggableScrollableSheet(
    initialChildSize: 0.6,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    expand: false,
    builder: (_, ctrl) => Column(children: [
      // Handle
      Container(margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: dark ? C.dBdr : C.lBdr, borderRadius: BorderRadius.circular(2))),
      // Title
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child:
        Row(children: [
          Expanded(child: Text(title, style: GoogleFonts.tajawal(
            color: C.gold, fontSize: 18, fontWeight: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: C.info.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text('${groups.length} حجز', style: GoogleFonts.tajawal(
              color: C.info, fontSize: 13, fontWeight: FontWeight.w700))),
        ])),
      const Divider(height: 1),
      // List
      Expanded(child: groups.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.event_available_outlined, size: 52,
              color: dark ? C.dMu : C.lMu),
            const SizedBox(height: 12),
            Text('لا توجد حجوزات اليوم', style: GoogleFonts.tajawal(
              color: dark ? C.dMu : C.lMu, fontSize: 15)),
          ]))
        : ListView.builder(
            controller: ctrl,
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (_, i) {
              final g   = groups[i];
              final col = _courtColor(g.courtType);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: dark ? C.dSurf : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: col.withOpacity(0.3)),
                  boxShadow: [BoxShadow(
                    color: col.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(children: [
                  // Colored header bar
                  Container(
                    decoration: BoxDecoration(
                      color: col.withOpacity(0.12),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(13))),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(children: [
                      Text(g.courtIcon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(g.courtName, style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w800, fontSize: 15,
                        color: dark ? C.dTx : C.lTx))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: col.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text(g.courtType, style: GoogleFonts.roboto(
                          color: col, fontSize: 11, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                  // Details
                  Padding(padding: const EdgeInsets.all(14), child:
                    Column(children: [
                      // Time row
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.access_time, color: col, size: 18)),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${g.startTime} – ${g.endTime}',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w800, fontSize: 16,
                              color: dark ? C.dTx : C.lTx)),
                          Text('${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}',
                            style: GoogleFonts.tajawal(color: col, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                        const Spacer(),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${g.totalPrice.toStringAsFixed(0)} جنيه',
                            style: GoogleFonts.tajawal(
                              color: col, fontWeight: FontWeight.w800, fontSize: 15)),
                          Text('إجمالي', style: GoogleFonts.tajawal(
                            color: dark ? C.dMu : C.lMu, fontSize: 11)),
                        ]),
                      ]),
                      const SizedBox(height: 12),
                      Container(height: 1, color: dark ? C.dBdr : C.lBdr),
                      const SizedBox(height: 12),
                      // Member row
                      Row(children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: col.withOpacity(0.15),
                          child: Text(g.userName.substring(0, 1), style: GoogleFonts.tajawal(
                            color: col, fontWeight: FontWeight.w800, fontSize: 14))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(g.userName, style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700, fontSize: 14, color: dark ? C.dTx : C.lTx)),
                          Text(g.userEmail, style: GoogleFonts.tajawal(
                            color: dark ? C.dMu : C.lMu, fontSize: 11)),
                        ])),
                        StatusBadge(g.status),
                      ]),
                    ])),
                ]),
              );
            })),
    ]),
  );
}

// ── Tappable stat card ────────────────────────────────────────────────────────
class _StatCardTappable extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final IconData icon;
  final bool hasTap;
  const _StatCardTappable({
    required this.label, required this.value, required this.sub,
    required this.color, required this.icon, this.hasTap = false,
  });

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? C.dCard : C.lCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasTap ? color.withOpacity(0.4) : (dark ? C.dBdr : C.lBdr),
          width: hasTap ? 1.2 : 0.8)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 20)),
          Flexible(child: FittedBox(fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(value, style: GoogleFonts.tajawal(
              color: color, fontSize: 22, fontWeight: FontWeight.w800)))),
        ]),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.tajawal(
          fontWeight: FontWeight.w700, fontSize: 13,
          color: dark ? C.dTx : C.lTx),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(sub, style: GoogleFonts.tajawal(color: color, fontSize: 10),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}