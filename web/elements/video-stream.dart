library videoStream;
import 'package:polymer/polymer.dart';
import 'dart:math';
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

  bool isPlaying(){
    return !video.paused;
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
  
  void setProgress(double currentTime){
    video.currentTime = currentTime;
  }
  
  double getProgress(){
    return video.currentTime;
  }
  
  void setSpeed(double speed){
    video.playbackRate = speed;
  }
  
  void resize() {
    double minVideoWidth = 100.0;
    
    double parentWidth = double.parse( this.parent.getComputedStyle().width.replaceAll('px', '') );
    
    double newWidth = double.parse( this.getComputedStyle().width.replaceAll('px', '') );
    newWidth = min( parentWidth - minVideoWidth , max(minVideoWidth, newWidth) );
    
    double newHeight = newWidth * ratioAsDouble(ratio);
    
    this.style.width = newWidth.toString() + "px";
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
