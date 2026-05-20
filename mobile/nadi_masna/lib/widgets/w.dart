import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import '../models/court.dart';
import '../models/reservation.dart';
import '../models/notif.dart';

bool _dark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;
Color _tx(BuildContext ctx)   => _dark(ctx) ? C.dTx  : C.lTx;
Color _mu(BuildContext ctx)   => _dark(ctx) ? C.dMu  : C.lMu;
Color _card(BuildContext ctx) => _dark(ctx) ? C.dCard : C.lCard;
Color _bdr(BuildContext ctx)  => _dark(ctx) ? C.dBdr  : C.lBdr;
Color _surf(BuildContext ctx) => _dark(ctx) ? C.dSurf : C.lBg;

// Helper: responsive font size
double _fs(BuildContext ctx, double base) {
  final w = MediaQuery.of(ctx).size.width;
  if (w < 340) return base - 2;
  if (w < 380) return base - 1;
  return base;
}

// ── GoldButton ────────────────────────────────────────────────────────────────
class GoldBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  const GoldBtn({super.key, required this.text, this.onTap, this.loading = false, this.icon});

  @override
  Widget build(BuildContext ctx) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      child: loading
        ? const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Flexible(child: Text(text,
              style: GoogleFonts.tajawal(fontSize: _fs(ctx, 16), fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
    ),
  );
}

// ── Section Header ────────────────────────────────────────────────────────────
class SecHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SecHead(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext ctx) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Text(title, style: GoogleFonts.tajawal(
        fontWeight: FontWeight.w800, fontSize: _fs(ctx, 17), color: _tx(ctx)),
        maxLines: 1, overflow: TextOverflow.ellipsis)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: GoogleFonts.tajawal(
            color: C.gold, fontSize: _fs(ctx, 14), fontWeight: FontWeight.w700)),
        ),
    ],
  );
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final small = w < 360;
    final configs = <String, List<dynamic>>{
      'active':             [C.ok,      const Color(0xFFE8F8F0), 'نشط'],
      'confirmed':          [C.ok,      const Color(0xFFE8F8F0), 'مؤكد ✓'],
      'pending':            [C.pending, const Color(0xFFFFF3E0), 'انتظار إيصال'],
      'pending_screenshot': [C.pending, const Color(0xFFFFF3E0), 'انتظار إيصال'],
      'pending_review':     [C.warn,    const Color(0xFFFFF8E0), 'انتظار مراجعة'],
      'maintenance':        [C.warn,    const Color(0xFFFFF8E0), 'صيانة'],
      'cancelled':          [C.err,     const Color(0xFFFEECEA), 'ملغى ✗'],
      'closed':             [C.err,     const Color(0xFFFEECEA), 'مغلق'],
      'blocked':            [C.err,     const Color(0xFFFEECEA), 'محظور'],
    };
    final cfg = configs[status] ?? [Colors.grey, const Color(0xFFF0F0F0), status];
    final dark = _dark(ctx);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 10, vertical: 3),
      decoration: BoxDecoration(
        color: dark ? (cfg[0] as Color).withOpacity(0.18) : cfg[1] as Color,
        borderRadius: BorderRadius.circular(20)),
      child: Text(cfg[2] as String,
        style: GoogleFonts.tajawal(
          color: cfg[0] as Color,
          fontSize: small ? 9 : 11,
          fontWeight: FontWeight.w700),
        maxLines: 1),
    );
  }
}

// ── Court Card ────────────────────────────────────────────────────────────────
class CourtCard extends StatelessWidget {
  final Court c;
  final VoidCallback? onTap;
  final bool sel;
  const CourtCard(this.c, {super.key, this.onTap, this.sel = false});

  @override
  Widget build(BuildContext ctx) {
    final small = MediaQuery.of(ctx).size.width < 360;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: sel ? C.gold.withOpacity(0.1) : _card(ctx),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? C.gold : _bdr(ctx), width: sel ? 2 : 0.8),
          boxShadow: sel
            ? [BoxShadow(color: C.gold.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
        ),
        padding: EdgeInsets.all(small ? 12 : 16),
        child: Row(children: [
          Container(
            width: small ? 48 : 56, height: small ? 48 : 56,
            decoration: BoxDecoration(
              color: C.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(c.icon,
              style: TextStyle(fontSize: small ? 24 : 28))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w700, fontSize: _fs(ctx, 16), color: _tx(ctx)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${c.typeAr} · ${c.capacity} لاعبين',
              style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: _fs(ctx, 13)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            if (c.description.isNotEmpty)
              Text(c.description,
                style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: _fs(ctx, 12)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${c.hourlyRate.toStringAsFixed(0)} جنيه',
              style: GoogleFonts.tajawal(
                color: C.gold, fontWeight: FontWeight.w800, fontSize: _fs(ctx, 14))),
            Text('/ ساعة', style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 11)),
            const SizedBox(height: 6),
            StatusBadge(c.status),
          ]),
        ]),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final IconData icon;
  const StatCard({super.key, required this.label, required this.value,
    required this.sub, required this.color, required this.icon});

  @override
  Widget build(BuildContext ctx) => Container(
    decoration: BoxDecoration(
      color: _card(ctx),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _bdr(ctx), width: 0.8)),
    padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 20)),
        Flexible(child: FittedBox(
          fit: BoxFit.scaleDown, alignment: Alignment.centerRight,
          child: Text(value, style: GoogleFonts.tajawal(
            color: color, fontSize: 22, fontWeight: FontWeight.w800)))),
      ]),
      const SizedBox(height: 8),
      Text(label, style: GoogleFonts.tajawal(
        fontWeight: FontWeight.w700, fontSize: _fs(ctx, 13), color: _tx(ctx)),
        maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(sub, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 11),
        maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );
}

// ── Notification Tile ─────────────────────────────────────────────────────────
class NotifTile extends StatelessWidget {
  final AppNotif n;
  final VoidCallback? onTap;
  const NotifTile(this.n, {super.key, this.onTap});

  @override
  Widget build(BuildContext ctx) {
    final unread = !n.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: unread ? C.gold.withOpacity(0.08) : _card(ctx),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unread ? C.gold.withOpacity(0.4) : _bdr(ctx),
            width: unread ? 1.2 : 0.8)),
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: C.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Icon(
              n.type == 'screenshot_uploaded' ? Icons.image_outlined : Icons.event_note,
              color: C.gold, size: 22))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.title, style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w700, fontSize: _fs(ctx, 14), color: _tx(ctx)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (unread)
                Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: C.gold, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 4),
            Text(n.body, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: _fs(ctx, 13)),
              maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              '${n.createdAt.hour.toString().padLeft(2,'0')}:${n.createdAt.minute.toString().padLeft(2,'0')}'
              ' – ${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}',
              style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 11)),
          ])),
        ]),
      ),
    );
  }
}

// ── Empty View ────────────────────────────────────────────────────────────────
class EmptyV extends StatelessWidget {
  final IconData icon;
  final String msg;
  final String? action;
  final VoidCallback? onAct;
  const EmptyV({super.key, required this.icon, required this.msg, this.action, this.onAct});

  @override
  Widget build(BuildContext ctx) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: _mu(ctx).withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(msg, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: _fs(ctx, 16)),
          textAlign: TextAlign.center),
        if (action != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onAct,
            child: Text(action!, style: GoogleFonts.tajawal())),
        ],
      ]),
    ),
  );
}

// ── App Logo ──────────────────────────────────────────────────────────────────
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext ctx) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [C.gold, C.goldL],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(size * 0.22),
      boxShadow: [BoxShadow(
        color: C.gold.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Center(child: Text('AFC',
      style: GoogleFonts.roboto(
        color: Colors.white, fontWeight: FontWeight.w900,
        fontSize: size * 0.34, letterSpacing: 2))),
  );
}