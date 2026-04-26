import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              30.verticalSpace,
              // Welcome Text
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              8.verticalSpace,
              Text(
                'Sign in to continue your journey of connection.',
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
              _buildTextField(
                context: context,
                label: 'Email Address',
                hintText: 'hello@amora.com',
              ),
              20.verticalSpace,
              _buildTextField(
                context: context,
                label: 'Password',
                hintText: '••••••••',
                isPassword: true,
              ),
              10.verticalSpace,
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      wordSpacing: 2.5,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              20.verticalSpace,
              // Login Button
              ElevatedButton(
                onPressed: () {},
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text(
                  "Login",
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
                      'or continue with',
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

              buildSocialButton(
                label: 'Google',
                icon: Icons.g_mobiledata, // Placeholder for Google logo
                color: Colors.white,
                textColor: AppColors.textPrimary,
              ),

              30.verticalSpace,
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to Amora? ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  2.horizontalSpace,
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Sign up',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(fontSize: 14.sp),
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

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hintText,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
        ),
        8.verticalSpace,
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15.r),
        border: color == Colors.white
            ? Border.all(color: Colors.grey[300]!)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24.sp),
          8.horizontalSpace,
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
