import 'package:amora/features/chat/screens/chat_list_screen.dart';
import 'package:amora/features/profile/screens/user_profile_view.dart';
import 'package:amora/shared/widgets/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:amora/features/home/screens/home_screen.dart';
import 'package:amora/features/discover/screens/discover_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:amora/features/profile/screens/banned_screen.dart';

import 'package:amora/features/auth/screens/login_screen.dart';
import 'package:amora/core/services/auth_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    ChatListScreen(),
    UserProfileView(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    return profileAsync.when(
      data: (profile) {
        if (profile?.isBanned == true) {
          return const BannedScreen();
        }

        final currentIndex = ref.watch(bottomNavIndexProvider);
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Discover',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => _ErrorScreen(error: e.toString()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.error,
                size: 64.r,
              ),
              16.verticalSpace,
              Text(
                'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.verticalSpace,
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              32.verticalSpace,
              ElevatedButton.icon(
                onPressed: () async {
                  await AuthService.logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Force Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
