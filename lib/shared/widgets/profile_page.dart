import 'package:amora/features/profile/models/profile_model.dart';
import 'package:amora/features/profile/widgets/profile_audio_bio.dart';
import 'package:amora/features/profile/widgets/profile_header_info.dart';
import 'package:amora/features/profile/widgets/profile_image_gallery.dart';
import 'package:amora/features/profile/widgets/profile_interests_section.dart';
import 'package:amora/features/profile/widgets/profile_prompt_cards.dart';
import 'package:amora/features/chat/providers/connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends ConsumerWidget {
  final ProfileModel profile;
  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
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
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(connectionProvider)
                    .sendConnectionRequest(profile.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connection request sent!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send request: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Send Connection Request',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
