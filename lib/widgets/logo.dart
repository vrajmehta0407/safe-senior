import 'package:flutter/material.dart';
import '../theme.dart';

class SafeSeniorLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double spacing;

  const SafeSeniorLogo({
    super.key,
    this.size = 64.0,
    this.showText = true,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        if (showText) ...[
          SizedBox(width: spacing),
          Text(
            'Safe Senior',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryDarkBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.6,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shield,
            size: size,
            color: AppTheme.primaryLightBlue.withOpacity(0.9), // Base shield color
          ),
          Icon(
            Icons.favorite,
            size: size * 0.45,
            color: AppTheme.backgroundColor, // Heart color
          ),
        ],
      ),
    );
  }
}
