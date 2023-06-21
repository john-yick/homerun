import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:homerun/game_world.dart';

/// Class creates the Head Up Design of the game
class Hud extends PositionComponent with HasGameRef<GameWorld> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  }) {
    positionType = PositionType.viewport;
  }

  late TextComponent _scoreTextComponent;
  late TextComponent _hitTextComponent;
  late TextComponent _timeTextComponent;

  @override
  Future<void>? onLoad() async {
    _scoreTextComponent = TextComponent(
      text: '${game.distanceTravel} KM',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Color.fromRGBO(10, 10, 10, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x * 6, 40),
    );
    add(_scoreTextComponent);

    _hitTextComponent = TextComponent(
      text: '${game.tapCount} Hits',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Color.fromRGBO(10, 10, 10, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x * 26, 40),
    );
    add(_hitTextComponent);

    _timeTextComponent = TextComponent(
      text: '${game.timeLeft}s',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Color.fromRGBO(10, 10, 10, 1),
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(game.size.x * 45, 40),
    );
    add(_timeTextComponent);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.distanceTravel} KM';
    _hitTextComponent.text = '${game.tapCount} Hits';
    _timeTextComponent.text = '${game.timeLeft}s';
    super.update(dt);
  }
}
