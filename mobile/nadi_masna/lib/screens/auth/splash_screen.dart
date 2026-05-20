import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  final Duration duration;
  final Future<void> Function()? onInit;

  const SplashScreen({
    super.key,
    required this.nextScreen,
    this.duration = const Duration(seconds: 3),
    this.onInit,
  });

  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _roll;
  late final AnimationController _fade;

  late final Animation<double> _ballX;
  late final Animation<double> _ballRotate;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _logoFade;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _roll = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _ballX = Tween<double>(
      begin: -140,
      end: 140,
    ).animate(
      CurvedAnimation(
        parent: _roll,
        curve: Curves.easeInOut,
      ),
    );

    _ballRotate = Tween<double>(
      begin: 0,
      end: 6.28,
    ).animate(_roll);

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_fade);

    _logoFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fade,
        curve: const Interval(
          0.5,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );

    _fade.forward();
    _roll.repeat(reverse: true);

    _start();
  }

  Future<void> _start() async {
    try {
      await Future.wait([
        Future.delayed(widget.duration),
        if (widget.onInit != null) widget.onInit!(),
      ]);
    } catch (e) {
      debugPrint('Splash init error: $e');
    }

    if (!mounted || _navigated) return;

    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _roll.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: C.dBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoFade,
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [C.gold, C.goldL],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: C.gold.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'ACF',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'نادي مصنع الطائرات',
                      style: GoogleFonts.tajawal(
                        color: C.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Aircraft Factory Club',
                      style: GoogleFonts.roboto(
                        color: C.dMu,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              SizedBox(
                height: 80,
                width: 330,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            C.gold.withOpacity(0.3),
                            C.gold.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _roll,
                      builder: (_, __) {
                        return Transform.translate(
                          offset: Offset(_ballX.value, -20),
                          child: Transform.rotate(
                            angle: _ballRotate.value,
                            child: const Text(
                              '⚽',
                              style: TextStyle(fontSize: 44),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              AnimatedBuilder(
                animation: _roll,
                builder: (_, __) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = (_roll.value * 3).floor() % 3 == i;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 12 : 8,
                        height: active ? 12 : 8,
                        decoration: BoxDecoration(
                          color: active ? C.gold : C.dMu,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}