import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePromptCards extends StatelessWidget {
  final Map<String, String> prompts;
  const ProfilePromptCards({super.key, required this.prompts});

  static const Map<String, IconData> _promptIcons = {
    'my simple pleasure': Icons.spa_outlined,
    "we'll get along if": Icons.handshake_outlined,
    'i go crazy for': Icons.favorite_border_rounded,
    'my love language': Icons.volunteer_activism_outlined,
    'life goal': Icons.rocket_launch_outlined,
    'perfect day': Icons.wb_sunny_outlined,
    'i believe in': Icons.lightbulb_outline_rounded,
    'conversation starter': Icons.chat_bubble_outline_rounded,
  };

  static const List<List<Color>> _cardGradients = [
    [Color(0xFFF8F0FF), Color(0xFFEDE0FF)],
    [Color(0xFFF0F7FF), Color(0xFFDEEDFF)],
    [Color(0xFFFFF5F0), Color(0xFFFFE8DC)],
    [Color(0xFFF0FFF4), Color(0xFFDCF5E4)],
  ];

  static const List<Color> _accentColors = [
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFFF97316),
    Color(0xFF22C55E),
  ];

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    final entries = prompts.entries.toList();

    return Column(
      children: List.generate(entries.length, (index) {
        final entry = entries[index];
        final gradient = _cardGradients[index % _cardGradients.length];
        final accent = _accentColors[index % _accentColors.length];
        final lowerKey = entry.key.toLowerCase();
        final icon =
            _promptIcons.entries
                .where((e) => lowerKey.contains(e.key))
                .map((e) => e.value)
                .firstOrNull ??
            Icons.auto_awesome_outlined;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, size: 16.sp, color: accent),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                entry.value,
                style: GoogleFonts.notoSerif(fontSize: 14.sp, height: 1.55),
              ),
            ],
          ),
        );
      }),
    );
  }
}
