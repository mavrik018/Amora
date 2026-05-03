import 'package:amora/shared/widgets/bottom_nav_bar.dart';
import 'package:amora/core/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_steps.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(
        () => ref.read(onboardingProvider.notifier).requestLocationPermission(),
      );
      return null;
    }, []);

    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);

    final steps = [
      const CredentialsStep(),
      const BasicInfoStep(),
      const PersonalizationStep(),
      const MediaStep(),
    ];

    final stepLabels = ['Account', 'About You', 'Interests', 'Media'];
    final isLastStep = state.currentStep == steps.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: state.currentStep > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.onSurface,
                  size: 20.r,
                ),
                onPressed: notifier.previousStep,
              )
            : null,
        title: Text(
          stepLabels[state.currentStep],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                '${state.currentStep + 1} of ${steps.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Row(
                children: List.generate(steps.length, (i) {
                  final isActive = i == state.currentStep;
                  final isDone = i < state.currentStep;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99.r),
                              color: isDone || isActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        if (i < steps.length - 1) 6.horizontalSpace,
                      ],
                    ),
                  );
                }),
              ),
            ),

            12.verticalSpace,

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: steps[state.currentStep],
              ),
            ),

            if (state.errorMessage != null)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16.r,
                        color: theme.colorScheme.error,
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final latestState = ref.read(onboardingProvider);
                        String? validationError;

                        if (latestState.currentStep == 0) {
                          if (latestState.email.isEmpty ||
                              !latestState.email.contains('@')) {
                            validationError =
                                'Please enter a valid email address.';
                          } else if (latestState.password.length < 6) {
                            validationError =
                                'Password must be at least 6 characters.';
                          }
                        } else if (latestState.currentStep == 1) {
                          if (latestState.fullName.trim().isEmpty) {
                            validationError = 'Please enter your full name.';
                          } else if (latestState.dob == null) {
                            validationError =
                                'Please select your date of birth.';
                          } else if (latestState.gender.isEmpty) {
                            validationError = 'Please select your gender.';
                          } else if (latestState.interestedIn.isEmpty) {
                            validationError =
                                'Please select who you are interested in.';
                          } else if (latestState.relationshipIntent == null) {
                            validationError =
                                'Please select your relationship intent.';
                          }
                        } else if (latestState.currentStep == 2) {
                          if (latestState.prompts.length < 2) {
                            validationError =
                                'Please answer at least 2 personality prompts.';
                          }
                        }

                        if (validationError != null) {
                          CustomSnackBar.show(
                            context,
                            message: validationError,
                            type: SnackBarType.error,
                          );
                          return;
                        }

                        if (latestState.currentStep < steps.length - 1) {
                          notifier.nextStep();
                        } else {
                          if (latestState.photos.isEmpty) {
                            CustomSnackBar.show(
                              context,
                              message:
                                  'Please upload at least 1 profile photo.',
                              type: SnackBarType.error,
                            );
                            return;
                          }
                          await notifier.signUp();
                          if (context.mounted) {
                            final afterSignUpState = ref.read(
                              onboardingProvider,
                            );
                            if (afterSignUpState.errorMessage == null) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const BottomNavBar(),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  disabledBackgroundColor: theme.colorScheme.primary
                      .withOpacity(0.4),
                ),
                child: state.isLoading
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isLastStep ? 'Complete Sign Up' : 'Continue',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
