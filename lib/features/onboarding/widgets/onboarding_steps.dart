import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/widgets/text_field.dart';
import '../../../core/widgets/date_picker_field.dart';
import '../../../core/constants/enums.dart';

// ─────────────────────────────────────────────
// Shared step header widget
// ─────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 28.r),
        ),
        16.verticalSpace,
        Text(title, style: theme.textTheme.headlineMedium),
        8.verticalSpace,
        Text(subtitle, style: theme.textTheme.bodyMedium),
        28.verticalSpace,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Shared section label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final String? badge;

  const _SectionLabel({required this.text, this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (badge != null) ...[
          6.horizontalSpace,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              badge!,
              style: theme.textTheme.labelLarge?.copyWith(fontSize: 10.sp),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Step 1: Credentials
// ─────────────────────────────────────────────
class CredentialsStep extends ConsumerWidget {
  const CredentialsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          icon: Icons.lock_outline_rounded,
          title: 'Create your account',
          subtitle: 'Secure your account with an email and strong password.',
        ),
        BuildTextField(
          label: 'Email Address',
          hintText: 'hello@amora.com',
          initialValue: state.email,
          onChanged: notifier.updateEmail,
        ),
        16.verticalSpace,
        BuildTextField(
          label: 'Password',
          hintText: 'Min. 6 characters',
          isPassword: true,
          initialValue: state.password,
          onChanged: notifier.updatePassword,
        ),
        20.verticalSpace,
        _InfoNote(
          icon: Icons.info_outline_rounded,
          text: 'Your password must be at least 6 characters long.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Step 2: Basic Info
// ─────────────────────────────────────────────
class BasicInfoStep extends ConsumerWidget {
  const BasicInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          icon: Icons.person_outline_rounded,
          title: 'About you',
          subtitle: 'This helps us show you to the right people.',
        ),
        BuildTextField(
          label: 'Full Name',
          hintText: 'e.g. Alex Johnson',
          initialValue: state.fullName,
          onChanged: notifier.updateFullName,
        ),
        16.verticalSpace,
        BuildDatePickerField(
          label: 'Date of Birth',
          hintText: 'Select your birthday',
          initialDate: state.dob,
          onDateSelected: notifier.updateDob,
        ),
        16.verticalSpace,
        _SectionLabel(text: 'Relationship Intent'),
        12.verticalSpace,
        _IntentSelector(
          selected: state.relationshipIntent,
          onSelected: notifier.updateRelationshipIntent,
        ),
      ],
    );
  }
}

class _IntentSelector extends StatelessWidget {
  final RelationshipIntent? selected;
  final ValueChanged<RelationshipIntent> onSelected;

  const _IntentSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: RelationshipIntent.values.map((intent) {
        final isSelected = selected == intent;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(intent),
            child: Container(
              margin: EdgeInsets.only(
                right: intent != RelationshipIntent.values.last ? 8.w : 0,
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                intent.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Step 3: Personalization
// ─────────────────────────────────────────────
class PersonalizationStep extends ConsumerWidget {
  const PersonalizationStep({super.key});

  static const _interests = [
    ('Travel', Icons.flight_takeoff_rounded),
    ('Music', Icons.music_note_rounded),
    ('Fitness', Icons.fitness_center_rounded),
    ('Art', Icons.palette_rounded),
    ('Gaming', Icons.sports_esports_rounded),
    ('Cooking', Icons.restaurant_rounded),
    ('Hiking', Icons.terrain_rounded),
    ('Movies', Icons.movie_rounded),
    ('Photography', Icons.camera_alt_rounded),
    ('Reading', Icons.menu_book_rounded),
  ];

  static const _prompts = [
    "My ideal Saturday morning looks like...",
    "My love language is usually expressed by...",
    "I will fight you (playfully) over my opinion on...",
    "A 'bucket list' goal I'm actually working towards is...",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          icon: Icons.auto_awesome_rounded,
          title: 'Your personality',
          subtitle: 'This powers compatibility scores and AI icebreakers.',
        ),
        _SectionLabel(text: 'Interests', badge: '${state.interests.length}/3'),
        8.verticalSpace,
        Text(
          'Pick up to 3 topics that define you.',
          style: theme.textTheme.bodyMedium,
        ),
        14.verticalSpace,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _interests.map(((String label, IconData icon) pair) {
            final isSelected = state.interests.contains(pair.$1);
            final atMax = state.interests.length >= 3 && !isSelected;
            return GestureDetector(
              onTap: atMax ? null : () => notifier.toggleInterest(pair.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : atMax
                      ? theme.colorScheme.surface.withOpacity(0.5)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pair.$2,
                      size: 16.r,
                      color: isSelected
                          ? Colors.white
                          : atMax
                          ? theme.colorScheme.onSurface.withOpacity(0.3)
                          : theme.colorScheme.primary,
                    ),
                    6.horizontalSpace,
                    Text(
                      pair.$1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : atMax
                            ? theme.colorScheme.onSurface.withOpacity(0.3)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        30.verticalSpace,
        _SectionLabel(
          text: 'Personality Prompts',
          badge: '${state.prompts.length}/4 answered',
        ),
        8.verticalSpace,
        Text(
          'Answer at least 2 to let people know the real you.',
          style: theme.textTheme.bodyMedium,
        ),
        16.verticalSpace,
        ..._prompts.map(
          (question) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: BuildTextField(
              label: question,
              hintText: 'Your answer...',
              initialValue: state.prompts[question],
              onChanged: (val) => notifier.updatePrompt(question, val),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Step 4: Media
// ─────────────────────────────────────────────
class MediaStep extends ConsumerWidget {
  const MediaStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          icon: Icons.photo_camera_rounded,
          title: 'Show yourself',
          subtitle: 'Profiles with photos get 10× more matches.',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(
              text: 'Profile Photos',
              badge: '${state.photos.length}/6',
            ),
            Text(
              '1 required',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        12.verticalSpace,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            if (index < state.photos.length) {
              return Stack(
                clipBehavior: Clip.antiAlias,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      color: theme.colorScheme.surfaceContainerHighest,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://picsum.photos/150?random=1',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => notifier.removePhoto(state.photos[index]),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return GestureDetector(
              onTap: () => notifier.addPhoto('dummy_path'),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: theme.colorScheme.primary,
                      size: 28.r,
                    ),
                    4.verticalSpace,
                    Text(
                      'Add',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        28.verticalSpace,
        _SectionLabel(text: 'Audio Bio', badge: 'Optional'),
        8.verticalSpace,
        Text(
          'A 10–30 second intro played on your profile card.',
          style: theme.textTheme.bodyMedium,
        ),
        14.verticalSpace,
        _AudioBioButton(state: state.audioBioPath),
      ],
    );
  }
}

class _AudioBioButton extends StatelessWidget {
  final String? state;
  const _AudioBioButton({this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRecording = state != null;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: hasRecording
            ? theme.colorScheme.primary.withOpacity(0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasRecording
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasRecording ? Icons.play_arrow_rounded : Icons.mic_rounded,
              color: theme.colorScheme.primary,
              size: 22.r,
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasRecording ? 'Recording saved' : 'Record Introduction',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.verticalSpace,
                Text(
                  hasRecording
                      ? 'Tap to listen or re-record'
                      : '10–30 seconds • Tap to start',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared info note widget
// ─────────────────────────────────────────────
class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: theme.colorScheme.primary),
          10.horizontalSpace,
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
