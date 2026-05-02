import 'package:amora/features/home/widgets/home_header.dart';
import 'package:amora/features/home/widgets/profile_card.dart';
import 'package:amora/features/home/widgets/seeAll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const ProfileCard(),
            ],
          ),
        ),
      ),
    );
  }
}
