import 'package:amora/features/discover/providers/filters_provider.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActiveFiltersList extends ConsumerWidget {
  const ActiveFiltersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(discoveryFiltersProvider);
    final filterNotifier = ref.read(discoveryFiltersProvider.notifier);
    final userProfile = ref.watch(userProfileProvider).value;

    final List<Widget> chips = [];

    // Age chip
    chips.add(
      _buildFilterChip(
        theme,
        '${filters.minAge.round()}-${filters.maxAge.round()}',
        onDelete: () {
          filterNotifier.setAgeRange(const RangeValues(18, 24));
        },
      ),
    );

    // Verified chip
    if (filters.verifiedOnly) {
      chips.add(SizedBox(width: 8.w));
      chips.add(
        _buildFilterChip(
          theme,
          'Verified Only',
          onDelete: () {
            filterNotifier.setVerifiedOnly(false);
          },
        ),
      );
    }

    // Distance/Location chip
    final locationName = userProfile?.locationName ?? 'Location';
    chips.add(SizedBox(width: 8.w));
    chips.add(
      _buildFilterChip(
        theme,
        '$locationName +${filters.distance.round()}km',
        onDelete: () {
          filterNotifier.setDistance(50);
        },
      ),
    );

    // Gender chip
    chips.add(SizedBox(width: 8.w));
    chips.add(
      _buildFilterChip(
        theme,
        filters.gender,
        onDelete: () {
          // Maybe don't delete gender but reset to default
          filterNotifier.setGender('Woman');
        },
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(children: chips),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label, {
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          border: Border.all(color: theme.primaryColor),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.close, size: 16.w, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }
}
