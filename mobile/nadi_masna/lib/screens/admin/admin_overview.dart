import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/reservation.dart';
import '../../providers/court_prov.dart';
import '../../providers/notif_prov.dart';
import '../../providers/res_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';

class AdminOverview extends StatelessWidget {
  const AdminOverview({super.key});

  @override
  Widget build(BuildContext ctx) {
    final courts  = ctx.watch<CourtProv>().courts;
    final rp      = ctx.watch<ResProv>();
    final np      = ctx.watch<NotifProv>();
    final dark    = Theme.of(ctx).brightness == Brightness.dark;
    final today   = DateTime.now().toIso8601String().substring(0, 10);
    final sw      = MediaQuery.of(ctx).size.width;
    final isNarrow = sw < 360;

    final allGroups   = ReservationGroup.group(rp.all);
    final confirmed   = allGroups.where((g) => g.isConfirmed).toList();
    final todayCount  = confirmed.where((g) => g.date == today).length;
    final revenue     = confirmed.fold(0.0, (s, g) => s + g.totalPrice);
    final pending     = allGroups.where((g) => g.isPending).length;
    final recentGroups = allGroups.take(5).toList();

    // Stat cards data
    final stats = [
      _StatData('إجمالي الملاعب', '${courts.length}',
        '${courts.where((c) => c.isActive).length} نشطة', C.gold, Icons.sports_tennis_outlined),
      _StatData('حجوزات اليوم', '$todayCount',
        'مؤكدة', C.info, Icons.today_outlined),
      _StatData('إجمالي الإيرادات', revenue.toStringAsFixed(0),
        'جنيه', C.ok, Icons.attach_money),
      _StatData('بانتظار المراجعة', '$pending',
        'حجز', C.pending, Icons.pending_actions),
    ];

    return RefreshIndicator(
      color: C.gold,
      onRefresh: () async {
        await ctx.read<CourtProv>().fetch();
        await ctx.read<ResProv>().fetch(admin: true);
        await ctx.read<NotifProv>().fetchCount();
      },
      child: ListView(padding: const EdgeInsets.all(16), children: [

        // ── Stats — responsive: 1 col on narrow, 2 col on wide ────────────
        isNarrow
          // Narrow: vertical list
          ? Column(children: stats.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StatCard(label: s.label, value: s.value,
                sub: s.sub, color: s.color, icon: s.icon))).toList())
          // Wide: 2x2 grid
          : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: sw < 420 ? 1.3 : 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: stats.map((s) => StatCard(
                label: s.label, value: s.value,
                sub: s.sub, color: s.color, icon: s.icon)).toList()),

        // ── Notification alert ─────────────────────────────────────────────
        if (np.unread > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.gold.withOpacity(0.4))),
            child: Row(children: [
              const Icon(Icons.notifications_active, color: C.gold, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text('لديك ${np.unread} إشعار جديد غير مقروء',
                style: GoogleFonts.tajawal(
                  color: C.gold, fontWeight: FontWeight.w700, fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ],

        // ── Courts status ──────────────────────────────────────────────────
        const SizedBox(height: 20),
        SecHead('حالة الملاعب'),
        const SizedBox(height: 12),
        ...courts.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: dark ? C.dCard : C.lCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dark ? C.dBdr : C.lBdr, width: 0.8)),
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Text(c.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name,
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700,
                  color: dark ? C.dTx : C.lTx),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${c.typeAr} · ${c.hourlyRate.toStringAsFixed(0)} جنيه/ساعة',
                style: GoogleFonts.tajawal(
                  color: dark ? C.dMu : C.lMu, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            StatusBadge(c.status),
          ]),
        )),

        // ── Recent activity ────────────────────────────────────────────────
        const SizedBox(height: 20),
        SecHead('آخر النشاطات'),
        const SizedBox(height: 12),
        ...recentGroups.map((g) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: dark ? C.dCard : C.lCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dark ? C.dBdr : C.lBdr, width: 0.8)),
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Text(g.courtIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.userName,
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700, fontSize: 13,
                  color: dark ? C.dTx : C.lTx),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${g.courtName}  •  ${g.date}',
                style: GoogleFonts.tajawal(
                  color: dark ? C.dMu : C.lMu, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${g.startTime} – ${g.endTime}  •  ${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}',
                style: GoogleFonts.tajawal(
                  color: dark ? C.dMu : C.lMu, fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis),
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

        const SizedBox(height: 16),
      ]),
    );
  }
}

class _StatData {
  final String label, value, sub;
  final Color color;
  final IconData icon;
  const _StatData(this.label, this.value, this.sub, this.color, this.icon);
}