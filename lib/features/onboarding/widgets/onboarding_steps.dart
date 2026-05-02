import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/widgets/text_field.dart';
import '../../../core/widgets/date_picker_field.dart';
import '../../../core/constants/enums.dart';
import '../../../shared/widgets/audio_bio_editor.dart';

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
        _SectionLabel(text: 'My Gender'),
        12.verticalSpace,
        _OptionSelector(
          selected: state.gender,
          onSelected: notifier.updateGender,
          options: const ['Man', 'Woman', 'Other'],
        ),
        16.verticalSpace,
        _SectionLabel(text: 'Interested In'),
        12.verticalSpace,
        _OptionSelector(
          selected: state.interestedIn,
          onSelected: notifier.updateInterestedIn,
          options: const ['Men', 'Women', 'Everyone'],
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

class _OptionSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final List<String> options;

  const _OptionSelector({
    required this.selected,
    required this.onSelected,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: options.map((option) {
        final isSelected = selected == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              margin: EdgeInsets.only(
                right: option != options.last ? 8.w : 0,
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
                option,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
                      image: DecorationImage(
                        image: FileImage(File(state.photos[index])),
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
                        decoration: const BoxDecoration(
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
              onTap: () => _showImageSourceActionSheet(context, notifier),
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
        AudioBioEditor(
          initialLocalPath: state.audioBioPath,
          onAudioChanged: (path) => notifier.updateAudioBio(path),
        ),
      ],
    );
  }

  void _showImageSourceActionSheet(
    BuildContext context,
    OnboardingNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, notifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, notifier);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    OnboardingNotifier notifier,
  ) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      notifier.addPhoto(image.path);
    }
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
