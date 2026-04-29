import 'package:amora/core/widgets/date_picker_field.dart';
import 'package:amora/core/widgets/social_button.dart';
import 'package:amora/core/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/colors.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Text(
                "Amora",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              20.verticalSpace,
              // Hero Image
              Container(
                height: 250.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/banner2.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
              // Title
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              8.verticalSpace,
              Text(
                'Join Amora to start your journey of connection.',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF8A7174),
                  fontSize: 14.sp,
                  letterSpacing: 0.3,
                  height: 1.7,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              20.verticalSpace,
              const BuildTextField(label: 'Full Name', hintText: 'John Doe'),
              20.verticalSpace,
              const BuildTextField(
                label: 'Email Address',
                hintText: 'hello@amora.com',
              ),
              20.verticalSpace,
              BuildDatePickerField(
                label: 'Date of Birth',
                hintText: 'DD/MM/YYYY',
              ),
              20.verticalSpace,
              const BuildTextField(
                label: 'Password',
                hintText: '••••••••',
                isPassword: true,
              ),
              30.verticalSpace,
              // Sign Up Button
              ElevatedButton(
                onPressed: () {},
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text(
                  "Register",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              30.verticalSpace,
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'or join with',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              30.verticalSpace,
              // Social Sign Up
              BuildSocialButton(
                label: 'Google',
                icon: Icons.g_mobiledata,
                color: Colors.white,
                textColor: AppColors.textPrimary,
              ),
              20.verticalSpace,
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
