import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class SafeSeniorLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double spacing;
  final Color? color;

  const SafeSeniorLogo({
    super.key,
    this.size = 64.0,
    this.showText = true,
    this.spacing = 12.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppTheme.primaryTeal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(logoColor),
        if (showText) ...[
          SizedBox(height: spacing),
          Text(
            'Guardian\nAurora',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: logoColor,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.5,
              height: 1.1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon(Color logoColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: logoColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.shield,
          size: size * 0.55,
          color: Colors.white,
        ),
      ),
    );
  }
}
