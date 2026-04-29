import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/profile_image_gallery.dart';
import '../widgets/profile_header_info.dart';
import '../widgets/profile_audio_bio.dart';
import '../widgets/profile_prompt_cards.dart';
import '../widgets/profile_staggered_grid.dart';
import '../widgets/profile_interests_section.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  final List<int> _dummyImages = const [1, 2, 3];

  final List<Map<String, dynamic>> _interests = const [
    {'label': 'JAZZ', 'selected': false},
    {'label': 'ART GALLERIES', 'selected': false},
    {'label': 'WINE CULTURE', 'selected': false},
    {'label': 'COOKING', 'selected': true},
    {'label': 'HIKING', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 120.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileImageGallery(images: _dummyImages),

                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProfileHeaderInfo(),
                      SizedBox(height: 24.h),
                      const ProfileAudioBio(),
                      SizedBox(height: 24.h),
                      const ProfilePromptCards(),
                      SizedBox(height: 8.h),
                      const ProfileStaggeredGrid(),
                      SizedBox(height: 24.h),
                      ProfileInterestsSection(interests: _interests),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to Edit Profile Screen
            },
            borderRadius: BorderRadius.circular(30.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Edit Profile',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
