import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homerun/game_world.dart';
import 'package:homerun/helpers/player_model.dart';

/// The ScoreWidget is a widget that displays the score list to the player
class ScoreWidget extends StatelessWidget {
  final GameWorld game;

  const ScoreWidget({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 355,
        width: 500,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: MaterialApp(
          title: 'Scores',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: _scorePage(context, 'Scores', game),
        ),
      ),
    );
  }

  Widget _scorePage(BuildContext context, String title, GameWorld game) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // toolbarHeight: 55,
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => game.overlays.remove('Score'),
              ),
            ),
          ],
        ),
      ),
      body: _scoreView(context),
    );
  }

  /// Displays a center text "Empty" if the score list does not exist.
  Widget _scoreView(BuildContext context) {
    PlayerScores playerScoresJson;
    int listIndex = 1;

    if (game.storage.getStringList("HomeRun") != null) {
      playerScoresJson = PlayerScores.fromJson(
          {"players": game.storage.getStringList("HomeRun")});
      listIndex = playerScoresJson.players.length;
      return _listView(listIndex, playerScoresJson);
    } else {
      return const Center(
        child: SizedBox(
          height: 44,
          child: Center(
              child: Text(
            'Empty',
            style: TextStyle(fontSize: 30, color: Colors.white),
          )),
        ),
      );
    }
  }

  /// Populate the score list into the list view
  Widget _listView(int listIndex, PlayerScores playerScores) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listIndex,
      itemBuilder: (BuildContext context, int index) {
        playerScores = PlayerScores.fromJson(
            {"players": game.storage.getStringList("HomeRun")});
        Map<String, dynamic> playerMap =
            jsonDecode(playerScores.players[index]);
        Player playerJson = Player.fromJson(playerMap);
        return SizedBox(
          height: 44,
          child: Center(
              child: Text(
            '${playerJson.name}: ${playerJson.score}km',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          )),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
