import 'package:flutter/material.dart';

class IconBox extends StatelessWidget {
  const IconBox({
    required this.icon,
    super.key,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.0,
      height: 48.0,
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.75),
        size: 24.0,
      ),
    );
  }
}
