import 'dart:developer';

import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:flame/components.dart';
import 'package:flame/src/timer.dart' as Timer;
import 'package:flame/input.dart';
import 'package:homerun/components/wall.dart';

import '../game_world.dart';
import '../helpers/sandbag_rive.dart';
import '../helpers/enums.dart';
import 'ground.dart';

class SandBag extends BodyComponent<GameWorld>
    with Tappable, Draggable, ContactCallbacks {
  late SandbagComponent sandbagRive;
  late Vector2 position;
  late double tossSpeed = 0.0;

  late bool wentRight = true;
  late double decrease = 0;

  /// change the camera anchors
  late double panningX = 0.0;
  late double panningY = 0.8;

  late var currentState = BagStatus.idle; // current state of the sanbag
  late var tossState = Toss.waiting;

  late Vector2 dragInitPosition = Vector2.zero();
  late Vector2 dragLastPosition = Vector2.zero();
  late var dragDuration = 0;

  late Timer.Timer interval;
  int elapsedSecs = 0;
  late bool moveBackgroundUp = false;
  late bool moveBackgroundDown = false;

  SandBag({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    sandbagRive = SandbagComponent(sandbagArtboard: gameRef.sandbagArtboard)
      ..anchor = const Anchor(0.35, 0.5);
    add(sandbagRive);

    /// Move the parallax background up or down every 0.1s.
    interval = Timer.Timer(0.1,
        onTick: () => {
              if (moveBackgroundUp)
                {elapsedSecs += 1, gameRef.moveParallax(tossSpeed, -200)}
              else if (moveBackgroundDown)
                {
                  if (elapsedSecs >= 1)
                    {gameRef.moveParallax(tossSpeed, 200), elapsedSecs -= 1}
                  else
                    {gameRef.moveParallax(tossSpeed, 0)}
                },
            },
        repeat: true);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..userData = this
      ..bullet = true
      ..type = BodyType.dynamic
      ..position = position;
    final bag = world.createBody(bodyDef);
    final shape = PolygonShape()..setAsBoxXY(0.35, 0.35);
    final fixtureDef = FixtureDef(shape)
      ..friction = 0.2
      ..density = 20.0; // A density of 20 kg/m^3 is acceptable for the sandbag
    bag.createFixture(fixtureDef);
    return bag;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ground) {
      switch (currentState) {
        case BagStatus.takeoff:
          currentState = BagStatus.idle;
          break;
        case BagStatus.landing:
          FlameAudio.play('explosion.wav');
          currentState = BagStatus.crashing;
          break;
        case BagStatus.touchBounds:
          FlameAudio.play('explosion.wav');
          break;
        default:
          log("beginContact with $currentState");
          break;
      }
    } else if (other is Wall) {
      currentState = BagStatus.touchBounds;
    }
  }

  @override
  void update(double dt) {
    /// This allows the timer to work
    interval.update(dt);

    switch (currentState) {
      case BagStatus.idle:
        gameRef.moveParallax(0, 0); // Stop moving background
        break;
      case BagStatus.touchBounds:
        _endGame();
        break;
      default:
        break;
    }

    /// Handle the sandbag's movement depending on the number of taps
    switch (tossState) {
      case Toss.beginner:
        _beginnerToss();
        break;
      case Toss.intermediate:
        _intermediateToss();
        break;
      case Toss.advance:
        _advanceToss();
        break;
      default:
        break;
    }
  }

  @override
  bool onTapUp(TapUpInfo info) {
    switch (gameRef.bagTapState) {
      case CanTouch.yes:
        sandbagRive.animationTap();
        FlameAudio.play('punch-boxing.mp3');
        gameRef.tapCount += 1;

        /// Set the Toss enum value based on the tapCount
        if (gameRef.tapCount <= 7) {
          tossState = Toss.beginner; // 1 - 8
        } else if (gameRef.tapCount > 7 && gameRef.tapCount < 12) {
          tossState = Toss.intermediate; // 9-11
        } else {
          tossState = Toss.advance; // 12 ++
        }
        break;
      default:
        break;
    }
    return true;
  }

  @override
  bool onDragStart(DragStartInfo info) {
    /// Stores the intial position
    dragInitPosition = info.eventPosition.game;
    dragDuration = 0;
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    /// Stop the player from moving the bag when it is in motions
    if (gameRef.bagTapState == CanTouch.yes) {
      /// Stop the bag from being dragged out of bounds
      if ((dragInitPosition.y > info.eventPosition.game.y) &&
          (info.eventPosition.game.x > 0.0)) {
        /// Fetch the latest drag position
        dragLastPosition = info.eventPosition.game;

        /// Allows the bag to be dragged
        body.setTransform(info.eventPosition.game, 0.0);

        /// Fetch the new starting postion for when the bag is flicked
        gameRef.initDistance = body.position.x;
        dragDuration++;
      }
    }
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    if (gameRef.bagTapState == CanTouch.yes) {
      body.applyLinearImpulse(Vector2(0.0, 5.0)); // apply force after dragging

      if (gameRef.tapCount != 0) {
        /// The bag is thrown when the play drags the bag quickly (flick).
        /// This simulates flicking as it is not built into Forge or Flame
        if ((dragDuration <= 16) && (dragLastPosition.y > 0)) {
          tossSpeed = gameRef.tapCount * _speedMultiplier(dragDuration);

          /// Determine the direction the sandbag will be toss
          if ((dragLastPosition.x > dragInitPosition.x)) {
            body.applyLinearImpulse(Vector2(tossSpeed, -tossSpeed));
            log("go right");
          } else {
            wentRight = false;
            body.applyLinearImpulse(Vector2(-tossSpeed, -tossSpeed));
            log("go left");
          }
          gameRef.bagTapState = CanTouch.no;
          currentState = BagStatus.takeoff;
          gameRef.stopWatch.timer.pause();
          FlameAudio.play('whoosh.mp3', volume: 2.25);
        }
      }
    }
    return false;
  }

  void _beginnerToss() {
    camera.speed = 15;

    /// Handle the camera movement depending on tapCount's value
    if (gameRef.tapCount < 5) {
      if ((body.position.x - .5) > gameRef.size.x) {
        camera.moveTo(Vector2(body.position.x - 16, 0));
        gameRef.moveParallax(tossSpeed, 0);
      }
    } else {
      if ((body.position.x - 2) > gameRef.size.x) {
        camera.snapTo(Vector2(body.position.x - decrease, 0));
        gameRef.moveParallax(tossSpeed, 0);
        if (currentState != BagStatus.crashing) decrease += 0.04;
      }
    }

    switch (currentState) {
      case BagStatus.takeoff:
        if (body.previousTransform.p.y < body.transform.p.y) {
          currentState = BagStatus.landing;
        }
        break;
      case BagStatus.crashing:
        _endGame();
        gameRef.moveParallax(0, 0);
        break;
      default:
        break;
    }
  }

  /// Handles camera movement
  void _intermediateToss() {
    switch (currentState) {
      case BagStatus.takeoff:

        /// ***** Set BagStatus to soaring when the sandbag leaves the screen ***** \\\
        if (body.position.y < 0) currentState = BagStatus.soaring;
        break;
      case BagStatus.soaring:
        moveBackgroundUp = true;

        camera.followBodyComponent(this,
            relativeOffset: Anchor(panningX, panningY));
        _followCameraAdjustment();

        if (body.previousTransform.p.y < body.transform.p.y) {
          currentState = BagStatus.landing;
        }
        break;

      case BagStatus.landing:
        moveBackgroundUp = false;
        moveBackgroundDown = true;

        /// Adjusts the Rive animations angles
        if (sandbagRive.angle < 1.1) {
          sandbagRive.angle =
              double.parse((sandbagRive.angle).toStringAsFixed(3)) + 0.04;
        }
        camera.followBodyComponent(this,
            relativeOffset: Anchor(panningX, panningY));
        _followCameraAdjustment();
        break;

      case BagStatus.crashing:
        moveBackgroundDown = false;

        camera.followBodyComponent(this,
            relativeOffset: Anchor(panningX, panningY));
        _sliding();
        break;

      default:
        break;
    }
  }

  void _advanceToss() {
    switch (currentState) {
      case BagStatus.takeoff:

        /// Only play animation when swiped right
        if (dragLastPosition.x > dragInitPosition.x) {
          sandbagRive.animationflying(true);
        }

        /// ***** Set BagStatus to soaring when the sandbag leaves the screen ***** \\\
        if (body.position.y < 0) {
          currentState = BagStatus.soaring;
          gameRef.moveParallax(tossSpeed, 0);
        }
        break;
      case BagStatus.soaring:
        moveBackgroundUp = true; // parallax pan up

        _adjustRiveAngle(-0.2, true);
        camera.followBodyComponent(this,
            relativeOffset: Anchor(panningX, panningY));
        _followCameraAdjustment();

        if (body.previousTransform.p.y < body.transform.p.y) {
          currentState = BagStatus.landing;
        }
        break;

      case BagStatus.landing:
        moveBackgroundUp = false;
        moveBackgroundDown = true; // parallax pan down

        _adjustRiveAngle(0.65, true);
        camera.followBodyComponent(this,
            relativeOffset: Anchor(panningX, panningY));
        _followCameraAdjustment();
        break;

      case BagStatus.crashing:
        moveBackgroundDown = false;

        sandbagRive.animationHitGround();
        _adjustRiveAngle(0, false);

        /// Place grass layer in original position to hide separation
        gameRef.lowerGrassBg.position.y = 0;
        camera.followBodyComponent(this,
            relativeOffset: Anchor(panningX, panningY));
        currentState = BagStatus.sliding;
        break;

      case BagStatus.sliding:
        _sliding();
        break;

      default:
        break;
    }
  }

  /// Decrease the speed of the parallax background & Stop it from moving vertically
  void _sliding() {
    if (tossSpeed > 3) {
      tossSpeed -= 2;
      gameRef.moveParallax(tossSpeed, 0);
    } else {
      _endGame();
    }
  }

  /// Finds the appropriate multipler for the back throw.
  ///
  /// The output will be used to affect the linear impluse of the sandbag based on how long the sandbag was flicked
  double _speedMultiplier(int duration) {
    double multiplier = 0;
    if (duration <= 8) {
      multiplier = 15;
    } else {
      multiplier = 17;
    }
    return multiplier;
  }

  /// End the game when the sandbag stops moving
  void _endGame() {
    if ((body.previousTransform.p.x == body.transform.p.x)) {
      gameRef.gameState = GameState.complete;

      /// Checks if the bag is left the screen
      if (body.position.x < gameRef.size.x) {
        gameRef.overlayTitle = "Failed!";
        gameRef.gameFailed = true;
      }
    }
  }

  void _adjustRiveAngle(double angle, bool inAir) {
    switch (inAir) {
      case true:
        if (sandbagRive.angle < angle) {
          sandbagRive.angle =
              double.parse((sandbagRive.angle).toStringAsFixed(3)) + 0.01;
        }
        break;
      case false:
        if (sandbagRive.angle > angle) {
          sandbagRive.angle =
              double.parse((sandbagRive.angle).toStringAsFixed(3)) - 0.03;
        }
        break;
    }
  }

  /// Increase or Decrease the axises until the limit is reached
  void _followCameraAdjustment() {
    switch (currentState) {
      case BagStatus.soaring:
        if (panningX <= 0.4) panningX += 0.004;

        if (panningY >= 0.3) panningY -= 0.004;
        break;
      case BagStatus.landing:

        /// Do code before it gets close to the ground
        if (body.position.y <= -7) {
          if (panningX <= 0.6) panningX += 0.002;

          if (panningY <= 0.74) panningY += 0.006;
        } else {
          /// increase the y-axis Anchor until it hit 0.84,
          /// so that the background floor can be align with the ground bodyComponent
          if (panningY <= 0.84) panningY += 0.02;
        }
        break;
      default:
        break;
    }
  }
}
