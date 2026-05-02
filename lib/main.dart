import 'package:amora/core/theme/app_theme.dart';
import 'package:amora/features/onboarding/screens/get_started_screen.dart';
import 'package:amora/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:amora/core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Read the login state safely
  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(411.0, 914.0),
        minTextAdapt: true,
        builder: (context, child) => MyApp(isLoggedIn: isLoggedIn),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const BottomNavBar() : const GetStartedScreen(),
    );
  }
}
