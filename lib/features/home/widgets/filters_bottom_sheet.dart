import 'package:amora/core/constants/colors.dart';
import 'package:amora/features/discover/providers/filters_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FiltersBottomSheet extends ConsumerWidget {
  const FiltersBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(discoveryFiltersProvider);
    final filterNotifier = ref.read(discoveryFiltersProvider.notifier);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      final defaults = ref.read(
                        defaultDiscoveryFiltersProvider,
                      );
                      filterNotifier.reset(defaults);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'RESET',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Age Range',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '${filters.minAge.round()} - ${filters.maxAge.round()}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20.0,
                  ),
                  trackHeight: 4.0,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(0.15),
                  thumbColor: Colors.white,
                ),
                child: RangeSlider(
                  values: RangeValues(filters.minAge, filters.maxAge),
                  min: 18,
                  max: 65,
                  onChanged: (values) {
                    filterNotifier.setAgeRange(values);
                  },
                ),
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Up to ${filters.distance.round()} km',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20.0,
                  ),
                  trackHeight: 4.0,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primary.withOpacity(0.15),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: filters.distance,
                  min: 1,
                  max: 10000,
                  onChanged: (value) {
                    filterNotifier.setDistance(value);
                  },
                ),
              ),
              SizedBox(height: 24.h),

              Text(
                'Show Me',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildGenderButton('Woman', filters.gender, filterNotifier),
                    SizedBox(width: 8.w),
                    _buildGenderButton('Man', filters.gender, filterNotifier),
                    SizedBox(width: 8.w),
                    _buildGenderButton(
                      'Non-binary',
                      filters.gender,
                      filterNotifier,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: AppColors.secondary,
                      size: 28.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verified Only',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'See only authenticated profiles',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textPrimary.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: filters.verifiedOnly,
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade300,
                      onChanged: (value) {
                        filterNotifier.setVerifiedOnly(value);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(
    String gender,
    String selectedGender,
    DiscoveryFiltersNotifier notifier,
  ) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        notifier.setGender(gender);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          gender,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
