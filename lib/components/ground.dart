import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:homerun/game_world.dart';

class Ground extends BodyComponent<GameWorld> {
  final Vector2? size;
  late Vector2 arenaSize;
  late Vector2 start;
  late Vector2 end;

  Ground({this.size}) {
    assert(size == null || size!.x >= 1.0 && size!.y >= 1.0);
  }

  @override
  Future<void> onLoad() async {
    // getting the size of the visible area in Forge2D world coordinates
    arenaSize = size ?? gameRef.size;
    renderBody = false;
    start = Vector2(0, arenaSize.y - 1);
    end = Vector2(arenaSize.x * 35, arenaSize.y - 1);
    return super.onLoad();
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..userData = this
      ..position = Vector2(0, 0)
      ..type = BodyType.static
      ..angularDamping = 1.0
      ..linearDamping = 1.0;
    // set angularDamping and linearDamping to 100% to prevent any movement

    final groundBody = world.createBody(bodyDef);
    final shape = EdgeShape()..set(start, end);

    groundBody.createFixture(FixtureDef(shape)
      ..density = 2000.0
      ..friction = 1.2
      ..restitution = 0.00); // give the wall some elastic recoil of 0%
    return groundBody;
  }
}
