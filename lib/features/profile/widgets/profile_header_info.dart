import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/profile_model.dart';
import '../../../core/constants/enums.dart';

class ProfileHeaderInfo extends StatelessWidget {
  final ProfileModel profile;
  const ProfileHeaderInfo({super.key, required this.profile});

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _getIntentLabel(RelationshipIntent? intent) {
    switch (intent) {
      case RelationshipIntent.serious:
        return 'Serious Match';
      case RelationshipIntent.casual:
        return 'Casual Dating';
      case RelationshipIntent.openToBoth:
        return 'Open to Either';
      default:
        return 'Looking Around';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = _calculateAge(profile.dob);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          profile.fullName,
                          style: theme.textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (profile.isVerified) ...[
                        SizedBox(width: 8.w),
                        Icon(Icons.verified, color: Colors.blue, size: 22.sp),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                _getIntentLabel(profile.relationshipIntent),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
