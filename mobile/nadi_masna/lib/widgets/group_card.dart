import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reservation.dart';
import '../utils/theme.dart';

bool _dark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;
Color _tx(BuildContext ctx)   => _dark(ctx) ? C.dTx  : C.lTx;
Color _mu(BuildContext ctx)   => _dark(ctx) ? C.dMu  : C.lMu;
Color _card(BuildContext ctx) => _dark(ctx) ? C.dCard : C.lCard;
Color _bdr(BuildContext ctx)  => _dark(ctx) ? C.dBdr  : C.lBdr;
Color _surf(BuildContext ctx) => _dark(ctx) ? C.dSurf : C.lBg;

class GroupCard extends StatelessWidget {
  final ReservationGroup g;
  final VoidCallback? onPay;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;   // admin tap to detail
  final bool admin;
  final bool showTracker;

  const GroupCard(this.g, {
    super.key, this.onPay, this.onCancel,
    this.onTap, this.admin = false, this.showTracker = false,
  });

  Widget _row(BuildContext ctx, String l, String v, {Color? vc}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 13)),
      Text(v, style: GoogleFonts.tajawal(
        color: vc ?? _tx(ctx), fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );

  @override
  Widget build(BuildContext ctx) {
    final dark = _dark(ctx);
    final isPending = g.isPendingReview;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card(ctx),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending ? C.gold.withOpacity(0.5) : _bdr(ctx),
            width: isPending ? 1.5 : 0.8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header ─────────────────────────────────────────────────────────
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: C.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(g.courtIcon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.courtName, style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w700, fontSize: 15, color: _tx(ctx))),
              if (admin)
                Text(g.userName, style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 13)),
              // Duration badge
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: C.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
                child: Text(
                  '${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}  •  ${g.startTime} – ${g.endTime}',
                  style: GoogleFonts.tajawal(color: C.info, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ])),
            _StatusBadge(g.status),
          ]),
          const SizedBox(height: 12),

          // ── Details ─────────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(color: _surf(ctx), borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              _row(ctx, '📅 التاريخ', g.date),
              _row(ctx, '🕐 الوقت', '${g.startTime} – ${g.endTime}'),
              _row(ctx, '💰 إجمالي الحجز', '${g.totalPrice.toStringAsFixed(0)} جنيه'),
              _row(ctx, '💳 الدفعة المقدمة (25%)',
                '${g.depositAmount.toStringAsFixed(0)} جنيه', vc: C.gold),
              _row(ctx, '📄 الإيصال',
                g.hasScreenshot ? 'تم الإرسال ✓' : 'لم يُرسل بعد',
                vc: g.hasScreenshot ? C.ok : C.warn),
              if (g.isConfirmed)
                _row(ctx, '✅ الحالة', 'مؤكد من الإدارة', vc: C.ok),
              if (g.adminNote != null && g.adminNote!.isNotEmpty)
                _row(ctx, '📝 ملاحظة', g.adminNote!, vc: C.err),
            ]),
          ),

          // ── Tracker ─────────────────────────────────────────────────────────
          if (showTracker && !admin && !g.isCancelled) ...[
            const SizedBox(height: 10),
            _Tracker(g.status),
          ],

          // ── Actions ─────────────────────────────────────────────────────────
          if (g.isPendingScreenshot) ...[
            const SizedBox(height: 10),
            if (onPay != null) SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.upload_file_outlined, size: 18),
                label: Text(
                  'أرسل إيصال الدفع (${g.depositAmount.toStringAsFixed(0)} جنيه)',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w700)),
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 8),
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
          ],

          if (g.isPendingReview) ...[
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

          if (g.isConfirmed && g.isUpcoming && onCancel != null) ...[
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

          if (admin && onTap != null) ...[
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('اضغط للتفاصيل', style: GoogleFonts.tajawal(color: _mu(ctx), fontSize: 12)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 12, color: _mu(ctx)),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext ctx) {
    final cfgs = <String, List<dynamic>>{
      'confirmed':          [C.ok,      const Color(0xFFE8F8F0), 'مؤكد ✓'],
      'pending_screenshot': [C.pending, const Color(0xFFFFF3E0), 'بانتظار الإيصال 📤'],
      'pending_review':     [C.warn,    const Color(0xFFFFF8E0), 'بانتظار المراجعة ⏳'],
      'cancelled':          [C.err,     const Color(0xFFFEECEA), 'ملغى ✗'],
    };
    final c = cfgs[status] ?? [Colors.grey, const Color(0xFFF5F5F5), status];
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? (c[0] as Color).withOpacity(0.18) : c[1] as Color,
        borderRadius: BorderRadius.circular(20)),
      child: Text(c[2] as String,
        style: GoogleFonts.tajawal(color: c[0] as Color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _Tracker extends StatelessWidget {
  final String status;
  const _Tracker(this.status);
  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    final steps = [
      ('تم الحجز',        Icons.event_available_outlined,    true),
      ('إرسال الإيصال',   Icons.upload_file_outlined,
        status == 'pending_review' || status == 'confirmed'),
      ('مراجعة الإدارة',  Icons.admin_panel_settings_outlined, status == 'confirmed'),
      ('تأكيد نهائي',     Icons.check_circle_outline,          status == 'confirmed'),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? C.dSurf : C.lBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: dark ? C.dBdr : C.lBdr)),
      child: Row(children: steps.asMap().entries.map((e) {
        final i = e.key; final s = e.value; final isLast = i == steps.length - 1;
        return Expanded(child: Row(children: [
          Expanded(child: Column(children: [
            Container(width: 30, height: 30,
              decoration: BoxDecoration(
                color: s.$3 ? C.gold : (dark ? C.dBdr : C.lBdr),
                shape: BoxShape.circle),
              child: Icon(s.$2, color: s.$3 ? C.dBg : (dark ? C.dMu : C.lMu), size: 15)),
            const SizedBox(height: 4),
            Text(s.$1,
              style: GoogleFonts.tajawal(
                fontSize: 9, color: s.$3 ? C.gold : (dark ? C.dMu : C.lMu),
                fontWeight: s.$3 ? FontWeight.w700 : FontWeight.normal),
              textAlign: TextAlign.center, maxLines: 2),
          ])),
          if (!isLast) Expanded(child: Container(
            height: 2, margin: const EdgeInsets.only(bottom: 20),
            color: steps[i+1].$3 ? C.gold : (dark ? C.dBdr : C.lBdr))),
        ]));
      }).toList()),
    );
  }
}
