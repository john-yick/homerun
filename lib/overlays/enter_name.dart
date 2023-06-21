import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:homerun/game_world.dart';

/// EnterNameWidget is a widget in the GameWidget container with
/// text instructing the player to enter a 4 character name.
class EnterNameWidget extends StatefulWidget {
  final GameWorld game;

  const EnterNameWidget({super.key, required this.game});

  @override
  State<EnterNameWidget> createState() => _EnterNameWidgetState();
}

class _EnterNameWidgetState extends State<EnterNameWidget> {
  late TextEditingController _controller;
  late String name = "";
  late Color nameBoxColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      log(name);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                height: 210,
                width: 360,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.game.overlayTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 25),
                    enterPlayer(context),
                    _enterButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget enterPlayer(BuildContext context) {
    return Flexible(
      child: SizedBox(
        width: 130,
        height: 100,
        child: TextField(
          controller: _controller,
          autofocus: true,
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          enableSuggestions: false,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
          maxLength: 4,
          cursorColor: nameBoxColor,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 3, color: nameBoxColor),
            ),
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _enterButton() {
    return SizedBox(
      width: 100,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          name = _controller.text;
          if (name == "") {
            nameBoxColor = Colors.red;
            log('Not eligible');
          } else {
            log("Entered: $name");
            widget.game.closeEnterNameOverlay(name);
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: const Text(
          'Enter',
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
      ),
    );
  }
}
