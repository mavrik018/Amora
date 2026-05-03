import 'package:amora/features/chat/screens/chat_list_screen.dart';
import 'package:amora/features/profile/screens/user_profile_view.dart';
import 'package:amora/shared/widgets/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:amora/features/home/screens/home_screen.dart';
import 'package:amora/features/discover/screens/discover_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
