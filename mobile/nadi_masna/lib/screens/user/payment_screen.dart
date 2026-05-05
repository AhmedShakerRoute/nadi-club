import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/reservation.dart';
import '../../providers/res_prov.dart';
import '../../services/api.dart';
import '../../utils/theme.dart';

class PaymentScreen extends StatefulWidget {
  final ReservationGroup group;

  // Single reservation
  PaymentScreen(Reservation res, {super.key})
      : group = ReservationGroup([res]);

  // Multi-hour group
  PaymentScreen.fromGroup({super.key, required this.group});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _image;
  bool _uploading = false;
  bool _done = false;

  ReservationGroup get g => widget.group;

  Future<void> _pick() async {
    final p = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 70, maxWidth: 1200);
    if (p != null) setState(() => _image = File(p.path));
  }

  Future<void> _upload() async {
    if (_image == null) { _snack('اختر صورة الإيصال أولاً'); return; }
    setState(() => _uploading = true);
    try {
      final bytes  = await _image!.readAsBytes();
      final base64 = base64Encode(bytes);

      if (g.slots.length > 1 && g.first.groupId != null) {
        await api.uploadGroupScreenshot(g.first.groupId!, base64);
      } else {
        await api.uploadScreenshot(g.first.id, base64);
      }

      if (mounted) context.read<ResProv>().updateGroupStatus(g.groupId, 'pending_review');
      setState(() { _uploading = false; _done = true; });
    } on ApiErr catch (e) {
      _snack(e.msg); setState(() => _uploading = false);
    } catch (_) {
      _snack('حدث خطأ'); setState(() => _uploading = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m, style: GoogleFonts.tajawal()),
      backgroundColor: C.err, behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    if (_done) return _Done(g: g, onBack: () => Navigator.popUntil(ctx, (r) => r.isFirst));

    return Scaffold(
      appBar: AppBar(title: Text('إرسال إيصال الدفع', style: GoogleFonts.tajawal())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // Booking summary
          _box(dark, C.gold.withOpacity(0.08), C.gold.withOpacity(0.3),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('تفاصيل الحجز', style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w800, fontSize: 16, color: C.gold)),
              const SizedBox(height: 12),
              _r(ctx, '${g.courtIcon} الملعب', g.courtName, dark),
              _r(ctx, '📅 التاريخ', g.date, dark),
              _r(ctx, '🕐 الوقت', '${g.startTime} – ${g.endTime}', dark),
              _r(ctx, '⏱ المدة', '${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}', dark),
              _r(ctx, '💰 الإجمالي', '${g.totalPrice.toStringAsFixed(0)} جنيه', dark),
              const Divider(height: 20),
              _r(ctx, '💳 المطلوب دفعه (25%)',
                  '${g.depositAmount.toStringAsFixed(0)} جنيه', dark, bold: true, vc: C.gold),
              _r(ctx, '🔄 الباقي عند الحضور',
                  '${g.remaining.toStringAsFixed(0)} جنيه', dark),
            ])),
          const SizedBox(height: 14),

          // Bank info
          _box(dark, C.info.withOpacity(0.08), C.info.withOpacity(0.3),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.account_balance, color: C.info, size: 18),
                const SizedBox(width: 8),
                Text('بيانات التحويل', style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w800, fontSize: 14, color: C.info)),
              ]),
              const SizedBox(height: 12),
              _r(ctx, 'اسم الحساب', 'نادي مصنع الطائرات', dark),
              _r(ctx, 'رقم الحساب', '1234567890', dark),
              _r(ctx, 'البنك', 'بنك مصر', dark),
              _r(ctx, 'فودافون كاش', '01000000000', dark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: C.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: C.gold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                      'حوّل ${g.depositAmount.toStringAsFixed(0)} جنيه ثم ارفع الإيصال',
                      style: GoogleFonts.tajawal(color: C.gold, fontSize: 13))),
                ]),
              ),
            ])),
          const SizedBox(height: 18),

          // Upload
          Text('ارفع صورة إيصال التحويل',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700,
                  fontSize: 15, color: dark ? C.dTx : C.lTx)),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: _pick,
            child: Container(
              width: double.infinity,
              height: _image != null ? 200 : 130,
              decoration: BoxDecoration(
                color: dark ? C.dCard : C.lCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _image != null ? C.ok : C.gold.withOpacity(0.5),
                    width: _image != null ? 2 : 1.5)),
              child: _image != null
                ? ClipRRect(borderRadius: BorderRadius.circular(13),
                    child: Image.file(_image!, fit: BoxFit.cover))
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.upload_file_outlined, size: 40, color: C.gold.withOpacity(0.7)),
                    const SizedBox(height: 8),
                    Text('اضغط لاختيار الإيصال من المعرض',
                        style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 14)),
                  ]),
            ),
          ),

          if (_image != null) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.refresh, size: 16, color: C.gold),
              label: Text('تغيير الصورة', style: GoogleFonts.tajawal(color: C.gold))),
          ],
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _uploading || _image == null ? null : _upload,
              child: _uploading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.send_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text('إرسال الإيصال للإدارة',
                        style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
            )),
        ]),
      ),
    );
  }

  Widget _box(bool dark, Color bg, Color border, Widget child) => Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border)),
      padding: const EdgeInsets.all(16), child: child);

  Widget _r(BuildContext ctx, String l, String v, bool dark,
      {bool bold = false, Color? vc}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 13)),
        Text(v, style: GoogleFonts.tajawal(
            color: vc ?? (dark ? C.dTx : C.lTx),
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: 13)),
      ]));
}

class _Done extends StatelessWidget {
  final ReservationGroup g;
  final VoidCallback onBack;
  const _Done({required this.g, required this.onBack});

  @override
  Widget build(BuildContext ctx) => Scaffold(
    body: SafeArea(child: Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 88, height: 88,
          decoration: BoxDecoration(
              color: C.ok.withOpacity(0.15), borderRadius: BorderRadius.circular(44)),
          child: const Icon(Icons.check_circle_outline, color: C.ok, size: 56)),
        const SizedBox(height: 20),
        Text('تم إرسال الإيصال بنجاح!',
            style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w800, color: C.ok),
            textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('${g.courtName}\n${g.date}  •  ${g.startTime} – ${g.endTime}\n${g.hours} ${g.hours == 1 ? "ساعة" : "ساعات"}',
            style: GoogleFonts.tajawal(fontSize: 14,
                color: Theme.of(ctx).brightness == Brightness.dark ? C.dMu : C.lMu),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('سيقوم الإداري بمراجعة الإيصال وتأكيد حجزك قريباً',
            style: GoogleFonts.tajawal(fontSize: 13,
                color: Theme.of(ctx).brightness == Brightness.dark ? C.dMu : C.lMu),
            textAlign: TextAlign.center),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: onBack,
            child: Text('العودة للرئيسية',
                style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700)))),
      ]),
    ))));
}
