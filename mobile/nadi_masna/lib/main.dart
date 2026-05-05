import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_prov.dart';
import 'providers/court_prov.dart';
import 'providers/notif_prov.dart';
import 'providers/res_prov.dart';
import 'providers/theme_prov.dart';
import 'screens/auth/login.dart';
import 'screens/user/home.dart';
import 'screens/user/book.dart';
import 'screens/user/my_bookings.dart';
import 'screens/user/profile.dart';
import 'screens/admin/admin_shell.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final theme = ThemeProv();
  final auth  = AuthProv();
  await theme.load();
  await auth.restore();
  runApp(NadiApp(theme: theme, auth: auth));
}

class NadiApp extends StatelessWidget {
  final ThemeProv theme;
  final AuthProv auth;
  const NadiApp({super.key, required this.theme, required this.auth});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: theme),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(create: (_) => CourtProv()),
      ChangeNotifierProvider(create: (_) => ResProv()),
      ChangeNotifierProvider(create: (_) => NotifProv()),
    ],
    child: Consumer<ThemeProv>(
      builder: (_, t, __) => MaterialApp(
        title: K.appName,
        debugShowCheckedModeBanner: false,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: t.mode,
        locale: const Locale('ar'),
        builder: (ctx, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: const _Root(),
      ),
    ),
  );
}

class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProv>();
    if (!auth.ok) return const LoginScreen();
    if (auth.isAdmin) return const AdminShell();
    return const UserShell();
  }
}

// ═══ User Shell ═══════════════════════════════════════════════════════════════
class UserShell extends StatefulWidget {
  const UserShell({super.key});
  @override State<UserShell> createState() => _US();
}
class _US extends State<UserShell> {
  int _tab = 0;
  late final List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(goTo: (i) => setState(() => _tab = i)),
      const BookScreen(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProv>().isDark;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.gold, C.goldL]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text('AFC', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1))),
          ),
          const SizedBox(width: 10),
          Text(K.appName, style: GoogleFonts.tajawal(color: C.gold, fontWeight: FontWeight.w800, fontSize: 17)),
        ]),
        actions: [
          Padding(padding: const EdgeInsets.only(left: 8), child: GestureDetector(
            onTap: () => context.read<ThemeProv>().toggle(),
            child: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: C.gold),
          )),
        ],
      ),
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'حجز'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note), label: 'حجوزاتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'ملفي'),
        ],
      ),
    );
  }
}
