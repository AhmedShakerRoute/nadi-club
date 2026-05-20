import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_prov.dart';
import '../../providers/res_prov.dart';
import '../../providers/theme_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _S();
}

class _S extends State<ProfileScreen> {
  bool _edit = false, _saving = false;
  late final _n  = TextEditingController();
  late final _ph = TextEditingController();
  final _pw = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProv>().user!;
    _n.text = u.name; _ph.text = u.phone;
  }

  @override void dispose() { _n.dispose(); _ph.dispose(); _pw.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final u = context.read<AuthProv>().user!;
      await context.read<AuthProv>().updateProfile(
        u.id, _n.text.trim(), _ph.text.trim(),
        _pw.text.isNotEmpty ? _pw.text : null);
      setState(() => _edit = false); _pw.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("تم حفظ التغييرات", style: GoogleFonts.tajawal()),
        backgroundColor: C.ok, behavior: SnackBarBehavior.floating));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("فشل الحفظ", style: GoogleFonts.tajawal()),
        backgroundColor: C.err, behavior: SnackBarBehavior.floating));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext ctx) {
    final u     = ctx.watch<AuthProv>().user!;
    final theme = ctx.watch<ThemeProv>();
    final rp    = ctx.watch<ResProv>();
    final dark  = theme.isDark;
    final sw    = MediaQuery.of(ctx).size.width;
    final isSmall = sw < 360;
    final confirmed = rp.all.where((r) => r.isConfirmed).length;

    return ListView(padding: EdgeInsets.all(isSmall ? 14 : 20), children: [

      // ── Avatar ─────────────────────────────────────────────────────────────
      Center(child: Column(children: [
        CircleAvatar(
          radius: isSmall ? 36 : 44,
          backgroundColor: C.gold.withOpacity(0.15),
          child: Text(u.name.substring(0, 1),
            style: GoogleFonts.tajawal(
              color: C.gold, fontSize: isSmall ? 26 : 32, fontWeight: FontWeight.w800))),
        const SizedBox(height: 10),
        Text(u.name,
          style: GoogleFonts.tajawal(
            fontSize: isSmall ? 17 : 20,
            fontWeight: FontWeight.w800,
            color: dark ? C.dTx : C.lTx),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(u.email,
          style: GoogleFonts.tajawal(color: dark ? C.dMu : C.lMu, fontSize: isSmall ? 11 : 13),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        StatusBadge(u.status),
      ])),
      const SizedBox(height: 16),

      // ── Stats ───────────────────────────────────────────────────────────────
      Row(children: [
        Expanded(child: StatCard(
          label: "حجوزاتي المؤكدة", value: "$confirmed",
          sub: "إجمالي", color: C.ok, icon: Icons.event_available_outlined)),
        const SizedBox(width: 10),
        Expanded(child: StatCard(
          label: "عضو منذ", value: "${u.joinDate.year}",
          sub: "${u.joinDate.day}/${u.joinDate.month}/${u.joinDate.year}",
          color: C.info, icon: Icons.calendar_month_outlined)),
      ]),
      const SizedBox(height: 16),

      // ── Theme toggle ────────────────────────────────────────────────────────
      Container(
        decoration: BoxDecoration(
          color: dark ? C.dCard : C.lCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dark ? C.dBdr : C.lBdr)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(dark ? Icons.dark_mode : Icons.light_mode, color: C.gold, size: 20),
            const SizedBox(width: 10),
            Text(dark ? "الوضع الليلي" : "الوضع النهاري",
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 13 : 15,
                color: dark ? C.dTx : C.lTx)),
          ]),
          Switch(value: dark, onChanged: (_) => ctx.read<ThemeProv>().toggle(),
            activeColor: C.gold),
        ]),
      ),
      const SizedBox(height: 14),

      // ── Info card ───────────────────────────────────────────────────────────
      Card(child: Padding(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        child: _edit
          ? Column(children: [
              TextField(controller: _n,
                decoration: const InputDecoration(
                  labelText: "الاسم الكامل",
                  prefixIcon: Icon(Icons.person_outline, color: C.gold))),
              const SizedBox(height: 10),
              TextField(controller: _ph, keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "رقم الهاتف",
                  prefixIcon: Icon(Icons.phone_outlined, color: C.gold))),
              const SizedBox(height: 10),
              TextField(controller: _pw, obscureText: true,
                decoration: const InputDecoration(
                  labelText: "كلمة مرور جديدة (اتركها فارغة للإبقاء)",
                  prefixIcon: Icon(Icons.lock_outline, color: C.gold))),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => setState(() => _edit = false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: dark ? C.dBdr : C.lBdr),
                    foregroundColor: dark ? C.dTx : C.lTx),
                  child: Text("إلغاء", style: GoogleFonts.tajawal()))),
                const SizedBox(width: 10),
                Expanded(child: GoldBtn(
                  text: "حفظ", onTap: _save, loading: _saving, icon: Icons.check)),
              ]),
            ])
          : Column(children: [
              for (final r in [
                ["الاسم",           u.name],
                ["البريد الإلكتروني", u.email],
                ["الهاتف",          u.phone.isEmpty ? "غير محدد" : u.phone],
                ["نوع الحساب",      u.isAdmin ? "مدير" : "عضو"],
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r[0], style: GoogleFonts.tajawal(
                        color: dark ? C.dMu : C.lMu, fontSize: isSmall ? 12 : 13)),
                      Flexible(child: Text(r[1], style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w600,
                        color: dark ? C.dTx : C.lTx,
                        fontSize: isSmall ? 12 : 13),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end)),
                    ])),
              const Divider(),
              SizedBox(width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _edit = true),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text("تعديل الملف الشخصي", style: GoogleFonts.tajawal()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: dark ? C.dBdr : C.lBdr),
                    foregroundColor: dark ? C.dTx : C.lTx))),
            ])),
      ),
      const SizedBox(height: 14),

      // ── Logout ──────────────────────────────────────────────────────────────
      SizedBox(width: double.infinity, height: 50,
        child: OutlinedButton.icon(
          onPressed: () => ctx.read<AuthProv>().logout(),
          icon: const Icon(Icons.logout, size: 18),
          label: Text("تسجيل الخروج",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w700, fontSize: isSmall ? 13 : 15)),
          style: OutlinedButton.styleFrom(
            foregroundColor: C.err, side: const BorderSide(color: C.err),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
    ]);
  }
}