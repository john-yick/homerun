import 'dart:developer';
import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:homerun/overlays/enter_name.dart';
import 'package:homerun/overlays/high_score.dart';

import 'game_world.dart';
import 'overlays/post_game_overlay.dart';
import 'overlays/pregame_overlay.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    RestartWidget(
      child: GameWidget<GameWorld>.controlled(
        gameFactory: GameWorld.new,
        overlayBuilderMap: {
          'MainMenu': (_, game) => PreGameOverlay(game: game),
          'PostGame': (_, game) => PostGameOverlay(game: game),
          'Score': (_, game) => ScoreWidget(game: game),
          'Enter': (_, game) => EnterNameWidget(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    ),
  );
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, this.child});
  final Widget? child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<StatefulWidget> createState() {
    return _RestartWidgetState();
  }
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child ?? Container(),
    );
  }

  //  initState() is a method which is called once when the stateful widget is inserted in the widget tree.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        FlutterNativeSplash.remove();
        log("Completed");
      });
    });
  }
}
