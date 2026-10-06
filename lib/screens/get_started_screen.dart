import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'register_step1_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // TopAppBar — centered brand title only (Stitch transactional header)
            Container(
              height: 64,
              alignment: Alignment.center,
              child: Text(
                'SafeSenior',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    // Heading
                    Text(
                      'Get Started',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B1C1C),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to stay connected and safe with your loved ones.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 18,
                        color: const Color(0xFF3E4949),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Card: Email (Stitch secondary-container terracotta)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterStep1Screen(isEmail: true)),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE3E2E2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Icon circle (Stitch secondary-container terracotta #FE7356)
                            Container(
                              width: 84,
                              height: 84,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFE7356),
                              ),
                              child: const Center(
                                child: Icon(Icons.mail, color: Colors.white, size: 42),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Continue with Email',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B1C1C),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign up securely with your email address',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 14,
                                color: const Color(0xFF717171),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Already have account
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'I already have an account ',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 16,
                            color: const Color(0xFF3E4949),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            'Log In',
                            style: GoogleFonts.atkinsonHyperlegible(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
