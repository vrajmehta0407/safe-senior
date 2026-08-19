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
    this.size = 80.0,
    this.showText = true,
    this.spacing = 12.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppTheme.primaryTeal;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoImage(),
        if (showText) ...[
          SizedBox(height: spacing),
          Text(
            'SafeSenior',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.38,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SENIOR SAFETY & SCAM NEUTRALIZATION',
            textAlign: TextAlign.center,
            style: GoogleFonts.atkinsonHyperlegible(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.15,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoImage() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/images/app_logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            color: AppTheme.primaryTeal,
            child: Icon(Icons.shield_rounded, size: size * 0.55, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
