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
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(text, style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700)),
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
      Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.w800, fontSize: 17, color: _tx(ctx))),
      if (action != null)
        GestureDetector(onTap: onAction,
          child: Text(action!, style: GoogleFonts.tajawal(color: C.gold, fontSize: 14, fontWeight: FontWeight.w700))),
    ],
  );
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext ctx) {
    final configs = <String, List<dynamic>>{
      'active':             [C.ok,      const Color(0xFFE8F8F0), 'نشط'],
      'confirmed':          [C.ok,      const Color(0xFFE8F8F0), 'مؤكد ✓'],
      'pending':            [C.pending, const Color(0xFFFFF3E0), 'بانتظار الإيصال 📤'],
      'pending_screenshot': [C.pending, const Color(0xFFFFF3E0), 'بانتظار الإيصال 📤'],
      'pending_review':     [C.warn,    const Color(0xFFFFF8E0), 'بانتظار المراجعة ⏳'],
      'maintenance':        [C.warn,    const Color(0xFFFFF8E0), 'صيانة'],
      'cancelled':          [C.err,     const Color(0xFFFEECEA), 'ملغى ✗'],
      'closed':             [C.err,     const Color(0xFFFEECEA), 'مغلق'],
      'blocked':            [C.err,     const Color(0xFFFEECEA), 'محظور'],
    };
    final cfg = configs[status] ?? [Colors.grey, const Color(0xFFF0F0F0), status];
    final dark = _dark(ctx);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? (cfg[0] as Color).withOpacity(0.18) : cfg[1] as Color,
        borderRadius: BorderRadius.circular(20)),
      child: Text(cfg[2] as String,
        style: GoogleFonts.tajawal(color: cfg[0] as Color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Status Tracker (shows steps for user) ────────────────────────────────────
class StatusTracker extends StatelessWidget {
  final String status;
  const StatusTracker(this.status, {super.key});

  @override
  Widget build(BuildContext ctx) {
    final dark = _dark(ctx);

    final steps = [
      _Step('تم الحجز',         Icons.event_available_outlined, true),
      _Step('إرسال الإيصال',    Icons.upload_file_outlined,
            status == 'pending_review' || status == 'confirmed'),
      _Step('مراجعة الإدارة',   Icons.admin_panel_settings_outlined,
            status == 'confirmed'),
      _Step('تأكيد نهائي',      Icons.check_circle_outline,
            status == 'confirmed'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? C.dSurf : C.lBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _bdr(ctx)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('متابعة الحجز', style: GoogleFonts.tajawal(
          fontWeight: FontWeight.w700, fontSize: 13, color: _tx(ctx))),
        const SizedBox(height: 12),
        Row(children: steps.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final isLast = i == steps.length - 1;
          return Expanded(child: Row(children: [
            Expanded(child: Column(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: s.done ? C.gold : (dark ? C.dBdr : C.lBdr),
                  shape: BoxShape.circle,
                ),
                child: Icon(s.icon,
                  color: s.done ? C.dBg : _mu(ctx), size: 16),
              ),
              const SizedBox(height: 4),
              Text(s.label,
                style: GoogleFonts.tajawal(
                  fontSize: 10,
                  color: s.done ? C.gold : _mu(ctx),
                  fontWeight: s.done ? FontWeight.w700 : FontWeight.normal),
                textAlign: TextAlign.center, maxLines: 2),
            ])),
            if (!isLast)
              Expanded(child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 20),
                color: steps[i + 1].done ? C.gold : (dark ? C.dBdr : C.lBdr),
              )),
          ]));
        }).toList()),
      ]),
    );
  }
}

class _Step {
  final String label;
  final IconData icon;
  final bool done;
  const _Step(this.label, this.icon, this.done);
}

// ── Court Card ────────────────────────────────────────────────────────────────
class CourtCard extends StatelessWidget {
  final Court c;
  final VoidCallback? onTap;
  final bool sel;
  const CourtCard(this.c, {super.key, this.onTap, this.sel = false});

  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: sel ? C.gold.withOpacity(0.1) : _card(ctx),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sel ? C.gold : _bdr(ctx), width: sel ? 2 : 0.8),
        boxShadow: sel ? [BoxShadow(color: C.gold.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))] : [],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: C.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(c.icon, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.name, style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 16, color: _tx(ctx))),
          Text('${c.typeAr} · ${c.capacity} لاعبين', style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 13)),
          if (c.description.isNotEmpty)
            Text(c.description, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 12),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${c.hourlyRate.toStringAsFixed(0)} جنيه',
            style: GoogleFonts.tajawal(color: C.gold, fontWeight: FontWeight.w800, fontSize: 15)),
          Text('/ ساعة', style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 11)),
          const SizedBox(height: 6),
          StatusBadge(c.status),
        ]),
      ]),
    ),
  );
}

// ── Booking Card ──────────────────────────────────────────────────────────────
class BookCard extends StatelessWidget {
  final Reservation r;
  final VoidCallback? onCancel;
  final VoidCallback? onPay;
  final bool admin;
  final bool showTracker;
  const BookCard(this.r, {super.key, this.onCancel, this.onPay, this.admin = false, this.showTracker = false});

  Widget _row(BuildContext ctx, String l, String v, {Color? vc}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 13)),
      Text(v, style: GoogleFonts.tajawal(color: vc ?? _tx(ctx), fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );

  @override
  Widget build(BuildContext ctx) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: _card(ctx),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _bdr(ctx), width: 0.8),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Header
      Row(children: [
        Text(r.icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.courtName, style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 15, color: _tx(ctx))),
          if (admin) Text(r.userName, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 13)),
        ])),
        StatusBadge(r.status),
      ]),
      const SizedBox(height: 10),

      // Details
      Container(
        decoration: BoxDecoration(color: _surf(ctx), borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          _row(ctx, 'التاريخ', r.date),
          _row(ctx, 'الوقت', '${r.startTime} – ${r.endTime}'),
          _row(ctx, 'الإجمالي', '${r.totalPrice.toStringAsFixed(0)} جنيه'),
          _row(ctx, 'الدفعة المقدمة (25%)', '${r.depositAmount.toStringAsFixed(0)} جنيه', vc: C.gold),
          _row(ctx, 'حالة الإيصال',
            r.hasScreenshot ? 'تم الإرسال ✓' : 'لم يُرسل بعد',
            vc: r.hasScreenshot ? C.ok : C.warn),
          if (r.isConfirmed)
            _row(ctx, 'حالة الدفع', 'مؤكد من الإدارة ✓', vc: C.ok),
          if (r.adminNote != null && r.adminNote!.isNotEmpty)
            _row(ctx, 'ملاحظة الإدارة', r.adminNote!, vc: C.err),
        ]),
      ),

      // Status tracker for user (shows progress steps)
      if (showTracker && !admin && !r.isCancelled) ...[
        const SizedBox(height: 10),
        StatusTracker(r.status),
      ],

      // ── Action buttons ──────────────────────────────────────────────────────

      // pending_screenshot → send receipt + cancel
      if (r.isPendingScreenshot) ...[
        const SizedBox(height: 10),
        if (onPay != null) SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPay,
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: Text('أرسل إيصال الدفع (${r.depositAmount.toStringAsFixed(0)} جنيه)',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        if (onCancel != null) OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.close, size: 16),
          label: Text('إلغاء الحجز', style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: C.err, side: const BorderSide(color: C.err),
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ],

      // pending_review → receipt sent, waiting (no cancel, no pay button)
      if (r.isPendingReview) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: C.warn.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.warn.withOpacity(0.3))),
          child: Row(children: [
            const Icon(Icons.hourglass_top, color: C.warn, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text('تم إرسال الإيصال — بانتظار تأكيد الإدارة',
              style: GoogleFonts.tajawal(color: C.warn, fontSize: 13))),
          ]),
        ),
      ],

      // confirmed + upcoming → cancel only
      if (r.isConfirmed && r.isUpcoming && onCancel != null) ...[
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.close, size: 16),
          label: Text('إلغاء الحجز', style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: C.err, side: const BorderSide(color: C.err),
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ],
    ]),
  );
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
    decoration: BoxDecoration(color: _card(ctx),
      borderRadius: BorderRadius.circular(14), border: Border.all(color: _bdr(ctx), width: 0.8)),
    padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 20)),
        Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight,
          child: Text(value, style: GoogleFonts.tajawal(color: color, fontSize: 22, fontWeight: FontWeight.w800)))),
      ]),
      const SizedBox(height: 8),
      Text(label, style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 13, color: _tx(ctx)),
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
          border: Border.all(color: unread ? C.gold.withOpacity(0.4) : _bdr(ctx), width: unread ? 1.2 : 0.8)),
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: C.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Icon(
              n.type == 'screenshot_uploaded' ? Icons.image_outlined : Icons.event_note,
              color: C.gold, size: 22))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.title, style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: 14, color: _tx(ctx)))),
              if (unread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.gold, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 4),
            Text(n.body, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('${n.createdAt.hour.toString().padLeft(2,'0')}:${n.createdAt.minute.toString().padLeft(2,'0')} – ${n.createdAt.day}/${n.createdAt.month}/${n.createdAt.year}',
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
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 64, color: _mu(ctx).withOpacity(0.5)),
      const SizedBox(height: 16),
      Text(msg, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 16), textAlign: TextAlign.center),
      if (action != null) ...[
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onAct, child: Text(action!, style: GoogleFonts.tajawal())),
      ],
    ]),
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
      gradient: const LinearGradient(colors: [C.gold, C.goldL], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(size * 0.22),
      boxShadow: [BoxShadow(color: C.gold.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
    child: Center(child: Text('AFC',
      style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w900, fontSize: size * 0.34, letterSpacing: 2))),
  );
}
