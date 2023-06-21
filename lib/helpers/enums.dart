/// File containing all of the enums

enum BagStatus {
  idle,
  takeoff,
  soaring,
  landing,
  crashing,
  sliding,
  touchBounds
}

enum GameState { initializing, ready, ongoing, complete }

enum TimerState { on, off }

enum CanTouch { yes, no }

enum Toss { waiting, beginner, intermediate, advance }
