// Get Started screen
import 'package:amora/features/onboarding/widgets/cta_button.dart';
import 'package:amora/features/onboarding/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/couple.jpg'),
            fit: BoxFit.cover,
            opacity: 0.35,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD81B60),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    "Amora",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  5.verticalSpace,
                  Container(
                    width: 50.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  20.verticalSpace,
                  Text(
                    "Find Real Connections that Matter",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      letterSpacing: 0.5,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  20.verticalSpace,
                  Text(
                    "Experience a modern romantic journey designed for meaningful discovery and genuine chemistry.",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF8A7174),
                      fontSize: 14.sp,
                      letterSpacing: 0.3,
                      height: 1.7,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  30.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Transform.rotate(
                        angle: -0.12,
                        child: const ProfileCard(
                          imagePath: 'assets/images/girl.jpg',
                        ),
                      ),
                      Transform.rotate(
                        angle: 0.12,
                        child: const ProfileCard(
                          imagePath: 'assets/images/guy.jpg',
                        ),
                      ),
                    ],
                  ),
                  30.verticalSpace,
                  const CtaButton(),
                  10.verticalSpace,
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "LOG IN",
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
