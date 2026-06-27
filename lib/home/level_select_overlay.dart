import 'dart:math';
import 'package:aetherius/home/space_shooter_game.dart';
import 'package:aetherius/home/sound_service.dart';
import 'package:flutter/material.dart';

class LevelSelectOverlay extends StatefulWidget {
  final SpaceShooterGame game;
  const LevelSelectOverlay({super.key, required this.game});

  @override
  State<LevelSelectOverlay> createState() => _LevelSelectOverlayState();
}

class _LevelSelectOverlayState extends State<LevelSelectOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highest = widget.game.highestLevelUnlocked;
    // Always show at least 9 cards (3 rows) with a few locked ahead
    final totalShown = max(highest + 3, 9);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04000F), Color(0xFF0B0025), Color(0xFF04000F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        widget.game.overlays.remove('LevelSelect');
                        widget.game.overlays.add('MainMenu');
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'SELECT LEVEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(color: Color(0xFFAA44FF), blurRadius: 14),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        SoundService.enabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: () async {
                        await SoundService.toggleSound();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              // ── Purple divider ─────────────────────────────────────────
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFAA44FF).withAlpha(200),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Best score bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🏆  Best: ${widget.game.highScore}',
                      style: const TextStyle(
                        color: Color(0xFFFFDD44),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '🔓 Unlocked: ${widget.game.highestLevelUnlocked}',
                      style: const TextStyle(
                        color: Color(0xFF88FFCC),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Level grid ────────────────────────────────────────────
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: totalShown,
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final isUnlocked = level <= highest;
                    return _LevelCard(
                      level: level,
                      isUnlocked: isUnlocked,
                      onTap: isUnlocked
                          ? () => widget.game.startGame(startLevel: level)
                          : null,
                    );
                  },
                ),
              ),

              // ── Legend ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 14, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(const Color(0xFF5544FF), 'Unlocked'),
                    const SizedBox(width: 20),
                    _legendDot(Colors.white24, 'Locked — complete prev. level'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Individual Level Card ──────────────────────────────────────────────────

class _LevelCard extends StatefulWidget {
  final int level;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, required this.isUnlocked, this.onTap});

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _pulseAnim = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    if (widget.isUnlocked) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _themeColor {
    if (widget.level <= 3) return const Color(0xFF2244FF);
    if (widget.level <= 6) return const Color(0xFF7722EE);
    if (widget.level <= 10) return const Color(0xFFCC2299);
    if (widget.level <= 15) return const Color(0xFFFF4400);
    return const Color(0xFFFF0066);
  }

  String get _tierLabel {
    if (widget.level <= 3) return 'ROOKIE';
    if (widget.level <= 6) return 'WARRIOR';
    if (widget.level <= 10) return 'ELITE';
    if (widget.level <= 15) return 'VETERAN';
    return 'LEGEND';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUnlocked) return _lockedCard();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _themeColor.withAlpha(210),
                  _themeColor.withAlpha(110),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _themeColor.withAlpha(
                  (100 + (155 * _pulseAnim.value)).toInt(),
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _themeColor.withAlpha((80 * _pulseAnim.value).toInt()),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _tierLabel,
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(28),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: const Text(
                'PLAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockedCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(18), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            'LVL ${widget.level}',
            style: TextStyle(
              color: Colors.white.withAlpha(55),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LOCKED',
            style: TextStyle(
              color: Colors.white.withAlpha(30),
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
