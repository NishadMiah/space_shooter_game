import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:aetherius/home/bullet.dart';
import 'package:aetherius/home/enemy.dart';
import 'package:aetherius/home/high_score_service.dart';
import 'package:aetherius/home/power_up.dart';
import 'package:flutter/material.dart';

class SpaceShooterGame extends FlameGame
    with PanDetector, TapCallbacks, HasCollisionDetection {
  // ─── Player ───────────────────────────────────────────────────────────────
  late SpriteComponent player;

  // ─── Score & Level ────────────────────────────────────────────────────────
  int score = 0;
  int highScore = 0;
  int currentLevel = 1;
  int highestLevelUnlocked = 1;
  int _selectedLevel = 1; // level chosen from level select
  int enemiesKilled = 0;
  int _enemiesForNextLevel = 5;

  // ─── Lives ────────────────────────────────────────────────────────────────
  int lives = 3;
  static const int maxLives = 3;

  // ─── Power-ups ────────────────────────────────────────────────────────────
  bool isShielded = false;
  bool isSpeedBoost = false;
  double _shieldTimer = 0;
  double _speedTimer = 0;

  // ─── Intro ────────────────────────────────────────────────────────────────
  bool isIntro = true;
  int introEnemiesLeft = 3;

  // ─── Bullet System ────────────────────────────────────────────────────────
  double _bulletTimer = 0;

  double get _bulletPeriod => isSpeedBoost ? 0.08 : 0.2;

  /// Bullets fired per salvo, based on current level.
  /// LVL 1-2 → 1, LVL 3-4 → 2, LVL 5+ → 3
  int get bulletCount {
    if (currentLevel >= 5) return 3;
    if (currentLevel >= 3) return 2;
    return 1;
  }

  // ─── Spawner ──────────────────────────────────────────────────────────────
  SpawnComponent? enemySpawner;

  // ─── HUD ──────────────────────────────────────────────────────────────────
  late TextComponent scoreText;
  late TextComponent livesText;
  late TextComponent levelText;
  late TextComponent highScoreText;
  late TextComponent bulletIndicator;

  // ──────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = 'assets/icons/';

    highScore = await HighScoreService.getHighScore();
    highestLevelUnlocked = await HighScoreService.getHighestLevel();

    // Player
    player = SpriteComponent(
      sprite: await loadSprite('player.png'),
      size: Vector2(50, 50),
    )..add(RectangleHitbox());
    player.position = Vector2(size.x / 2, size.y - 100);
    add(player);

    // HUD — Score (top-left)
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(scoreText);

    // HUD — Best score (top-left, second row)
    highScoreText = TextComponent(
      text: 'Best: $highScore',
      position: Vector2(20, 68),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFDD44),
          fontSize: 16,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(highScoreText);

    // HUD — Level (top-center)
    levelText = TextComponent(
      text: 'LVL 1',
      position: Vector2(size.x / 2, 40),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFAA88FF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(levelText);

    // HUD — Lives (top-right)
    livesText = TextComponent(
      text: '❤️ ❤️ ❤️',
      position: Vector2(size.x - 16, 40),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20)),
    );
    add(livesText);

    // HUD — Bullet count (top-right, second row)
    bulletIndicator = TextComponent(
      text: '• ×1',
      position: Vector2(size.x - 16, 68),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF88FFCC),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
    add(bulletIndicator);

    // Intro enemies
    add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.25, 80));
    add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.50, 100));
    add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.75, 120));
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HUD helpers
  // ──────────────────────────────────────────────────────────────────────────
  void _updateLivesHUD() {
    final hearts = List.generate(lives, (_) => '❤️').join(' ');
    final empty = List.generate(maxLives - lives, (_) => '🖤').join(' ');
    livesText.text = '$hearts$empty';
  }

  void _updateBulletHUD() {
    bulletIndicator.text = '• ×$bulletCount';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Score
  // ──────────────────────────────────────────────────────────────────────────
  void increaseScore(int amount) {
    score += amount;
    scoreText.text = 'Score: $score';
    if (score > highScore) {
      highScore = score;
      highScoreText.text = 'Best: $highScore';
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Enemy killed / Level-up
  // ──────────────────────────────────────────────────────────────────────────
  void onEnemyKilled() {
    enemiesKilled++;
    if (enemiesKilled >= _enemiesForNextLevel) {
      _enemiesForNextLevel += 5;
      currentLevel++;
      levelText.text = 'LVL $currentLevel';
      _updateBulletHUD();
      _adjustDifficulty();

      // Persist highest level
      if (currentLevel > highestLevelUnlocked) {
        highestLevelUnlocked = currentLevel;
        HighScoreService.saveHighestLevel(currentLevel);
      }

      overlays.add('LevelUp');
    }
  }

  void _adjustDifficulty() {
    final period = max(0.35, 1.0 - (currentLevel - 1) * 0.08);
    enemySpawner?.timer.limit = period;
  }

  Enemy _spawnEnemy() {
    final rand = Random();
    final roll = rand.nextDouble();
    final fastChance = min(0.05 * (currentLevel - 1), 0.4);
    final tankChance = min(0.03 * (currentLevel - 1), 0.25);
    EnemyType type;
    if (roll < tankChance) {
      type = EnemyType.tank;
    } else if (roll < tankChance + fastChance) {
      type = EnemyType.fast;
    } else {
      type = EnemyType.basic;
    }
    return Enemy(type: type);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Lives
  // ──────────────────────────────────────────────────────────────────────────
  void loseLife() {
    if (isShielded) return;
    lives = (lives - 1).clamp(0, maxLives);
    _updateLivesHUD();
    if (lives <= 0) gameOver();
  }

  void gainLife() {
    if (lives < maxLives) {
      lives++;
      _updateLivesHUD();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Power-ups
  // ──────────────────────────────────────────────────────────────────────────
  void collectPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.heart:
        gainLife();
      case PowerUpType.shield:
        _activateShield();
      case PowerUpType.speed:
        _activateSpeed();
    }
  }

  void _activateShield() {
    isShielded = true;
    _shieldTimer = 3.0;
    // Remove old shield visual first
    player.children.whereType<CircleComponent>().forEach((c) => c.removeFromParent());
    final ring = CircleComponent(
      radius: 35,
      paint: Paint()
        ..color = const Color(0xFF44AAFF).withAlpha(70)
        ..style = PaintingStyle.fill,
    )..add(
        CircleComponent(
          radius: 35,
          paint: Paint()
            ..color = const Color(0xFF44AAFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );
    ring.anchor = Anchor.center;
    ring.position = Vector2(player.size.x / 2, player.size.y / 2);
    player.add(ring);
  }

  void _activateSpeed() {
    isSpeedBoost = true;
    _speedTimer = 5.0;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Bullet firing
  // ──────────────────────────────────────────────────────────────────────────
  void _fireBullets() {
    final px = player.position.x;
    final py = player.position.y;
    // During intro always fire single bullet
    final count = isIntro ? 1 : bulletCount;

    switch (count) {
      case 1:
        add(Bullet()..position = Vector2(px + 20, py));
      case 2:
        add(Bullet()..position = Vector2(px + 8, py));
        add(Bullet()..position = Vector2(px + 32, py));
      default:
        add(Bullet()..position = Vector2(px + 20, py));
        add(Bullet()..position = Vector2(px + 6, py));
        add(Bullet()..position = Vector2(px + 34, py));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Intro
  // ──────────────────────────────────────────────────────────────────────────
  void decrementIntroEnemies() {
    introEnemiesLeft--;
    if (introEnemiesLeft <= 0) _onIntroComplete();
  }

  void _onIntroComplete() {
    pauseEngine();
    overlays.remove('StoryIntro');
    overlays.add('MainMenu');
    isIntro = false;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Game Flow
  // ──────────────────────────────────────────────────────────────────────────

  /// Starts the game at [startLevel]. Called from level select.
  void startGame({int startLevel = 1}) {
    _selectedLevel = startLevel;
    score = 0;
    lives = 3;
    currentLevel = startLevel;
    enemiesKilled = (startLevel - 1) * 5; // normalise kill count for level
    _enemiesForNextLevel = startLevel * 5;
    isShielded = false;
    isSpeedBoost = false;
    _bulletTimer = 0;

    scoreText.text = 'Score: 0';
    levelText.text = 'LVL $currentLevel';
    highScoreText.text = 'Best: $highScore';
    _updateLivesHUD();
    _updateBulletHUD();

    player.position = Vector2(size.x / 2, size.y - 100);
    player.children.whereType<CircleComponent>().forEach((c) => c.removeFromParent());

    // Clear stale game objects
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());

    // Enemy spawner
    final period = max(0.35, 1.0 - (startLevel - 1) * 0.08);
    if (enemySpawner == null) {
      enemySpawner = SpawnComponent(
        factory: (index) => _spawnEnemy(),
        period: period,
        area: Rectangle.fromLTWH(20, 0, size.x - 40, 0),
      );
      add(enemySpawner!);
    } else {
      enemySpawner!.timer.limit = period;
    }

    resumeEngine();
    // Remove any overlays that might be showing
    overlays.remove('MainMenu');
    overlays.remove('LevelSelect');
    overlays.remove('GameOver');
  }

  void gameOver() {
    HighScoreService.saveHighScore(score);
    pauseEngine();
    overlays.add('GameOver');
  }

  /// Restart at the same level the player chose from the level select.
  void restart() {
    startGame(startLevel: _selectedLevel);
  }

  /// Return to the level select screen (called from Game Over).
  void returnToLevelSelect() {
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());
    player.children.whereType<CircleComponent>().forEach((c) => c.removeFromParent());
    overlays.remove('GameOver');
    overlays.add('LevelSelect');
    // engine stays paused — startGame() will resume it
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Update loop
  // ──────────────────────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    // Auto bullet fire (fires in both intro and gameplay)
    _bulletTimer += dt;
    if (_bulletTimer >= _bulletPeriod) {
      _bulletTimer = 0;
      _fireBullets();
    }

    // Shield timer
    if (isShielded) {
      _shieldTimer -= dt;
      if (_shieldTimer <= 0) {
        isShielded = false;
        player.children
            .whereType<CircleComponent>()
            .forEach((c) => c.removeFromParent());
      }
    }

    // Speed boost timer
    if (isSpeedBoost) {
      _speedTimer -= dt;
      if (_speedTimer <= 0) isSpeedBoost = false;
    }

    // Intro: auto-aim player at first enemy
    if (isIntro) {
      final activeEnemies = children.whereType<Enemy>();
      if (activeEnemies.isNotEmpty) {
        final target = activeEnemies.first;
        final targetX =
            target.position.x + target.size.x / 2 - player.size.x / 2;
        final moveSpeed = 400 * dt;
        if ((player.position.x - targetX).abs() > 4.0) {
          player.position.x = player.position.x < targetX
              ? min(player.position.x + moveSpeed, targetX)
              : max(player.position.x - moveSpeed, targetX);
        }
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Input
  // ──────────────────────────────────────────────────────────────────────────
  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.position.x = (player.position.x + info.delta.global.x)
        .clamp(0.0, size.x - player.size.x);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Tap fires an extra burst on top of the auto-fire
    _fireBullets();
  }
}
