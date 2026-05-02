import 'package:amora/features/discover/providers/profiles.dart';
import 'package:amora/features/discover/widgets/active_filters_list.dart';
import 'package:amora/features/discover/widgets/discover_grid_card.dart';
import 'package:amora/features/discover/widgets/discover_swipe_view.dart';
import 'package:amora/features/discover/widgets/mode_toggle.dart';
import 'package:amora/features/home/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  bool isGridMode = true;

  int calculateAge(String dobString) {
    final dob = DateTime.parse(dobString);
    final today = DateTime.now();

    int age = today.year - dob.year;

    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = ref.watch(otherProfilesProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discover', style: theme.textTheme.headlineLarge),
                ModeToggle(
                  isGridMode: isGridMode,
                  onModeChanged: (value) {
                    setState(() {
                      isGridMode = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const ActiveFiltersList(),
          SizedBox(height: 16.h),

          Expanded(
            child: profileProvider.when(
              data: (profiles) {
                if (profiles.isEmpty) {
                  return const Center(child: Text('No profiles found'));
                }
                return isGridMode
                    ? GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          final name = profile['full_name'];
                          final location = profile['location_name'];
                          final dob = profile['dob'];
                          final age = calculateAge(dob);
                          final imageUrl = profile['photos'][0];
                          return DiscoverGridCard(
                            index: index,
                            age: age,
                            location: location,
                            name: name,
                            imageUrl: imageUrl,
                            profile: profile,
                          );
                        },
                      )
                    : PageView.builder(
                        itemCount: profiles.length,
                        controller: PageController(viewportFraction: 0.9),
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          final name = profile['full_name'];
                          final location = profile['location_name'];
                          final dob = profile['dob'];
                          final age = calculateAge(dob);
                          final imageUrl = profile['photos'][0];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 8.h,
                            ),
                            child: DiscoverSwipeCard(
                              index: index,
                              name: name,
                              age: age,
                              location: location,
                              imageUrl: imageUrl,
                              profile: profile,
                            ),
                          );
                        },
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
