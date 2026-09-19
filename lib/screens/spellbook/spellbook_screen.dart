import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/app_user.dart';
import '../../models/spell.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/magic_background.dart';
import '../../widgets/magic_loading_indicator.dart';
import '../../widgets/spell_card.dart';
import 'spell_detail_screen.dart';

/// Screen 9 — Spellbook Screen (PRD Section 16)
/// Shows all 9 academy spells, dynamically retrieving unlocked states from Supabase user_spells.
/// - Unlocked spells can be inspected via SpellDetailScreen.
/// - Locked spells show the curriculum lesson required to unlock them.
class SpellbookScreen extends StatefulWidget {
  final AppUser? user;

  const SpellbookScreen({super.key, this.user});

  @override
  State<SpellbookScreen> createState() => _SpellbookScreenState();
}

class _SpellbookScreenState extends State<SpellbookScreen> {
  late Future<List<Spell>> _spellsFuture;

  @override
  void initState() {
    super.initState();
    _loadSpells();
  }

  void _loadSpells() {
    final effectiveUserId =
        widget.user?.id ?? AuthService.instance.currentUser?.id ?? '';
    _spellsFuture =
        ProgressService.instance.getSpellbookForUser(effectiveUserId);
  }

  void _onSpellTapped(Spell spell) {
    if (spell.isUnlocked) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              SpellDetailScreen(spell: spell),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      _showLockedRequirementDialog(spell);
    }
  }

  void _showLockedRequirementDialog(Spell spell) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassPanel(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(26),
              borderColor: AppColors.locked,
              glowColor: AppColors.violetGlow.withValues(alpha: 0.15),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardSurface,
                        border: Border.all(
                          color: AppColors.lockedText.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_rounded,
                          color: AppColors.lockedText,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SPELL SEALED',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 18,
                        color: AppColors.lockedText,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      spell.name.toUpperCase(),
                      style: AppTypography.displayMedium.copyWith(
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'To unlock this spell in your grimoire, you must complete the required curriculum challenge:',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        spell.unlockRequirement ??
                            'Complete ${spell.schoolName} lesson',
                        style: AppTypography.label.copyWith(
                          color: AppColors.textGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        'RETURN',
                        style: AppTypography.buttonSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        maxContentWidth: 720,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.goldLight),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SPELLBOOK ARCHIVES',
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 20,
                        color: AppColors.textGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<Spell>>(
                  future: _spellsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: MagicLoadingIndicator(
                          message: 'Opening your spellbook...',
                        ),
                      );
                    }

                    final spells = snapshot.data ?? [];
                    if (spells.isEmpty) {
                      return Center(
                        child: GlassPanel(
                          child: Text(
                            'Your spellbook is empty. Complete lessons to unlock spells.',
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final unlockedCount =
                        spells.where((s) => s.isUnlocked).length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress bar banner
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassPanel(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'DISCOVERED SPELLS',
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.textGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$unlockedCount / ${spells.length} Mastered',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: unlockedCount > 0
                                        ? AppColors.cyanMagic
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Spells list
                        Expanded(
                          child: ListView.separated(
                            itemCount: spells.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final spell = spells[index];
                              return SpellCard(
                                spellName: spell.name,
                                schoolName: spell.schoolName,
                                iconEmoji: spell.icon,
                                masteryLevel: spell.masteryLevel,
                                isUnlocked: spell.isUnlocked,
                                unlockRequirement: spell.unlockRequirement,
                                onTap: () => _onSpellTapped(spell),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

