import 'package:flame_forge2d/flame_forge2d.dart';

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;
  late Vector2 position;

  Wall(this.start, this.end, this.position);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape)
      ..density = 2000.0
      ..friction = 2
      ..restitution = .15;

    final bodyDef = BodyDef()
      ..userData = this // To be able to determine object in collision
      ..position = position
      ..type = BodyType.static
      ..angularDamping = 1.0
      ..linearDamping = 1.0;

    renderBody = false;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
