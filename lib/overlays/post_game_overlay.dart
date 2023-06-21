import 'package:flutter/material.dart';
import '../game_world.dart';
import '../main.dart';

/// The PostGameOverlay widget is a widget that centers a Text widget in the
/// GameWidget container with text instructing the player to tap the button to either replay the game or view the scoreboard.
class PostGameOverlay extends StatelessWidget {
  final GameWorld game;

  const PostGameOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: 250,
            width: 430,
            decoration: const BoxDecoration(
              color: blackTextColor,
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game.overlayTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 10),
                endMessage(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 65, child: _resetButton(context)),
                    const SizedBox(width: 25),
                    SizedBox(height: 65, child: _scoreButton()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resetButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Colors.blue,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      onPressed: () => RestartWidget.restartApp(context),
      icon: const Icon(Icons.restart_alt_outlined),
      label: const Text(
        'Replay',
        style: TextStyle(
          fontSize: 35.0,
        ),
      ),
    );
  }

  Widget _scoreButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: Colors.blue,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      onPressed: () => game.overlays.add("Score"),
      icon: const Icon(Icons.scoreboard_rounded),
      label: const Text(
        'Scores',
        style: TextStyle(
          fontSize: 35.0,
        ),
      ),
    );
  }

  Widget endMessage() {
    if (game.overlayMessage == "") {
      return Column(
        children: [
          Text(
            "Your Score: ${game.distanceTravel}km",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "With: ${game.tapCount} Hits",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 10),
          Text(
            game.overlayMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 25),
        ],
      );
    }
  }
}
