import 'package:polymer/polymer.dart';
import 'dart:html';

/**
 * A Polymer element.
 */
@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  ButtonElement playPauseButton;
  Element videoPlayer;
  
  VideoControlBar.created() : super.created() {
  }
  
  @override
  void attached() {
    super.attached();
    videoPlayer = this.parentNode.host;
    this.shadowRoot.querySelector('#playPauseButton').onClick.listen(videoPlayer.play);
  }

}