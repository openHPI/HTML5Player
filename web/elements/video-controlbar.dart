import 'package:polymer/polymer.dart';
import 'dart:html';
/**
 * A Polymer element.
 */
@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  Element videoPlayer;
  ButtonElement speedButton;
  
  VideoControlBar.created() : super.created() {
  }
  
  @override
  void attached() {
    super.attached();
    videoPlayer = this.parentNode.host;
    this.shadowRoot.querySelector('#playPauseButton').onClick.listen(videoPlayer.play);
    
    speedButton = $['speedButton'];
    speedButton.onClick.listen(clickOnSpeed);
  }
  
  void clickOnSpeed(Event e){
    document.querySelector("video-player").toggleSpeed();
  }
  
  void changeSpeed(double d){
    speedButton.setInnerHtml(d.toString());
  }
  
}