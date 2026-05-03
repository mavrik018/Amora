import 'package:amora/features/profile/models/profile_model.dart';
import 'package:amora/features/profile/widgets/profile_audio_bio.dart';
import 'package:amora/features/profile/widgets/profile_header_info.dart';
import 'package:amora/features/profile/widgets/profile_image_gallery.dart';
import 'package:amora/features/profile/widgets/profile_interests_section.dart';
import 'package:amora/features/profile/widgets/profile_prompt_cards.dart';
import 'package:amora/features/chat/providers/connection_provider.dart';
import 'package:amora/features/discover/providers/profiles.dart';
import 'dart:io';
import 'package:amora/features/profile/providers/block_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) =>
                        _handleMenuAction(context, ref, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'not_interested',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_off_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Not Interested'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(
                              Icons.report_outlined,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Report Profile',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
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
          child: Consumer(
            builder: (context, ref, child) {
              final connectionStatusAsync = ref.watch(
                checkConnectionStatusProvider(profile.id),
              );

              return connectionStatusAsync.when(
                data: (status) {
                  final bool alreadyConnected = status != null;
                  final String buttonText;
                  if (status == 'pending') {
                    buttonText = 'Request Pending';
                  } else if (status == 'accepted') {
                    buttonText = 'Connected';
                  } else if (status == 'rejected') {
                    buttonText = 'Request Rejected';
                  } else {
                    buttonText = 'Send Connection Request';
                  }

                  return StatefulBuilder(
                    builder: (context, setButtonState) {
                      bool isLoading = false;

                      return ElevatedButton(
                        onPressed: (isLoading || alreadyConnected)
                            ? null
                            : () async {
                                setButtonState(() => isLoading = true);

                                try {
                                  await ref
                                      .read(connectionProvider)
                                      .sendConnectionRequest(profile.id);

                                  if (context.mounted) {
                                    ref.invalidate(
                                      checkConnectionStatusProvider(profile.id),
                                    );
                                    ref.invalidate(otherProfilesProvider);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Connection request sent!',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to send request: $e',
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setButtonState(() => isLoading = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          disabledBackgroundColor: alreadyConnected
                              ? (status == 'accepted'
                                    ? Colors.green.withOpacity(0.6)
                                    : Colors.grey.withOpacity(0.6))
                              : null,
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                buttonText,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error checking connection: $e'),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'not_interested') {
      _showBlockConfirmation(context, ref);
    } else if (action == 'report') {
      _showReportDialog(context, ref);
    }
  }

  void _showBlockConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Interested?'),
        content: Text('We won\'t show ${profile.fullName} to you anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(blockRepositoryProvider).blockUser(profile.id);
              if (context.mounted) {
                ref.invalidate(otherProfilesProvider);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${profile.fullName} hidden')),
                );
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isSubmitting = false;

          return AlertDialog(
            title: const Text('Report Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason for reporting',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Fake profile, Harassment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Provide more details...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  const Text(
                    'Evidence (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  if (selectedImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            selectedImage!,
                            height: 100.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedImage = null),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                        );
                        if (image != null) {
                          setDialogState(
                            () => selectedImage = File(image.path),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Add Screenshot'),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (reasonController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please provide a reason'),
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isSubmitting = true);

                        try {
                          await ref
                              .read(blockRepositoryProvider)
                              .reportUser(
                                reportedId: profile.id,
                                reason: reasonController.text,
                                description: descriptionController.text,
                                evidenceImage: selectedImage,
                              );

                          if (context.mounted) {
                            ref.invalidate(otherProfilesProvider);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Report submitted. Profile hidden.',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setDialogState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
