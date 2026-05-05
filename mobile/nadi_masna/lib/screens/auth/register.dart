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
  bool _submitted = false; // ← prevent double tap

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m, style: GoogleFonts.tajawal()),
      backgroundColor: C.err,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Future<void> _go() async {
    // Prevent double submission
    if (_submitted) return;

    final name  = _name.text.trim();
    final email = _email.text.trim();
    final pass  = _pass.text;
    final phone = _phone.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _snack('جميع الحقول مطلوبة');
      return;
    }
    if (pass.length < 6) {
      _snack('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _snack('أدخل بريد إلكتروني صحيح');
      return;
    }

    setState(() => _submitted = true);

    final ok = await context.read<AuthProv>().register(name, email, pass, phone);

    if (!ok && mounted) {
      setState(() => _submitted = false); // allow retry on failure
      _snack(context.read<AuthProv>().err ?? 'فشل إنشاء الحساب');
    }
    // On success: AuthProv notifies listeners → _Root navigates automatically
  }

  @override
  Widget build(BuildContext ctx) {
    final auth = ctx.watch<AuthProv>();
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    final isLoading = auth.loading || _submitted;

    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب جديد', style: GoogleFonts.tajawal()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 8),

          // Name
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: const Icon(Icons.person_outline, color: C.gold),
            ),
          ),
          const SizedBox(height: 14),

          // Email
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: const Icon(Icons.email_outlined, color: C.gold),
            ),
          ),
          const SizedBox(height: 14),

          // Phone
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: const Icon(Icons.phone_outlined, color: C.gold),
            ),
          ),
          const SizedBox(height: 14),

          // Password
          TextField(
            controller: _pass,
            obscureText: _obs,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _go(),
            decoration: InputDecoration(
              labelText: 'كلمة المرور (6 أحرف فأكثر)',
              prefixIcon: const Icon(Icons.lock_outline, color: C.gold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: dark ? C.dMu : C.lMu,
                ),
                onPressed: () => setState(() => _obs = !_obs),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Submit button
          GoldBtn(
            text: 'إنشاء الحساب',
            onTap: isLoading ? null : _go,
            loading: isLoading,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 16),

          // Back to login
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'لديك حساب؟ ',
                    style: GoogleFonts.tajawal(
                      color: dark ? C.dMu : C.lMu,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: 'سجّل دخولك',
                    style: GoogleFonts.tajawal(
                      color: C.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}