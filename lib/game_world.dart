import 'dart:async';
import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homerun/components/wall.dart';
import 'package:homerun/helpers/player_model.dart';
import 'helpers/enums.dart';
import 'components/sandbag.dart';
import 'components/ground.dart';
import 'overlays/hud.dart';

class GameWorld extends Forge2DGame
    with HasTappables, HasDraggables, HasCollisionDetection {
  GameWorld() : super(gravity: Vector2(0.0, 10));

  late final SandBag _sandBag;
  late final Ground _floor;
  late final Wall _wall, _ceiling;
  late final SharedPreferences storage;
  late List<String> playerScoreList = [];
  late String playerName = "";
  late String overlayTitle = "Win!";
  late String overlayMessage = "";

  /// Contains the Rive animations for the sandbag
  late Artboard sandbagArtboard;

  late int timeLeft = 10;
  late int tapCount = 0;
  late TimerComponent stopWatch;
  late double initDistance = 0;
  late double finalDistance;
  late int distanceTravel = 0;
  late ParallaxComponent background, lowerGrassBg, grassBg;
  late GameState gameState = GameState.initializing;
  late TimerState timerState = TimerState.off;
  late CanTouch bagTapState = CanTouch.yes;
  late bool gameFailed = false;

  @override
  Future<void> onLoad() async {
    camera.zoom = 50;

    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      'whoosh.mp3',
      'punch-boxing.mp3',
      'background.mp3',
    ]);
    storage = await SharedPreferences.getInstance();
    sandbagArtboard =
        await loadArtboard(RiveFile.asset('assets/images/sandbagRiv.riv'));
    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    /// Vectors for the wall & ceiling body objects
    final topLeft = Vector2.zero();
    final bottomLeft = Vector2(0, size.y);
    final topRight = Vector2(size.x, 0);

    ParallaxComponent skyLayer =
        await loadParallaxComponent([ParallaxImageData('parallax/sky.png')]);
    final layersMeta = {
      'parallax/mountain_far.png': 1.0,
      'parallax/mountain_near.png': 1.5,
      'parallax/trees_far.png': 2.5,
      'parallax/trees_middle.png': 3.5,
      'parallax/trees_near.png': 5.5,
      'parallax/bushes.png': 6.0
    };
    final layers = layersMeta.entries.map((e) => loadParallaxLayer(
        ParallaxImageData(e.key),
        velocityMultiplier: Vector2(e.value, 1.0)));

    background = ParallaxComponent(
        parallax:
            Parallax(await Future.wait(layers), baseVelocity: Vector2(20, 0)));

    lowerGrassBg = await loadParallaxComponent(
        [ParallaxImageData('parallax/static_dirt.png')],
        velocityMultiplierDelta: Vector2(7.6, 1.0));

    grassBg = await loadParallaxComponent(
        [ParallaxImageData('parallax/ground.png')],
        velocityMultiplierDelta: Vector2(7.6, 1.0));

    add(skyLayer);
    add(background);
    add(lowerGrassBg);
    add(grassBg);

    _floor = Ground();
    _wall = Wall(topLeft, bottomLeft, Vector2.zero());
    _ceiling = Wall(topLeft, topRight, Vector2(-size.x, 0));

    await add(_floor);
    await add(_wall);
    await add(_ceiling);

    _sandBag = SandBag(position: size / 2);
    await add(_sandBag);

    stopWatch = TimerComponent(
        period: 1,
        repeat: true,
        onTick: () => {
              if (timerState == TimerState.on)
                {
                  if (timeLeft > 0)
                    {timeLeft -= 1}
                  else
                    {timerState = TimerState.off}
                }
            });

    add(stopWatch);
    add(Hud());
    overlays.add('MainMenu');
  }

  @override
  void update(double dt) {
    super.update(dt);

    /// Calculate the distance travelled when the sandbag is flicked off screen.
    finalDistance = _sandBag.body.position.x;
    if ((bagTapState == CanTouch.no) && (_sandBag.body.position.x > size.x)) {
      distanceTravel = finalDistance.round() - initDistance.round();
    }

    /// Move the ceiling when the sandbag is flicked left.
    ///
    /// The ceiling will stop the movement of the sandbag on impact.
    /// The ceiling was placed to encourage the sandbag to be thrown in one direction.
    if ((!_sandBag.wentRight)) _ceiling.body.setTransform(Vector2.zero(), 0);

    switch (gameState) {
      case GameState.ready:
        FlameAudio.bgm.play('background.mp3');
        timerState = TimerState.on;
        gameState = GameState.ongoing;
        break;

      case GameState.ongoing:

        /// Ends the game when the time runs out
        if ((timerState == TimerState.off) && (bagTapState == CanTouch.yes)) {
          gameFailed = true;
          overlayTitle = "Failed!";
          overlayMessage = "Flick before the timer runs out!";
          gameState = GameState.complete;
        }

        /// Move the floor when the bag is about to fall
        if (_sandBag.currentState == BagStatus.landing) {
          final xPositionOffset = _sandBag.body.position.x - (initDistance);
          final newPositon = Vector2((xPositionOffset), 0);
          _floor.body.setTransform(newPositon, 0);
        }
        break;

      case GameState.complete:
        if (!gameFailed) {
          /// Displays the Enter overlay screen if "Homerun" storage doesn't exist yet
          if (storage.getStringList("HomeRun") == null) {
            overlayTitle = "High Score!";
            overlays.add('Enter');
          } else {
            overlayTitleConfig();
          }
        } else {
          overlays.add("PostGame");
        }
        FlameAudio.bgm.stop();
        pauseEngine();
        break;
      default:
        break;
    }
  }

  Future<void> startGame() async {
    gameState = GameState.ready;
    overlays.remove("MainMenu");
  }

  void closeEnterNameOverlay(String name) {
    playerName = name;
    overlayTitle = "Congratulations!";
    overlays.remove('Enter');
    setScoreList();
    overlays.add("PostGame");
  }

  /// Places the new player score into the "Homerun" storage preference StringList to create a score list
  ///
  /// The list is sorted in descending order and has a max length of 5
  void setScoreList() {
    /// Create a new Player String
    String currentPlayerJson =
        jsonEncode({"name": playerName, "score": distanceTravel});

    /// Dumbs a StringList from "Homerun" storage preference into a list.
    ///
    /// Only happens if the "Homerun" storage preference exist.
    if (storage.getStringList("HomeRun") != null) {
      playerScoreList = storage.getStringList("HomeRun")!;
    }

    /// Add the new player object into the list
    playerScoreList.add(currentPlayerJson);

    playerScoreList.sort((a, b) {
      Player aJson = Player.fromJson(jsonDecode(a));
      Player bJson = Player.fromJson(jsonDecode(b));
      return bJson.score.compareTo(aJson.score);
    });

    if (playerScoreList.length > 5) playerScoreList.length = 5;

    PlayerScores playerScoresJson =
        PlayerScores.fromJson({"players": playerScoreList});

    /// Place the PlayerScores list into storage preference
    storage.setStringList("HomeRun", playerScoresJson.players);
    storage.setInt("HomeRunLength", playerScoreList.length);
  }

  /// Determine the overlay title
  /// Update the score board
  ///
  /// This is done by comparing the highest score to the new score,
  /// then compare the last score to the newest score
  void overlayTitleConfig() {
    playerScoreList = storage.getStringList("HomeRun")!;

    var bestPlayer = playerScoreList[0];
    String fifthPlayer;
    int lastScore = 0;
    Player bestPlayerJson = Player.fromJson(jsonDecode(bestPlayer));

    /// Checks whether the last item in a list is the 5th item
    ///
    ///If true, the last item will be parsed to fetch its score
    if (playerScoreList.lastIndexOf(playerScoreList.last) == 4) {
      fifthPlayer = playerScoreList.last;
      Player fifthPlayerJson = Player.fromJson(jsonDecode(fifthPlayer));
      lastScore = fifthPlayerJson.score;
    }

    if (distanceTravel > bestPlayerJson.score) {
      overlayTitle = "New High Score!";
      overlays.add('Enter');
    } else if (distanceTravel > lastScore) {
      overlayTitle = "In the Top 5";
      overlays.add('Enter');
    } else {
      overlays.add('PostGame');
    }
  }

  void moveParallax(double x, double y) {
    background.parallax?.baseVelocity = Vector2(x, y);
    lowerGrassBg.parallax?.baseVelocity = Vector2(x, y);
    grassBg.parallax?.baseVelocity = Vector2(x, y);
  }
}
