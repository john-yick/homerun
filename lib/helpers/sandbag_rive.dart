import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';

/// Used to start animations in the sandbagArtboard
class SandbagComponent extends RiveComponent with Tappable, HasGameRef {
  late Artboard sandbagArtboard;
  late OneShotAnimation sandbagController;

  SandbagComponent({required this.sandbagArtboard})
      : super(artboard: sandbagArtboard, size: Vector2.all(13));

  void animationflying(bool active) {
    sandbagController = OneShotAnimation('toss', autoplay: true, mix: 10);
    sandbagArtboard.addController(sandbagController);
    anchor = const Anchor(0.66, 0.5);
    angle = -0.9;
  }

  void animationflick() {
    sandbagController = OneShotAnimation('flick', autoplay: true);
    sandbagArtboard.addController(sandbagController);
  }

  void animationHitGround() {
    /// Stopping the previous animation before starting the new one.
    sandbagController.instance?.animation.loopValue = 0;
    sandbagController.instance?.animation.duration = 0;

    sandbagController = OneShotAnimation('bounce', autoplay: true);
    sandbagArtboard.addController(sandbagController);
    anchor = const Anchor(0.35, 0.5);
    angle = 1.25;
  }

  void animationTap() {
    sandbagController = OneShotAnimation('tap', autoplay: true);
    sandbagArtboard.addController(sandbagController);
  }

  void animationfalling() {
    sandbagController = OneShotAnimation('falling', autoplay: true);
    sandbagArtboard.addController(sandbagController);
  }
}
