import 'package:amora/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amora/features/home/widgets/filters_bottom_sheet.dart';
import 'package:amora/features/home/widgets/location_picker_sheet.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LocationPickerSheet(),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                profileAsync.when(
                  data: (profile) => Text(
                    profile?.locationName ?? 'Select Location',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  loading: () => SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, s) => const Text('Error'),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FiltersBottomSheet(),
              );
            },
            icon: Icon(Icons.tune, color: AppColors.primary, size: 24.w),
          ),
        ],
      ),
    );
  }
}
