import 'package:polymer/polymer.dart';
import 'dart:html';

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
  @published bool autoPlay = false;
  String playPauseState = "pause";
  ElementList<VideoElement> videoStreamList;

  VideoPlayer.created() : super.created() {
  }

  @override
  void attached() {
    this.querySelector("video-stream:last-child").setAttribute("flex", "");
    videoStreamList = this.querySelectorAll("video-stream");
    videoStreamList.forEach(
        (stream) => stream..resize()
                          //..alert()
    );    
  }
  
  void play([Event e]){
    videoStreamList.forEach(
        (stream) => stream.play()
    );
    playPauseState = "play";
  }
  
  void pause([Event e]){
    videoStreamList.forEach(
        (stream) => stream.play()
    );
    playPauseState = "pause";
  }
  
  void togglePlayState(){
    
  }
  
  void speedChanged() {
    this.querySelectorAll("video-stream").forEach(
            (stream) => stream.setSpeed(speed)
        );
  }
  
  void toggleSpeed(){
    if(speed == "1.0"){
      speed = "1.3";
    }
    else if(speed == "1.3"){
      speed = "1.7";
    }
    else if(speed == "1.7"){
      speed = "0.7";
    }
    else {
      speed = "1.0";
    }
    this.shadowRoot.querySelector("video-controlbar").changeSpeed(speed);
  }
  
}

