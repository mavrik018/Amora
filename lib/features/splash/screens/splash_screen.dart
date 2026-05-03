import 'dart:math';
import 'package:amora/features/onboarding/screens/get_started_screen.dart';
import 'package:amora/features/onboarding/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amora/core/constants/colors.dart';
import 'package:amora/core/providers/supabase_provider.dart';
import 'package:amora/features/auth/screens/login_screen.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:amora/features/profile/screens/admin_screen.dart';
import 'package:amora/shared/widgets/bottom_nav_bar.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _heartsCtrl;
  late final AnimationController _rippleCtrl;

  // ── Logo animations ───────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoBlur;

  // ── Text animations ───────────────────────────────────────────────────────
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  // ── Tagline ───────────────────────────────────────────────────────────────
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  // ── Progress / shimmer ────────────────────────────────────────────────────
  late final Animation<double> _progressValue;

  // ── Hearts / ripple ───────────────────────────────────────────────────────
  late final Animation<double> _heartsOpacity;
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;

  bool _navigated = false;
  final List<_HeartParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _buildParticles();
    _initControllers();
    _startSequence();
  }

  void _buildParticles() {
    final rng = Random();
    for (int i = 0; i < 18; i++) {
      _particles.add(
        _HeartParticle(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          size: rng.nextDouble() * 14 + 6,
          speed: rng.nextDouble() * 0.4 + 0.1,
          opacity: rng.nextDouble() * 0.35 + 0.08,
          phase: rng.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  void _initControllers() {
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _rippleScale = Tween<double>(begin: 0.6, end: 1.6).animate(_rippleCtrl);
    _rippleOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(_rippleCtrl);

    _heartsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _heartsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heartsCtrl,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _logoBlur = Tween<double>(
      begin: 8.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn));
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _taglineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _progressCtrl.forward();

    // Wait for minimum splash + auth check
    await Future.delayed(const Duration(milliseconds: 1600));
    _maybeNavigate();
  }

  void _maybeNavigate() {
    if (!mounted || _navigated) return;
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (state) {
        if (state.session != null) {
          _navigateToHome();
        } else {
          _navigated = true;
          _navigate(const GetStartedScreen());
        }
      },
      loading: () {
        ref.listenManual(authStateProvider, (_, next) {
          next.whenData((state) {
            if (_navigated || !mounted) return;
            if (state.session != null) {
              _navigateToHome();
            } else {
              _navigated = true;
              _navigate(const GetStartedScreen());
            }
          });
        });
      },
      error: (_, __) {
        _navigated = true;
        _navigate(const GetStartedScreen());
      },
    );
  }

  void _navigateToHome() async {
    final profile = await ref.read(userProfileProvider.future);
    if (!mounted || _navigated) return;
    _navigated = true;
    final dest = profile?.isAdmin == true
        ? const AdminScreen()
        : const BottomNavBar();
    _navigate(dest);
  }

  void _navigate(Widget dest) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
        transitionDuration: const Duration(milliseconds: 6000),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _taglineCtrl.dispose();
    _progressCtrl.dispose();
    _heartsCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen so navigation fires if auth state arrives after _startSequence
    ref.listen(authStateProvider, (_, next) {
      next.whenData((_) => _maybeNavigate());
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F5), Color(0xFFFFE4EE), Color(0xFFFFC2D9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // ── Floating heart particles ──────────────────────────────────
            AnimatedBuilder(
              animation: _heartsCtrl,
              builder: (_, __) {
                return FadeTransition(
                  opacity: _heartsOpacity,
                  child: _HeartsLayer(
                    particles: _particles,
                    progress: _heartsCtrl.value,
                  ),
                );
              },
            ),

            // ── Soft radial glow behind logo ─────────────────────────────
            Center(
              child: Container(
                width: 260.r,
                height: 260.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Ripple ring ──────────────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _rippleCtrl,
                builder: (_, __) => Transform.scale(
                  scale: _rippleScale.value,
                  child: Opacity(
                    opacity: _rippleOpacity.value,
                    child: Container(
                      width: 160.r,
                      height: 160.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo icon
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: _LogoIcon(),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // App name
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Text(
                        'amora',
                        style: GoogleFonts.notoSerif(
                          fontSize: 52.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'where hearts connect',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary.withOpacity(0.65),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar at bottom ────────────────────────────────────
            Positioned(
              bottom: 60.h,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineOpacity,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _progressCtrl,
                      builder: (_, __) =>
                          _ShimmerProgressBar(value: _progressValue.value),
                    ),
                    SizedBox(height: 16.h),
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'Finding your story…',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: AppColors.primary.withOpacity(0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo icon widget
// ─────────────────────────────────────────────────────────────────────────────
class _LogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110.r,
      height: 110.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.40),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.favorite_rounded, color: Colors.white, size: 54.r),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer progress bar
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerProgressBar extends StatefulWidget {
  final double value;
  const _ShimmerProgressBar({required this.value});

  @override
  State<_ShimmerProgressBar> createState() => _ShimmerProgressBarState();
}

class _ShimmerProgressBarState extends State<_ShimmerProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimCtrl;
  late final Animation<double> _shimAnim;

  @override
  void initState() {
    super.initState();
    _shimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _shimAnim = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 4.h,
          child: AnimatedBuilder(
            animation: _shimAnim,
            builder: (_, __) {
              return Stack(
                children: [
                  // Track
                  Container(color: AppColors.primary.withOpacity(0.15)),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: widget.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            const Color(0xFFFF6B9D),
                            AppColors.primary,
                          ],
                          stops: [
                            (_shimAnim.value - 0.5).clamp(0.0, 1.0),
                            _shimAnim.value.clamp(0.0, 1.0),
                            (_shimAnim.value + 0.5).clamp(0.0, 1.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating heart particles
// ─────────────────────────────────────────────────────────────────────────────
class _HeartParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;
  const _HeartParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

class _HeartsLayer extends StatelessWidget {
  final List<_HeartParticle> particles;
  final double progress;
  const _HeartsLayer({required this.particles, required this.progress});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: particles.map((p) {
        // Each heart drifts upward and oscillates horizontally
        final t = (progress * p.speed + p.phase) % 1.0;
        final dy = 1.0 - t; // 1 → 0 (bottom to top)
        final dx = p.x + 0.04 * sin(t * 4 * pi + p.phase);

        return Positioned(
          left: dx * size.width,
          top: dy * size.height,
          child: Opacity(
            opacity: (p.opacity * (1 - (1 - t) * 0.3)).clamp(0.0, 1.0),
            child: Icon(Icons.favorite, size: p.size, color: AppColors.primary),
          ),
        );
      }).toList(),
    );
  }
}
