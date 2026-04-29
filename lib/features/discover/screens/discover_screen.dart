import 'package:amora/features/discover/widgets/active_filters_list.dart';
import 'package:amora/features/discover/widgets/discover_grid_card.dart';
import 'package:amora/features/discover/widgets/discover_swipe_view.dart';
import 'package:amora/features/discover/widgets/mode_toggle.dart';
import 'package:amora/features/home/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool isGridMode = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: isGridMode
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
                    itemCount: 8, // Dummy count
                    itemBuilder: (context, index) {
                      return DiscoverGridCard(index: index);
                    },
                  )
                : const DiscoverSwipeView(),
          ),
        ],
      ),
    );
  }
}
