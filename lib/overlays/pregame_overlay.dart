import 'package:flutter/material.dart';
import '../game_world.dart';

/// Declare a PreGameOverlay widget as a stateless widget.
///
/// The PreGameOverlay widget is a widget that centers a Text widget in the
/// GameWidget container with text instructing the player to tap the button to begin the game.
class PreGameOverlay extends StatelessWidget {
  final GameWorld game;
  static const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
  static const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

  const PreGameOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 280,
          width: 340,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'HomeRun Bat',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tap the sangbag and flick \nit off the the screen',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                  width: 200, height: 75, child: _playButton(context, game)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playButton(BuildContext context, GameWorld game) {
    return ElevatedButton(
      onPressed: () {
        game.startGame();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: whiteTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text(
        'Start',
        style: TextStyle(
          fontSize: 40.0,
          color: blackTextColor,
        ),
      ),
    );
  }
}
