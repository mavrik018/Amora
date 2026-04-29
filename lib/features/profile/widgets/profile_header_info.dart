import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileHeaderInfo extends StatelessWidget {
  const ProfileHeaderInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name, Age, Verification and Intent
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Amora, 26',
                          style: theme.textTheme.headlineLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.verified, color: Colors.blue, size: 22.sp),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14.sp, color: Colors.grey.shade700),
                      SizedBox(width: 4.w),
                      Text(
                        '3.2 km away',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Seeking Serious Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Seeking Serious',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 24.h),
        
        // Bio
        Text(
          'Artsy soul with a love for deep\nconversations and rainy days at jazz clubs.\nLooking for someone who appreciates\nthe finer things and isn\'t afraid of a little\nadventure. 🌿✨',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
