import 'package:polymer/polymer.dart';

/**
 * A Polymer element.
 */
@CustomTag('video-player')
class VideoPlayer extends PolymerElement {
  @published int time = 0;
  @published int duration = 0;
  @published String speed = "1.0";
  @published String quality;
  @published String volume = "1.0";  // 0.0 - 1.0

  VideoPlayer.created() : super.created() {
    this.querySelector("video-stream:last-child").setAttribute("flex", "");
    this.querySelectorAll("video-stream").forEach(
        (stream) => stream..resize()
                          ..setAttribute("speed", speed)
                          ..setAttribute("volume", volume)
                          //..alert()
    );
  }
}

