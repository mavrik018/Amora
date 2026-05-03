import 'package:amora/features/profile/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import '../widgets/profile_image_gallery.dart';
import '../widgets/profile_header_info.dart';
import '../widgets/profile_audio_bio.dart';
import '../widgets/profile_prompt_cards.dart';
import '../widgets/profile_interests_section.dart';
import 'admin_screen.dart';
import '../providers/admin_provider.dart';
import 'verification_request_screen.dart';

class UserProfileView extends ConsumerWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 120.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileImageGallery(images: profile.photos),

                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileHeaderInfo(profile: profile),

                          SizedBox(height: 24.h),
                          ProfileAudioBio(audioBioUrl: profile.audioBioUrl),
                          SizedBox(height: 24.h),
                          ProfilePromptCards(prompts: profile.prompts),
                          SizedBox(height: 24.h),
                          ProfileInterestsSection(interests: profile.interests),
                          SizedBox(height: 32.h),
                          _VerificationStatusCard(profile: profile),
                          SizedBox(height: 40.h),
                          Center(
                            child: TextButton.icon(
                              onPressed: () async {
                                await AuthService.logout();
                              },
                              icon: Icon(
                                Icons.logout_rounded,
                                color: theme.colorScheme.error,
                                size: 20.sp,
                              ),
                              label: Text(
                                'Sign Out',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: theme.colorScheme.error.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: profileAsync.when(
        data: (profile) => profile == null
            ? null
            : Container(
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: profile),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
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
        loading: () => null,
        error: (err, stack) => null,
      ),
    );
  }
}

class _VerificationStatusCard extends ConsumerWidget {
  final ProfileModel profile;
  const _VerificationStatusCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final verificationAsync = ref.watch(userVerificationProvider);

    if (profile.isVerified) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.green),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verified Account',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Your identity has been confirmed.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return verificationAsync.when(
      data: (request) {
        String title = 'Verify Identity';
        String subtitle = 'Get a verification badge and build trust.';
        IconData icon = Icons.admin_panel_settings_outlined;
        Color color = theme.colorScheme.primary;

        if (request != null) {
          if (request.status == 'pending') {
            title = 'Verification Pending';
            subtitle = 'We are reviewing your ID.';
            icon = Icons.hourglass_empty_rounded;
            color = Colors.orange;
          } else if (request.status == 'rejected') {
            title = 'Verification Failed';
            subtitle = 'Tap to see reason and try again.';
            icon = Icons.error_outline_rounded;
            color = theme.colorScheme.error;
          }
        }

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const VerificationRequestScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color.withOpacity(0.5),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
