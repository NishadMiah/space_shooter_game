import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:aetherius/home/bullet.dart';
import 'package:aetherius/home/enemy.dart';
import 'package:aetherius/home/high_score_service.dart';
import 'package:aetherius/home/power_up.dart';
import 'package:flutter/material.dart';

class SpaceShooterGame extends FlameGame
    with PanDetector, TapCallbacks, HasCollisionDetection {
  // ─── Player ───────────────────────────────────────────────────────────────
  late SpriteComponent player;

  // ─── Scores & Level ───────────────────────────────────────────────────────
  int score = 0;
  int highScore = 0;
  int currentLevel = 1;
  int enemiesKilled = 0;
  int _enemiesForNextLevel = 5;

  // ─── Lives ────────────────────────────────────────────────────────────────
  int lives = 3;
  static const int maxLives = 3;

  // ─── Power-up State ───────────────────────────────────────────────────────
  bool isShielded = false;
  bool isSpeedBoost = false;
  double _shieldTimer = 0;
  double _speedTimer = 0;
  SpriteComponent? _shieldVisual;

  // ─── Intro State ──────────────────────────────────────────────────────────
  bool isIntro = true;
  int introEnemiesLeft = 3;

  // ─── Spawners ─────────────────────────────────────────────────────────────
  SpawnComponent? enemySpawner;
  SpawnComponent? bulletSpawner;

  // ─── HUD Components ───────────────────────────────────────────────────────
  late TextComponent scoreText;
  late TextComponent livesText;
  late TextComponent levelText;
  late TextComponent highScoreText;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    super.onLoad();
    images.prefix = 'assets/icons/';

    // Load persistent high score
    highScore = await HighScoreService.getHighScore();

    // Player
    player = SpriteComponent(
      sprite: await loadSprite('player.png'),
      size: Vector2(50, 50),
    )..add(RectangleHitbox());
    player.position = Vector2(size.x / 2, size.y - 100);
    add(player);

    // HUD
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

    livesText = TextComponent(
      text: '❤️ ❤️ ❤️',
      position: Vector2(size.x - 16, 40),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 20),
      ),
    );
    add(livesText);

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

    // Intro enemies
    add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.25, 80));
    add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.50, 100));
    add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.75, 120));

    // Auto bullet spawner
    bulletSpawner = SpawnComponent(
      factory: (index) =>
          Bullet()..position = Vector2(player.position.x + 20, player.position.y),
      period: 0.2,
      selfPositioning: true,
    );
    add(bulletSpawner!);
  }

  // ─── Score ────────────────────────────────────────────────────────────────
  void increaseScore(int amount) {
    score += amount;
    scoreText.text = 'Score: $score';
    if (score > highScore) {
      highScore = score;
      highScoreText.text = 'Best: $highScore';
    }
  }

  // ─── Enemy Killed / Level Up ──────────────────────────────────────────────
  void onEnemyKilled() {
    enemiesKilled++;
    if (enemiesKilled >= _enemiesForNextLevel) {
      _enemiesForNextLevel += 5;
      currentLevel++;
      levelText.text = 'LVL $currentLevel';
      _adjustDifficulty();
      // Show level-up overlay
      overlays.add('LevelUp');
    }
  }

  void _adjustDifficulty() {
    // Increase spawn rate each level (min 0.35s period)
    final newPeriod = max(0.35, 1.0 - (currentLevel - 1) * 0.08);
    if (enemySpawner != null) {
      enemySpawner!.timer.limit = newPeriod;
    }
  }

  Enemy _spawnEnemy() {
    final rand = Random();
    final roll = rand.nextDouble();

    // Level influences enemy type mix
    double fastChance = min(0.05 * (currentLevel - 1), 0.4);
    double tankChance = min(0.03 * (currentLevel - 1), 0.25);

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

  // ─── Lives ────────────────────────────────────────────────────────────────
  void loseLife() {
    if (isShielded) return;
    lives--;
    _updateLivesHUD();
    if (lives <= 0) {
      gameOver();
    }
  }

  void gainLife() {
    if (lives < maxLives) {
      lives++;
      _updateLivesHUD();
    }
  }

  void _updateLivesHUD() {
    final hearts = List.generate(lives, (_) => '❤️').join(' ');
    final empty = List.generate(maxLives - lives, (_) => '🖤').join(' ');
    livesText.text = '$hearts$empty';
  }

  // ─── Power-ups ────────────────────────────────────────────────────────────
  void collectPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.heart:
        gainLife();
        break;
      case PowerUpType.shield:
        _activateShield();
        break;
      case PowerUpType.speed:
        _activateSpeed();
        break;
    }
  }

  void _activateShield() {
    isShielded = true;
    _shieldTimer = 3.0;
    // Add blue ring around player
    _shieldVisual?.removeFromParent();
    _shieldVisual = SpriteComponent(size: Vector2(70, 70), anchor: Anchor.center)
      ..position = Vector2(player.size.x / 2, player.size.y / 2);
    // Draw a glowing circle using a paint override
    final shieldCircle = CircleComponent(
      radius: 35,
      paint: Paint()
        ..color = const Color(0xFF44AAFF).withAlpha(80)
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
    shieldCircle.anchor = Anchor.center;
    shieldCircle.position = Vector2(player.size.x / 2, player.size.y / 2);
    player.add(shieldCircle);
    _shieldVisual = null; // tracked indirectly via player children
  }

  void _activateSpeed() {
    isSpeedBoost = true;
    _speedTimer = 5.0;
    bulletSpawner?.timer.limit = 0.08;
  }

  // ─── Intro ────────────────────────────────────────────────────────────────
  void decrementIntroEnemies() {
    introEnemiesLeft--;
    if (introEnemiesLeft <= 0) {
      onIntroEnemyDestroyed();
    }
  }

  void onIntroEnemyDestroyed() {
    pauseEngine();
    overlays.remove('StoryIntro');
    overlays.add('MainMenu');
    isIntro = false;
  }

  // ─── Game Flow ────────────────────────────────────────────────────────────
  void startGame() {
    score = 0;
    lives = 3;
    currentLevel = 1;
    enemiesKilled = 0;
    _enemiesForNextLevel = 5;
    isShielded = false;
    isSpeedBoost = false;
    scoreText.text = 'Score: 0';
    levelText.text = 'LVL 1';
    _updateLivesHUD();
    player.position = Vector2(size.x / 2, size.y - 100);

    if (enemySpawner == null) {
      enemySpawner = SpawnComponent(
        factory: (index) => _spawnEnemy(),
        period: 1.0,
        area: Rectangle.fromLTWH(20, 0, size.x - 40, 0),
      );
      add(enemySpawner!);
    } else {
      enemySpawner!.timer.limit = 1.0;
    }

    bulletSpawner?.timer.limit = 0.2;
    resumeEngine();
    overlays.remove('MainMenu');
  }

  void gameOver() {
    // Save high score
    HighScoreService.saveHighScore(score);
    pauseEngine();
    overlays.add('GameOver');
  }

  void reset() {
    score = 0;
    lives = 3;
    currentLevel = 1;
    enemiesKilled = 0;
    _enemiesForNextLevel = 5;
    isShielded = false;
    isSpeedBoost = false;
    scoreText.text = 'Score: 0';
    levelText.text = 'LVL 1';
    highScoreText.text = 'Best: $highScore';
    _updateLivesHUD();
    player.position = Vector2(size.x / 2, size.y - 100);
    // Clear shield visual from player
    player.children.whereType<CircleComponent>().forEach((c) => c.removeFromParent());

    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    children.whereType<PowerUp>().forEach((p) => p.removeFromParent());

    if (isIntro) {
      introEnemiesLeft = 3;
      add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.25, 80));
      add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.50, 100));
      add(Enemy(type: EnemyType.basic)..position = Vector2(size.x * 0.75, 120));
    } else {
      enemySpawner?.timer.limit = 1.0;
      bulletSpawner?.timer.limit = 0.2;
    }

    resumeEngine();
    overlays.remove('GameOver');
  }

  // ─── Update ───────────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    // Power-up timers
    if (isShielded) {
      _shieldTimer -= dt;
      if (_shieldTimer <= 0) {
        isShielded = false;
        player.children.whereType<CircleComponent>().forEach((c) => c.removeFromParent());
      }
    }

    if (isSpeedBoost) {
      _speedTimer -= dt;
      if (_speedTimer <= 0) {
        isSpeedBoost = false;
        bulletSpawner?.timer.limit = 0.2;
      }
    }

    // Intro auto-aim
    if (isIntro) {
      final activeEnemies = children.whereType<Enemy>();
      if (activeEnemies.isNotEmpty) {
        final targetEnemy = activeEnemies.first;
        double targetX =
            targetEnemy.position.x +
            (targetEnemy.size.x / 2) -
            (player.size.x / 2);
        double moveSpeed = 400 * dt;
        if ((player.position.x - targetX).abs() > 4.0) {
          if (player.position.x < targetX) {
            player.position.x = min(player.position.x + moveSpeed, targetX);
          } else {
            player.position.x = max(player.position.x - moveSpeed, targetX);
          }
        }
      }
    }
  }

  // ─── Input ────────────────────────────────────────────────────────────────
  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.position.x = (player.position.x + info.delta.global.x).clamp(
      0.0,
      size.x - player.size.x,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final bullet = Bullet()
      ..position = Vector2(player.position.x + 20, player.position.y);
    add(bullet);
  }
}
