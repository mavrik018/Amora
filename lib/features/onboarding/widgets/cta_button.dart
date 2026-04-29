import 'package:amora/features/auth/screens/sign_up_screen.dart';
import 'package:amora/shared/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class CtaButton extends StatelessWidget {
  const CtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const BottomNavBar()));
      },
      style: Theme.of(context).elevatedButtonTheme.style,
      child: Text(
        "Get Started",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
