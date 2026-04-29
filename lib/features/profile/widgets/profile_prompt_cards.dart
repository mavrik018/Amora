import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePromptCards extends StatelessWidget {
  const ProfilePromptCards({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4.w),
            ),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MY SIMPLE PLEASURE',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 10.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '"The smell of old books and\nfresh espresso on a Sunday\nmorning."',
                style: GoogleFonts.notoSerif(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 24.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WE\'LL GET ALONG IF',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF5B67A4), // Muted blue/purple
                  fontSize: 10.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '"You know the difference\nbetween a good playlist and a\ngreat one."',
                style: GoogleFonts.notoSerif(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
