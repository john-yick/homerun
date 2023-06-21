/// JSON parser classes.
///
/// Used to help store or read the string list stored in GameWorld's storage field
class Player {
  final String name;
  final int score;

  Player(this.name, this.score);

  Player.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        score = json['score'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
      };
}

class PlayerScores {
  final List<String> players;

  PlayerScores(this.players);

  PlayerScores.fromJson(Map<String, dynamic> json) : players = json['players'];

  Map<String, dynamic> toJson() => {
        'players': players,
      };
}
