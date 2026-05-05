import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/court.dart';
import '../../providers/court_prov.dart';
import '../../providers/res_prov.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';
import '../../models/reservation.dart';
// ── Filter options ─────────────────────────────────────────────────────────────
enum RevenueFilter { daily, weekly, monthly, all }

extension RevenueFilterExt on RevenueFilter {
  String get label {
    switch (this) {
      case RevenueFilter.daily:   return 'اليوم';
      case RevenueFilter.weekly:  return 'هذا الأسبوع';
      case RevenueFilter.monthly: return 'هذا الشهر';
      case RevenueFilter.all:     return 'الكل';
    }
  }
}

class AdminCourts extends StatefulWidget {
  const AdminCourts({super.key});
  @override State<AdminCourts> createState() => _AdminCourtsState();
}

class _AdminCourtsState extends State<AdminCourts> {
  RevenueFilter _filter = RevenueFilter.monthly;

  // Calculate revenue for a court based on filter
  double _revenue(String courtName, ResProv rp) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ReservationGroup.group(rp.all)
      .where((g) {
        if (g.courtName != courtName) return false;
        if (!g.isConfirmed) return false;
        final d = DateTime.tryParse(g.date);
        if (d == null) return false;
        switch (_filter) {
          case RevenueFilter.daily:
            return d.year == today.year && d.month == today.month && d.day == today.day;
          case RevenueFilter.weekly:
            return d.isAfter(today.subtract(const Duration(days: 7)));
          case RevenueFilter.monthly:
            return d.year == now.year && d.month == now.month;
          case RevenueFilter.all:
            return true;
        }
      })
      .fold(0.0, (s, g) => s + g.totalPrice);
  }

  int _bookings(String courtName, ResProv rp) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ReservationGroup.group(rp.all)
      .where((g) {
        if (g.courtName != courtName) return false;
        if (!g.isConfirmed) return false;
        final d = DateTime.tryParse(g.date);
        if (d == null) return false;
        switch (_filter) {
          case RevenueFilter.daily:
            return d.year == today.year && d.month == today.month && d.day == today.day;
          case RevenueFilter.weekly:
            return d.isAfter(today.subtract(const Duration(days: 7)));
          case RevenueFilter.monthly:
            return d.year == now.year && d.month == now.month;
          case RevenueFilter.all:
            return true;
        }
      })
      .length;
  }

  @override
  Widget build(BuildContext ctx) {
    final cp   = ctx.watch<CourtProv>();
    final rp   = ctx.watch<ResProv>();
    final dark = Theme.of(ctx).brightness == Brightness.dark;

    return Scaffold(
      body: Column(children: [

        // ── Filter bar ────────────────────────────────────────────────────
        Container(
          color: dark ? C.dSurf : C.lSurf,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            Text('الإيرادات:', style: GoogleFonts.tajawal(
              color: dark ? C.dMu : C.lMu, fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: RevenueFilter.values.map((f) {
                final sel = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? C.gold : C.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? C.gold : C.gold.withOpacity(0.3))),
                    child: Text(f.label, style: GoogleFonts.tajawal(
                      color: sel ? Colors.white : C.gold,
                      fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                );
              }).toList()),
            )),
          ]),
        ),

        // ── Courts list ───────────────────────────────────────────────────
        Expanded(child: cp.loading
          ? const Center(child: CircularProgressIndicator(color: C.gold))
          : RefreshIndicator(
              color: C.gold,
              onRefresh: () => ctx.read<CourtProv>().fetch(),
              child: cp.courts.isEmpty
                ? const EmptyV(icon: Icons.sports_tennis, msg: 'لا توجد ملاعب بعد')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cp.courts.length,
                    itemBuilder: (_, i) => _CourtTile(
                      cp.courts[i],
                      revenue: _revenue(cp.courts[i].name, rp),
                      bookings: _bookings(cp.courts[i].name, rp),
                      filterLabel: _filter.label,
                    ),
                  ),
            )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: C.gold,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('إضافة ملعب', style: GoogleFonts.tajawal(fontWeight: FontWeight.w700)),
        onPressed: () => _showForm(ctx, null),
      ),
    );
  }

  static void _showForm(BuildContext ctx, Court? c) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(ctx).brightness == Brightness.dark ? C.dCard : C.lCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CourtForm(c),
    );
  }
}

class _CourtTile extends StatelessWidget {
  final Court c;
  final double revenue;
  final int bookings;
  final String filterLabel;
  const _CourtTile(this.c, {required this.revenue, required this.bookings, required this.filterLabel});

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(c.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w700, fontSize: 15, color: dark ? C.dTx : C.lTx)),
              Text('${c.typeAr} · ${c.capacity} لاعبين',
                style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: 12)),
            ])),
            StatusBadge(c.status),
          ]),
          const SizedBox(height: 12),

          // Stats chips with filter period label
          Wrap(spacing: 8, runSpacing: 6, children: [
            _chip('${c.hourlyRate.toStringAsFixed(0)} جنيه/ساعة', C.gold),
            _chip('$bookings حجز ($filterLabel)', C.info),
            _chip('${revenue.toStringAsFixed(0)} جنيه ($filterLabel)', C.ok),
          ]),

          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text('تعديل', style: GoogleFonts.tajawal()),
              onPressed: () => _AdminCourtsState._showForm(ctx, c),
              style: OutlinedButton.styleFrom(
                foregroundColor: dark ? C.dTx : C.lTx,
                side: BorderSide(color: dark ? C.dBdr : C.lBdr)),
            )),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, size: 16),
              label: Text('حذف', style: GoogleFonts.tajawal()),
              onPressed: () => _del(ctx),
              style: OutlinedButton.styleFrom(
                foregroundColor: C.err, side: const BorderSide(color: C.err)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(String t, Color col) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(t, style: GoogleFonts.tajawal(
      color: col, fontSize: 12, fontWeight: FontWeight.w600)),
  );

  Future<void> _del(BuildContext ctx) async {
    final ok = await showDialog<bool>(context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark ? C.dCard : C.lCard,
        title: Text('حذف ${c.name}؟', style: GoogleFonts.tajawal()),
        content: Text('لا يمكن التراجع عن هذا الإجراء.', style: GoogleFonts.tajawal()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal())),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف', style: GoogleFonts.tajawal(color: C.err))),
        ],
      ));
    if (ok == true && ctx.mounted) await ctx.read<CourtProv>().remove(c.id);
  }
}

// ── Court form (unchanged) ────────────────────────────────────────────────────
class _CourtForm extends StatefulWidget {
  final Court? c;
  const _CourtForm(this.c);
  @override State<_CourtForm> createState() => _CourtFormState();
}

class _CourtFormState extends State<_CourtForm> {
  late final _name = TextEditingController(text: widget.c?.name ?? '');
  late final _cap  = TextEditingController(text: '${widget.c?.capacity ?? 4}');
  late final _rate = TextEditingController(text: '${widget.c?.hourlyRate.toStringAsFixed(0) ?? 100}');
  late final _desc = TextEditingController(text: widget.c?.description ?? '');
  late String _type   = widget.c?.type ?? 'Tennis';
  late String _status = widget.c?.status ?? 'active';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose(); _cap.dispose(); _rate.dispose(); _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final d = {
      'name': _name.text.trim(), 'type': _type,
      'capacity': int.tryParse(_cap.text) ?? 4,
      'hourlyRate': double.tryParse(_rate.text) ?? 100,
      'status': _status, 'description': _desc.text.trim(),
    };
    if (widget.c == null) {
      await context.read<CourtProv>().add(d);
    } else {
      await context.read<CourtProv>().update(widget.c!.id, d);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(ctx).viewInsets.bottom +
                      MediaQuery.of(ctx).padding.bottom + 16;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: dark ? C.dBdr : C.lBdr,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(widget.c == null ? 'إضافة ملعب جديد' : 'تعديل الملعب',
            style: GoogleFonts.tajawal(color: C.gold, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(controller: _name, textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'اسم الملعب')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: _type,
            dropdownColor: dark ? C.dCard : C.lCard,
            decoration: const InputDecoration(labelText: 'النوع'),
            items: K.courtTypes.map((t) => DropdownMenuItem(value: t,
              child: Text('${K.courtTypesAr[t] ?? t}  ($t)',
                style: GoogleFonts.tajawal()))).toList(),
            onChanged: (v) => setState(() => _type = v!)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _cap,
              keyboardType: TextInputType.number, textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'السعة'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _rate,
              keyboardType: TextInputType.number, textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'السعر (جنيه/ساعة)'))),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: _status,
            dropdownColor: dark ? C.dCard : C.lCard,
            decoration: const InputDecoration(labelText: 'الحالة'),
            items: const [
              DropdownMenuItem(value: 'active',      child: Text('نشط')),
              DropdownMenuItem(value: 'maintenance', child: Text('صيانة')),
              DropdownMenuItem(value: 'closed',      child: Text('مغلق')),
            ],
            onChanged: (v) => setState(() => _status = v!)),
          const SizedBox(height: 12),
          TextField(controller: _desc, maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'الوصف')),
          const SizedBox(height: 20),
          GoldBtn(
            text: widget.c == null ? 'إضافة الملعب' : 'حفظ التغييرات',
            onTap: _save, loading: _saving, icon: Icons.check),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}