import 'package:flutter/material.dart';

class CtaButton extends StatelessWidget {
  const CtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
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
