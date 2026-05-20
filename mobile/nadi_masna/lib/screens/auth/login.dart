import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_prov.dart';
import '../../providers/theme_prov.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/w.dart';
import '../root_screen.dart';
import 'register.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _S();
}

class _S extends State<LoginScreen> {
  final _e = TextEditingController();
  final _p = TextEditingController();

  bool _obs = true;
  bool _submitted = false;

  @override
  void dispose() {
    _e.dispose();
    _p.dispose();
    super.dispose();
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          m,
          style: GoogleFonts.tajawal(),
        ),
        backgroundColor: C.err,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _go() async {
    if (_submitted) return;

    final email = _e.text.trim();
    final password = _p.text;

    if (email.isEmpty || password.isEmpty) {
      _snack('أدخل البيانات المطلوبة');
      return;
    }

    setState(() => _submitted = true);

    final ok = await context.read<AuthProv>().login(email, password);

    if (!mounted) return;

    setState(() => _submitted = false);

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) {
            return const SplashScreen(
              nextScreen: RootScreen(),
              duration: Duration(seconds: 2),
            );
          },
        ),
      );
    } else {
      _snack(context.read<AuthProv>().err ?? 'فشل الدخول');
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final auth = ctx.watch<AuthProv>();
    final theme = ctx.watch<ThemeProv>();
    final dark = theme.isDark;
    final isLoading = auth.loading || _submitted;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => ctx.read<ThemeProv>().toggle(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: dark ? C.dCard : C.lCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: dark ? C.dBdr : C.lBdr,
                      ),
                    ),
                    child: Icon(
                      dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: C.gold,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [C.gold, C.goldL],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'ACF',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              Text(
                K.appName,
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: C.gold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Aircraft Factory Club',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: dark ? C.dMu : C.lMu,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                decoration: BoxDecoration(
                  color: dark ? C.dCard : C.lCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: dark ? C.dBdr : C.lBdr,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: dark ? C.dTx : C.lTx,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _e,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: C.gold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _p,
                      obscureText: _obs,
                      enabled: !isLoading,
                      onSubmitted: (_) => _go(),
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: C.gold,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obs
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: dark ? C.dMu : C.lMu,
                          ),
                          onPressed: isLoading
                              ? null
                              : () => setState(() => _obs = !_obs),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    GoldBtn(
                      text: 'دخول',
                      onTap: isLoading ? null : _go,
                      loading: isLoading,
                      icon: Icons.login_rounded,
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'ليس لديك حساب؟ ',
                                style: GoogleFonts.tajawal(
                                  color: dark ? C.dMu : C.lMu,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: 'سجّل الآن',
                                style: GoogleFonts.tajawal(
                                  color: C.gold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: C.gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: C.gold.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'بيانات الدخول التجريبية',
                      style: GoogleFonts.tajawal(
                        color: C.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مدير: admin@nadi.com / admin123',
                      style: GoogleFonts.tajawal(
                        color: dark ? C.dMu : C.lMu,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'عضو: ahmed@nadi.com / user123',
                      style: GoogleFonts.tajawal(
                        color: dark ? C.dMu : C.lMu,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}