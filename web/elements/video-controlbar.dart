import 'package:polymer/polymer.dart';
import 'dart:html';
/**
 * A Polymer element.
 */
@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  ElementList<VideoElement> videoList;
  ButtonElement playPauseButton;
  
  VideoControlBar.created() : super.created() {


  }
  
  @override
  void attached() {
    super.attached();
    
    videoList = document.querySelectorAll('video-stream /deep/ video');    
  
    playPauseButton = $['playPauseButton'];
    playPauseButton.onClick.listen(togglePlayer);
  }
  
  void togglePlayer(Event e) {
    if (videoList.first.paused) {
      videoList.forEach(
        (stream) => stream..play());      
      playPauseButton.setInnerHtml("pause");
    }
    else {
      videoList.forEach(
        (stream) => stream..pause());
      playPauseButton.setInnerHtml("play");
    }   
  }
  

}