import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/app_user.dart';
import '../../models/lesson.dart';
import '../../models/puzzle.dart';
import '../../services/database_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/magic_button.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_loading_indicator.dart';
import '../spellbook/spellbook_screen.dart';

/// Screen 7 — Core Puzzle Gameplay Screen (PRD Section 13 & 14)
/// Renders 3 puzzle challenges for the selected lesson with 5 supported puzzle types:
/// 1. multiple_choice
/// 2. sequence
/// 3. symbol_select
/// 4. pattern
/// 5. memory
class PuzzleGameScreen extends StatefulWidget {
  final Lesson lesson;
  final AppUser user;

  const PuzzleGameScreen({
    super.key,
    required this.lesson,
    required this.user,
  });

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late Future<List<Puzzle>> _puzzlesFuture;
  List<Puzzle> _puzzles = [];

  int _currentIndex = 0;
  String? _selectedAnswer;
  String? _feedbackMessage;
  bool _isCorrect = false;
  bool _isCompleted = false;
  bool _isSubmitting = false;

  // Reward and accuracy tracking (PRD Section 20)
  int _mistakeCount = 0;
  LessonRewardResult? _rewardResult;

  // Memory puzzle state: false = study/reveal phase, true = recall phase
  bool _memoryRecallPhase = false;

  @override
  void initState() {
    super.initState();
    _puzzlesFuture = _loadPuzzles();
  }

  Future<List<Puzzle>> _loadPuzzles() async {
    final puzzles =
        await DatabaseService.instance.getPuzzlesForLesson(widget.lesson.id);
    _puzzles = puzzles;
    return puzzles;
  }

  void _onOptionSelected(String option) {
    if (_isCorrect || _isSubmitting) return;
    setState(() {
      _selectedAnswer = option;
      _feedbackMessage = null;
    });
  }

  Future<void> _castSpell() async {
    if (_selectedAnswer == null || _puzzles.isEmpty || _isSubmitting) return;

    final currentPuzzle = _puzzles[_currentIndex];
    final bool answerMatches = _selectedAnswer!.trim().toLowerCase() ==
        currentPuzzle.correctAnswer.trim().toLowerCase();

    if (answerMatches) {
      setState(() {
        _isCorrect = true;
        _feedbackMessage = 'Spell cast successfully!';
      });

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      if (_currentIndex < _puzzles.length - 1) {
        // Next puzzle challenge
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _feedbackMessage = null;
          _isCorrect = false;
          _memoryRecallPhase = false;
        });
      } else {
        // All 3 puzzles solved! Complete the lesson and calculate rewards
        setState(() {
          _isSubmitting = true;
        });

        final reward = await ProgressService.instance.completeLesson(
          userId: widget.user.id,
          lesson: widget.lesson,
          mistakeCount: _mistakeCount,
        );

        if (!mounted) return;

        setState(() {
          _rewardResult = reward;
          _isCompleted = true;
          _isSubmitting = false;
        });
      }
    } else {
      // Incorrect answer: increment mistake count, friendly retry message
      setState(() {
        _mistakeCount++;
        _isCorrect = false;
        _feedbackMessage = 'The spell fizzled.\nTry again, apprentice.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 760,
        child: FutureBuilder<List<Puzzle>>(
          future: _puzzlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: MagicLoadingIndicator(
                  message: 'Summoning lesson challenges...',
                ),
              );
            }

            if (_puzzles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No puzzle challenges found for this lesson.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('RETURN TO ACADEMY',
                          style: AppTypography.buttonSecondary),
                    ),
                  ],
                ),
              );
            }

            if (_isCompleted) {
              return _buildLessonSuccessView();
            }

            final currentPuzzle = _puzzles[_currentIndex];
            final totalPuzzles = _puzzles.length;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Navigation & Exit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.goldLight),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Leave Lesson',
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.goldPrimary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.lesson.spellIcon,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'LESSON 0${widget.lesson.lessonOrder}',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.textGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // balance spacing
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress Header: e.g. "CHALLENGE 1 / 3"
                  _buildProgressHeader(_currentIndex + 1, totalPuzzles),

                  const SizedBox(height: 20),

                  // Puzzle Area
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dynamic Puzzle View based on puzzleType
                          _buildPuzzleContent(currentPuzzle),

                          const SizedBox(height: 20),

                          // Feedback message (Retry / Success)
                          if (_feedbackMessage != null)
                            _buildFeedbackBanner(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Action Bar
                  MagicButton(
                    label: _isCorrect
                        ? 'SOLVED'
                        : (_isSubmitting ? 'MASTERING SPELL...' : 'CAST SPELL'),
                    icon: _isCorrect ? Icons.check_circle_rounded : Icons.auto_awesome,
                    isLoading: _isSubmitting,
                    onPressed: (_selectedAnswer != null && !_isCorrect)
                        ? _castSpell
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Progress Indicator with segmented bars & text: e.g. 1/3, 2/3, 3/3
  Widget _buildProgressHeader(int current, int total) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'CHALLENGE $current / $total',
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 13,
                    color: AppColors.textGold,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.lesson.title.toUpperCase(),
                  style: AppTypography.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(total, (index) {
              final isCompletedStep = index < current - 1;
              final isCurrentStep = index == current - 1;

              Color stepColor;
              if (isCompletedStep) {
                stepColor = AppColors.success;
              } else if (isCurrentStep) {
                stepColor = AppColors.goldPrimary;
              } else {
                stepColor = AppColors.surfaceGlassBorder;
              }

              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(
                    right: index < total - 1 ? 6.0 : 0.0,
                  ),
                  decoration: BoxDecoration(
                    color: stepColor,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isCurrentStep
                        ? [
                            BoxShadow(
                              color: AppColors.goldGlow.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Renders specific puzzle UI depending on puzzleType
  Widget _buildPuzzleContent(Puzzle puzzle) {
    switch (puzzle.puzzleType) {
      case 'sequence':
        return _buildSequencePuzzle(puzzle);
      case 'symbol_select':
        return _buildSymbolSelectPuzzle(puzzle);
      case 'pattern':
        return _buildPatternPuzzle(puzzle);
      case 'memory':
        return _buildMemoryPuzzle(puzzle);
      case 'multiple_choice':
      default:
        return _buildMultipleChoicePuzzle(puzzle);
    }
  }

  /// 1. Multiple Choice Puzzle View
  Widget _buildMultipleChoicePuzzle(Puzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Box
        GlassPanel(
          borderColor: AppColors.violetGlow.withValues(alpha: 0.3),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.help_outline_rounded,
                  color: AppColors.goldLight, size: 28),
              const SizedBox(height: 10),
              Text(
                puzzle.question,
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 17,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4 Selectable Option Tiles
        ...puzzle.options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionTile(option),
            )),
      ],
    );
  }

  /// 2. Sequence Puzzle View
  Widget _buildSequencePuzzle(Puzzle puzzle) {
    // If the question contains sequence arrows '→', display visual sequence chain
    final hasArrow = puzzle.question.contains('→');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          borderColor: AppColors.goldLight.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'COMPLETE THE SEQUENCE',
                style: AppTypography.label.copyWith(
                  color: AppColors.textGold,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (hasArrow)
                _buildSequenceChain(puzzle.question)
              else
                Text(
                  puzzle.question,
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Select the next sequence element:',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Sequence Options Grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: puzzle.options.map((option) {
            final isSelected = _selectedAnswer == option;
            return SizedBox(
              width: 140,
              child: _buildOptionTile(option, isSelected: isSelected),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Visual horizontal chain of sequence steps
  Widget _buildSequenceChain(String rawQuestion) {
    final parts = rawQuestion.split(':').last.split('→');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: parts.asMap().entries.map((entry) {
          final text = entry.value.trim();
          final isLast = entry.key == parts.length - 1;
          final isTargetSlot = text.contains('?');

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isTargetSlot
                      ? AppColors.goldPrimary.withValues(alpha: 0.2)
                      : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isTargetSlot
                        ? AppColors.goldPrimary
                        : AppColors.surfaceGlassBorder,
                    width: isTargetSlot ? 1.5 : 1.0,
                  ),
                  boxShadow: isTargetSlot
                      ? [
                          BoxShadow(
                            color: AppColors.goldGlow.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  isTargetSlot
                      ? (_selectedAnswer != null ? _selectedAnswer! : '?')
                      : text,
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 16,
                    color: isTargetSlot
                        ? AppColors.textGold
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.goldLight.withValues(alpha: 0.6),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 3. Symbol Selection Puzzle View
  Widget _buildSymbolSelectPuzzle(Puzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(20),
          borderColor: AppColors.arcaneRune.withValues(alpha: 0.4),
          child: Column(
            children: [
              Text(
                'ARCANE SYMBOL CLUE',
                style: AppTypography.label.copyWith(
                  color: AppColors.arcaneRune,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                puzzle.question,
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Grid of Large Rune/Symbol Tiles
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.5,
          ),
          itemCount: puzzle.options.length,
          itemBuilder: (context, index) {
            final option = puzzle.options[index];
            return _buildOptionTile(option, isLargeSymbol: true);
          },
        ),
      ],
    );
  }

  /// 4. Pattern Matching Puzzle View
  Widget _buildPatternPuzzle(Puzzle puzzle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(20),
          borderColor: AppColors.mysticLogic.withValues(alpha: 0.4),
          child: Column(
            children: [
              Text(
                'PATTERN RECOGNITION',
                style: AppTypography.label.copyWith(
                  color: AppColors.mysticLogic,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                puzzle.question,
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Choose the matching symbol:',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: puzzle.options.map((option) {
            return SizedBox(
              width: 130,
              child: _buildOptionTile(option, isLargeSymbol: true),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 5. Memory Puzzle View (Reveal Phase -> Recall Phase)
  Widget _buildMemoryPuzzle(Puzzle puzzle) {
    if (!_memoryRecallPhase) {
      // Phase 1: Reveal & Study Phase
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassPanel(
            padding: const EdgeInsets.all(24),
            borderColor: AppColors.violetGlow.withValues(alpha: 0.5),
            glowColor: AppColors.violetGlow.withValues(alpha: 0.2),
            child: Column(
              children: [
                const Icon(Icons.remove_red_eye_outlined,
                    color: AppColors.violetGlow, size: 36),
                const SizedBox(height: 12),
                Text(
                  'ARCANE VISION',
                  style: AppTypography.label.copyWith(
                    color: AppColors.textGold,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  puzzle.question,
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Commit the vision to memory before concealing the symbols.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                MagicButton(
                  label: 'I HAVE MEMORIZED THE VISION',
                  icon: Icons.visibility_off_rounded,
                  onPressed: () {
                    setState(() {
                      _memoryRecallPhase = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Phase 2: Concealed / Recall Phase
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(20),
          borderColor: AppColors.goldLight.withValues(alpha: 0.4),
          child: Column(
            children: [
              Text(
                'VISION CONCEALED',
                style: AppTypography.label.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              // Concealed glyph markers
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✦   ✦   ✦   ✦',
                      style: TextStyle(
                          fontSize: 22, color: AppColors.violetGlow)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Which arcane symbol was part of the celestial vision?',
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ...puzzle.options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionTile(option),
            )),
      ],
    );
  }

  /// Reusable Option Selection Tile
  Widget _buildOptionTile(String option,
      {bool? isSelected, bool isLargeSymbol = false}) {
    final selected = isSelected ?? (_selectedAnswer == option);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onOptionSelected(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isLargeSymbol ? 18 : 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.goldPrimary.withValues(alpha: 0.15)
                : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.goldPrimary
                  : AppColors.surfaceGlassBorder,
              width: selected ? 1.5 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.goldGlow.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: isLargeSymbol
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              if (!isLargeSymbol) ...[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.goldPrimary
                          : AppColors.surfaceGlassBorder,
                      width: 1.5,
                    ),
                    color: selected
                        ? AppColors.goldPrimary
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Center(
                          child: Icon(Icons.check,
                              size: 14, color: AppColors.background),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
              ],
              Flexible(
                child: Text(
                  option,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: isLargeSymbol ? 20 : 15,
                    color: selected
                        ? AppColors.textGold
                        : AppColors.textPrimary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: isLargeSymbol ? TextAlign.center : TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Friendly Retry / Success Banner (PRD Section 14)
  Widget _buildFeedbackBanner() {
    final bool isSuccess = _isCorrect;

    return GlassPanel(
      borderColor: isSuccess
          ? AppColors.success.withValues(alpha: 0.8)
          : AppColors.error.withValues(alpha: 0.6),
      glowColor: isSuccess
          ? AppColors.success.withValues(alpha: 0.2)
          : AppColors.error.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.auto_awesome : Icons.refresh_rounded,
            color: isSuccess ? AppColors.success : AppColors.error,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _feedbackMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: isSuccess
                    ? AppColors.success
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Screen 8 — Lesson Success / Spell Mastered View (PRD Section 15)
  /// Screen 8 — Lesson Success / Spell Mastered View (PRD Section 15 & 20)
  Widget _buildLessonSuccessView() {
    final reward = _rewardResult;
    final bool isRevisit = reward != null && !reward.isFirstCompletion;
    final bool isFlawless =
        reward != null && reward.isFlawless && reward.isFirstCompletion;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            borderColor: AppColors.goldLight,
            glowColor: AppColors.goldGlow.withValues(alpha: 0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                isRevisit ? '✦ LESSON REVISITED ✦' : '✨ SPELL MASTERED ✨',
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.textGold,
                  fontSize: 20,
                  letterSpacing: 2.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // Spell Icon in Glowing Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardSurface,
                  border: Border.all(color: AppColors.goldLight, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldGlow.withValues(alpha: 0.5),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.lesson.spellIcon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                widget.lesson.spellName.toUpperCase(),
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                isRevisit
                    ? 'You have reenchanted the ${widget.lesson.title} spell.'
                    : 'You have awakened the ${widget.lesson.title} spell.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Rewards & XP Breakdown
              if (isRevisit)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Practice Session • Already Mastered',
                    style: AppTypography.label.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    // Base XP Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '+100 XP',
                        style: AppTypography.label.copyWith(
                          color: AppColors.goldLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Flawless Mastery Bonus Chip (+25 XP)
                    if (isFlawless)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '+25 XP FLAWLESS BONUS',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Total XP Summary
                Text(
                  'Total Earned: +${reward?.totalXpEarned ?? 100} XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Level Up Banner
                if (reward != null && reward.leveledUp) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.violetGlow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.violetGlow.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      '🌟 LEVEL UP! ADVANCED TO LEVEL ${reward.newLevel} 🌟',
                      style: AppTypography.label.copyWith(
                        color: AppColors.violetGlow,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Action Buttons
              MagicButton(
                label: 'OPEN SPELLBOOK',
                icon: Icons.menu_book_rounded,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SpellbookScreen(user: widget.user),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'RETURN TO ACADEMY',
                  style: AppTypography.buttonSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
