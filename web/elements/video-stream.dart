library videoStream;
import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('video-stream')
class VideoStream extends PolymerElement {
  
  //published attributes
  @published String sd_src;
  @published String hd_src;
  @published String poster;
  @published String ratio;
  
  //referenced elements
  VideoElement video;
  
  @observable
  VideoStream.created() : super.created() { }
  
  @override
  void attached() {
    video = this.shadowRoot.querySelector("video");
  }
  
  void play(){
    video.play();
  }
  
  void pause(){
    video.pause();
  }
  
  void setVolume(int volume){
    video.volume = volume/100;
  }
  
  void setCurrentTime(int currentTime){
    video.currentTime = currentTime;
  }
  
  int getCurrentTime(){
    return video.currentTime.floor();
  }
  
  void setSpeed(double speed){
    video.playbackRate = speed;
  }
  
  void resize() {
    double width = double.parse( this.getComputedStyle().width.replaceAll('px', '') );
    double newHeight = width * ratioAsDouble(ratio);
    this.style.height = newHeight.toString() + "px";
  }
  
  double ratioAsDouble(String ratio){
    if(ratio == "4:3"){
      return 3/4;
    }
    else if(ratio == "16:9"){
      return 9/16;
    }
    else{
      // default ratio = 16:9
      return 9/16;
    }
  }
  
}
