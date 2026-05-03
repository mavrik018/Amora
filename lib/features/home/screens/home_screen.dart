import 'package:amora/features/discover/providers/profiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/home_header.dart';
import '../widgets/profile_card.dart';
import '../widgets/seeAll.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestMatchAsync = ref.watch(bestMatchProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Best Match",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Curated just for you",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                    SeeAllButton(tabIndex: 1),
                  ],
                ),
              ),
              //SizedBox(height: 16.h),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 20.w),
              //   child: Container(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: 20.w,
              //       vertical: 10.h,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).primaryColor,
              //       borderRadius: BorderRadius.circular(20.r),
              //       border: null,
              //     ),
              //     child: Text(
              //       'For You',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.w600,
              //         fontSize: 14.sp,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: 16.h),
              bestMatchAsync.when(
                data: (profile) => profile != null
                    ? ProfileCard(profile: profile)
                    : const Center(child: Text('No matches found yet')),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading match: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
