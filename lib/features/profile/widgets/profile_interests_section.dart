import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileInterestsSection extends StatelessWidget {
  final List<Map<String, dynamic>> interests;
  const ProfileInterestsSection({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 8.w,
      runSpacing: 12.h,
      children: interests.map((interest) {
        final isSelected = interest['selected'] as bool;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Text(
            interest['label'] as String,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontSize: 9.sp,
              letterSpacing: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}
