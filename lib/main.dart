import 'package:amora/core/providers/supabase_provider.dart';
import 'package:amora/core/theme/app_theme.dart';
import 'package:amora/features/auth/screens/login_screen.dart';
import 'package:amora/features/splash/screens/splash_screen.dart';
import 'package:amora/shared/widgets/notif_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (_, next) {
      if (next is AsyncData) {
        final state = next.value;
        if (state != null && state.event == AuthChangeEvent.signedOut) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const LoginScreen(),
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (_, animation, _, child) => FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                ),
                child: child,
              ),
            ),
            (route) => false,
          );
        }
      }
    });

    return ScreenUtilInit(
      designSize: const Size(411.0, 914.0),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          builder: (context, child) {
            return Stack(
              children: [if (child != null) child, const NotificationLayer()],
            );
          },
        );
      },
    );
  }
}
