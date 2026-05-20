import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/auth_prov.dart';
import 'providers/court_prov.dart';
import 'providers/notif_prov.dart';
import 'providers/res_prov.dart';
import 'providers/theme_prov.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/root_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final theme = ThemeProv();
  final auth = AuthProv();

  runApp(
    NadiApp(
      theme: theme,
      auth: auth,
    ),
  );
}

class NadiApp extends StatelessWidget {
  final ThemeProv theme;
  final AuthProv auth;

  const NadiApp({
    super.key,
    required this.theme,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => CourtProv()),
        ChangeNotifierProvider(create: (_) => ResProv()),
        ChangeNotifierProvider(create: (_) => NotifProv()),
      ],
      child: Consumer<ThemeProv>(
        builder: (_, t, __) {
          return MaterialApp(
            title: K.appName,
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode: t.mode,
            locale: const Locale('ar'),
            builder: (ctx, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },

            // Splash appears first, while theme/auth are loading.
            home: SplashScreen(
              nextScreen: const RootScreen(),
              duration: const Duration(seconds: 5),
              onInit: () async {
                await theme.load();
                await auth.restore();
              },
            ),
          );
        },
      ),
    );
  }
}