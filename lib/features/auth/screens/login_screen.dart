import 'package:amora/core/widgets/text_field.dart';
import 'package:amora/core/widgets/social_button.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:amora/features/profile/screens/admin_screen.dart';
import 'package:amora/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/colors.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (_email.trim().isEmpty || _password.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.signInWithPassword(
        email: _email.trim(),
        password: _password.trim(),
      );

      if (mounted) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          await AuthService.persistLogin(user.id);

          final profile = await ref.read(userProfileProvider.future);
          if (mounted) {
            final dest = profile?.isAdmin == true
                ? const AdminScreen()
                : const BottomNavBar();

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => dest),
              (route) => false,
            );
          }
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Amora",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                20.verticalSpace,
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

                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20.r,
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                BuildTextField(
                  label: 'Email Address',
                  hintText: 'hello@amora.com',
                  onChanged: (val) => _email = val,
                ),
                20.verticalSpace,
                BuildTextField(
                  label: 'Password',
                  hintText: '••••••••',
                  isPassword: true,
                  onChanged: (val) => _password = val,
                ),
                10.verticalSpace,
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
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: _isLoading
                      ? SizedBox(
                          height: 20.r,
                          width: 20.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "Login",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                ),
                30.verticalSpace,
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

                BuildSocialButton(
                  label: 'Google',
                  icon: Icons.g_mobiledata,
                  color: Colors.white,
                  textColor: AppColors.textPrimary,
                ),

                30.verticalSpace,
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
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
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
      ),
    );
  }
}
