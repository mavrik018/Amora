import 'package:amora/features/discover/providers/profiles.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:amora/core/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/home_header.dart';
import '../widgets/profile_card.dart';
import '../widgets/seeAll.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _statusController = TextEditingController();
  bool _isUpdatingStatus = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus() async {
    final status = _statusController.text.trim();
    if (status.isEmpty) {
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isUpdatingStatus = true);
    try {
      final userProfile = ref.read(userProfileProvider).value;
      if (userProfile != null) {
        await ref
            .read(profileRepositoryProvider)
            .updateStatus(userProfile.id, status);
        ref.invalidate(userProfileProvider);
        _statusController.clear();
        setState(() => _isEditing = false);
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Status updated!',
            type: SnackBarType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Error updating status: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bestMatchAsync = ref.watch(bestMatchProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: userProfileAsync.when(
                    data: (profile) {
                      final hasStatus =
                          profile?.statusToday != null &&
                          profile!.statusToday!.isNotEmpty;

                      if (hasStatus && !_isEditing) {
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'How are you feeling today?',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    profile.statusToday!,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _statusController.text = profile.statusToday!;
                                  _isEditing = true;
                                });
                              },
                              icon: Icon(
                                Icons.edit_note_rounded,
                                color: theme.colorScheme.primary,
                                size: 24.r,
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How are you feeling today?',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _statusController,
                                  autofocus: _isEditing,
                                  decoration: InputDecoration(
                                    hintText: 'Share your mood...',
                                    hintStyle: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.4),
                                        ),
                                    filled: true,
                                    fillColor: theme.colorScheme.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  style: theme.textTheme.bodyMedium,
                                  onSubmitted: (_) => _updateStatus(),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: _isUpdatingStatus ? null : _updateStatus,
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _isUpdatingStatus
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 20.r,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Best Match",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SeeAllButton(tabIndex: 1),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: bestMatchAsync.when(
                  data: (profile) => profile != null
                      ? ProfileCard(profile: profile)
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Container(
                            height: 200.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Center(
                              child: Text(
                                'No matches found yet',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                  loading: () => SizedBox(
                    height: 520.h,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text('Error loading match: $e'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
