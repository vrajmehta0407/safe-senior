import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'safety_quiz_hub_screen.dart';
import 'quiz_results_screen.dart';

class SafetyQuizScreen extends StatefulWidget {
  final QuizTopic topic;

  const SafetyQuizScreen({super.key, required this.topic});

  @override
  State<SafetyQuizScreen> createState() => _SafetyQuizScreenState();
}

class _SafetyQuizScreenState extends State<SafetyQuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _correctScore = 0;

  void _chooseOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (index == widget.topic.questions[_currentQuestionIndex].correctIndex) {
        _correctScore++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < widget.topic.questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _answered = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultsScreen(
            topic: widget.topic,
            totalQuestions: widget.topic.questions.length,
            correctCount: _correctScore,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.topic.questions[_currentQuestionIndex];
    final total = widget.topic.questions.length;
    final progress = (_currentQuestionIndex + 1) / total;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Question ${_currentQuestionIndex + 1} of $total',
                          style: GoogleFonts.atkinsonHyperlegible(
                            fontSize: 13,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: $_correctScore',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Step Progress Indicator ──
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE3E2E2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Scenario Context Card ──
                    Text(
                      'Scenario Case:',
                      style: GoogleFonts.atkinsonHyperlegible(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTeal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question.scenario,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Simulated Incoming Message / Call Preview (if applicable) ──
                    if (question.messageContent != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBDC9C8), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFE7356),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.sms, color: Colors.white, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  question.senderName ?? 'UNKNOWN SENDER',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFAA361F),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              question.messageContent!,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 16,
                                color: const Color(0xFF1B1C1C),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Text(
                      'What is the safest action to take?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Multiple Choice Options ──
                    ...List.generate(question.options.length, (idx) {
                      final optionText = question.options[idx];
                      final isSelected = _selectedOptionIndex == idx;
                      final isCorrect = idx == question.correctIndex;

                      Color borderClr = const Color(0xFFE3E2E2);
                      Color bgClr = Colors.white;
                      Color textClr = AppTheme.textDark;
                      Widget? badgeIcon;

                      if (_answered) {
                        if (isCorrect) {
                          borderClr = const Color(0xFF006565);
                          bgClr = const Color(0xFFE0F2F2);
                          textClr = const Color(0xFF004F4F);
                          badgeIcon = const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 22);
                        } else if (isSelected) {
                          borderClr = const Color(0xFFAA361F);
                          bgClr = const Color(0xFFFFDAD6);
                          textClr = const Color(0xFF6D0F00);
                          badgeIcon = const Icon(Icons.cancel, color: Color(0xFFAA361F), size: 22);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _chooseOption(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                              color: bgClr,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: borderClr, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected && !_answered
                                        ? AppTheme.primaryTeal
                                        : const Color(0xFFF5F3F3),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: borderClr),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + idx), // A, B, C, D
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected && !_answered
                                            ? Colors.white
                                            : AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    optionText,
                                    style: GoogleFonts.atkinsonHyperlegible(
                                      fontSize: 16,
                                      fontWeight: isSelected || (_answered && isCorrect)
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: textClr,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                if (badgeIcon != null) badgeIcon,
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // ── Explanation Feedback Card ──
                    if (_answered) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _selectedOptionIndex == question.correctIndex
                              ? const Color(0xFFE0F2F2)
                              : const Color(0xFFFFDAD6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedOptionIndex == question.correctIndex
                                ? AppTheme.primaryTeal
                                : const Color(0xFFAA361F),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedOptionIndex == question.correctIndex
                                      ? Icons.verified
                                      : Icons.lightbulb_outline,
                                  color: _selectedOptionIndex == question.correctIndex
                                      ? AppTheme.primaryTeal
                                      : const Color(0xFFAA361F),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedOptionIndex == question.correctIndex
                                      ? 'Correct! Outstanding Reflexes!'
                                      : 'Important Safety Insight',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedOptionIndex == question.correctIndex
                                        ? AppTheme.primaryTeal
                                        : const Color(0xFFAA361F),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              question.explanation,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 15.5,
                                color: const Color(0xFF1B1C1C),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.safetyRule,
                              style: GoogleFonts.atkinsonHyperlegible(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: _selectedOptionIndex == question.correctIndex
                                    ? AppTheme.primaryTeal
                                    : const Color(0xFFAA361F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Next Question Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentQuestionIndex + 1 < total ? 'Next Question' : 'View Results & XP',
                                style: GoogleFonts.atkinsonHyperlegible(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
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
