import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/reservation.dart';
import '../../providers/res_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/group_card.dart';
import 'payment_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override State<MyBookingsScreen> createState() => _S();
}

class _S extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late final _tab = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ResProv>().fetch());
  }

  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) {
    final rp   = ctx.watch<ResProv>();
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    final sw   = MediaQuery.of(ctx).size.width;
    final isSmall = sw < 360;

    return Column(children: [
      Container(
        color: dark ? C.dSurf : C.lSurf,
        child: TabBar(
          controller: _tab,
          labelColor: C.gold,
          unselectedLabelColor: dark ? C.dMu : C.lMu,
          indicatorColor: C.gold,
          dividerColor: dark ? C.dBdr : C.lBdr,
          labelStyle: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            fontSize: isSmall ? 11 : 13),
          tabs: [
            Tab(text: "القادمة (${rp.upcomingGroups.length})"),
            Tab(text: "السابقة (${rp.pastGroups.length})"),
            Tab(text: "الملغاة (${rp.cancelledGroups.length})"),
          ],
        )),
      Expanded(child: rp.loading
        ? const Center(child: CircularProgressIndicator(color: C.gold))
        : TabBarView(controller: _tab, children: [
            _GL(rp.upcomingGroups, showTracker: true, rp: rp),
            _GL(rp.pastGroups),
            _GL(rp.cancelledGroups),
          ])),
    ]);
  }
}

class _GL extends StatelessWidget {
  final List<ReservationGroup> groups;
  final bool showTracker;
  final ResProv? rp;
  const _GL(this.groups, {this.showTracker = false, this.rp});

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    if (groups.isEmpty) return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.event_busy_outlined, size: 56, color: dark ? C.dMu : C.lMu),
      const SizedBox(height: 12),
      Text("لا توجد حجوزات هنا",
        style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 15)),
    ]));

    return RefreshIndicator(
      color: C.gold,
      onRefresh: () => ctx.read<ResProv>().fetch(),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final g = groups[i];
          return GroupCard(g,
            showTracker: showTracker,
            onPay: g.isPendingScreenshot
              ? () => Navigator.push(ctx, MaterialPageRoute(
                  builder: (_) => PaymentScreen.fromGroup(group: g)))
              : null,
            onCancel: g.isPendingScreenshot ? () => _cancel(ctx, g) : null,
          );
        },
      ),
    );
  }

  Future<void> _cancel(BuildContext ctx, ReservationGroup g) async {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    final ok = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: dark ? C.dCard : C.lCard,
      title: Text("إلغاء الحجز؟", style: GoogleFonts.tajawal()),
      content: Text("${g.courtName}\n${g.date}  •  ${g.startTime} – ${g.endTime}",
        style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
          child: Text("لا", style: GoogleFonts.tajawal())),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
          child: Text("نعم، ألغِ", style: GoogleFonts.tajawal(color: C.err))),
      ],
    ));
    if (ok == true && ctx.mounted) await ctx.read<ResProv>().cancelGroup(g.groupId);
  }
}