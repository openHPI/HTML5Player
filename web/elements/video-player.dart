import 'package:polymer/polymer.dart';
import 'dart:html';

/**
 * A Polymer element.
 */
@CustomTag('video-player')
class VideoPlayer extends PolymerElement {
  @published int time = 0;
  @published int duration = 0;
  @published double speed = 1.0;
  @published String quality = "sd";

  VideoPlayer.created() : super.created() {
  }

  void increment() {
    time++;
  }
}

