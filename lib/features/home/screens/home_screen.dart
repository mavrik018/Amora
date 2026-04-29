import 'package:amora/features/home/widgets/feed_tabs.dart';
import 'package:amora/features/home/widgets/home_header.dart';
import 'package:amora/features/home/widgets/profile_card.dart';
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
              SizedBox(height: 16.h),
              const FeedTabs(),
              SizedBox(height: 16.h),
              const ProfileCard(),
            ],
          ),
        ),
      ),
    );
  }
}
