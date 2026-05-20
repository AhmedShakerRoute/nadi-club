import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_prov.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  final _phone = TextEditingController();
  bool _obs = true;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose(); _email.dispose();
    _pass.dispose(); _phone.dispose();
    super.dispose();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(m, style: GoogleFonts.tajawal()),
    backgroundColor: C.err, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  Future<void> _go() async {
    if (_submitted) return;
    final name  = _name.text.trim();
    final email = _email.text.trim();
    final pass  = _pass.text;
    final phone = _phone.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _snack('جميع الحقول مطلوبة'); return;
    }
    if (pass.length < 6) {
      _snack('كلمة المرور يجب أن تكون 6 أحرف على الأقل'); return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _snack('أدخل بريد إلكتروني صحيح'); return;
    }

    setState(() => _submitted = true);
    final ok = await context.read<AuthProv>().register(name, email, pass, phone);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم إنشاء الحساب — سجّل دخولك الآن',
          style: GoogleFonts.tajawal()),
        backgroundColor: C.ok, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } else {
      setState(() => _submitted = false);
      _snack(context.read<AuthProv>().err ?? 'فشل إنشاء الحساب');
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final auth      = ctx.watch<AuthProv>();
    final dark      = Theme.of(ctx).brightness == Brightness.dark;
    final isLoading = auth.loading || _submitted;

    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 12),

          // Back button
          Align(alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dark ? C.dCard : C.lCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: dark ? C.dBdr : C.lBdr)),
                child: Icon(Icons.arrow_forward_ios,
                  color: dark ? C.dTx : C.lTx, size: 18)))),

          const SizedBox(height: 20),

          // ── Logo image ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/logo.png',
              width: 90, height: 90, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [C.gold, C.goldL]),
                  borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text('ACF',
                  style: GoogleFonts.roboto(
                    color: Colors.white, fontWeight: FontWeight.w900,
                    fontSize: 26, letterSpacing: 3)))))),

          const SizedBox(height: 12),

          Text('إنشاء حساب جديد', style: GoogleFonts.tajawal(
            color: C.gold, fontSize: 20, fontWeight: FontWeight.w800)),
          Text('سجّل معنا وابدأ الحجز', style: GoogleFonts.tajawal(
            color: dark ? C.dMu : C.lMu, fontSize: 13)),

          const SizedBox(height: 24),

          // ── Form card ───────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: dark ? C.dCard : C.lCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: dark ? C.dBdr : C.lBdr)),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              TextField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline, color: C.gold))),
              const SizedBox(height: 14),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined, color: C.gold))),
              const SizedBox(height: 14),

              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined, color: C.gold))),
              const SizedBox(height: 14),

              TextField(
                controller: _pass, obscureText: _obs,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _go(),
                decoration: InputDecoration(
                  labelText: 'كلمة المرور (6 أحرف فأكثر)',
                  prefixIcon: const Icon(Icons.lock_outline, color: C.gold),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: dark ? C.dMu : C.lMu),
                    onPressed: () => setState(() => _obs = !_obs)))),
              const SizedBox(height: 24),

              GoldBtn(
                text: 'إنشاء الحساب',
                onTap: isLoading ? null : _go,
                loading: isLoading,
                icon: Icons.check_circle_outline),
            ])),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: RichText(text: TextSpan(children: [
              TextSpan(text: 'لديك حساب؟ ',
                style: GoogleFonts.tajawal(
                  color: dark ? C.dMu : C.lMu, fontSize: 14)),
              TextSpan(text: 'سجّل دخولك',
                style: GoogleFonts.tajawal(
                  color: C.gold, fontWeight: FontWeight.w800, fontSize: 14)),
            ]))),
        ]))));
  }
}