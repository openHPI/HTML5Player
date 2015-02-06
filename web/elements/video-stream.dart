library videoStream;
import 'package:polymer/polymer.dart';
import 'dart:math';
import 'dart:html';
import 'dart:async';

@CustomTag('video-stream')
class VideoStream extends PolymerElement {
  
  //published attributes
  @published String sd_src;
  @published String hd_src;
  @published String poster;
  @published String ratio;
  @published String subtitles;
  
  @published bool isPlaying;
  @published int progress = 0;
  @published int buffered;
  @published int duration;
  @published bool isHD;
  @published double speed;
  @published int volume;
  
  bool notStarted = true;
  
  //referenced elements
  VideoElement video;
  
  @observable
  VideoStream.created() : super.created() { }
  
  @override
  void attached() {
    video = this.shadowRoot.querySelector("video");
    
    video.on['durationchange'].listen((event)=>
      duration = video.duration.floor()
    );
    
    new Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if(video.readyState>=1){
        isPlaying = !video.paused;
        progress = video.currentTime.floor();
        buffered = video.buffered.end(0).floor();
      }
    });
  }
  
  //PlayPause
  void isPlayingChanged(){
    if(isPlaying){
      video.play();
      notStarted = false;
    }
    else{
      video.pause();
    }
  }

  //Progress
  void progressChanged(oldValue, newValue){
    if((oldValue - newValue).abs() >= 3){
      video.currentTime = newValue;
    }
  }
  
  //Quality
  void isHDChanged(){
    if(isHD){
      setHD();
    }
    else{
      setSD();
    }
  }
  
  //Speed
  void speedChanged(){
    video.playbackRate = speed;
  }
  
  //Volume
  void volumeChanged(){
    video.volume = volume/100;
  }
  
  void setHD(){
    if(hd_src != null){
      var currentTime = video.currentTime;
      video.src = hd_src;
      if(!notStarted){
        video.load();
        video.currentTime = currentTime;
        video.play();
      }
    }
    else {
      setSD();
    }
  }
  
  void setSD(){
    if(sd_src != null){
      var currentTime = video.currentTime;
      video.src = sd_src;
      if(!notStarted){
        video.load();
        video.currentTime = currentTime;
        video.play();
      }
    }
    else {
      setHD();
    }
  }
  
  void showSubtitles(){
    video.textTracks.first.mode = "showing";
  }
  
  void hideSubtitles(){
    video.textTracks.first.mode = "disabled";
  }
  
  void resize([int videoCount]) {
    
    videoCount --;
    double controlbarHeight = 48.0;
    double minVideoWidth = 100.0;
    double parentWidth = double.parse( this.parent.getComputedStyle().width.replaceAll('px', '') );
    
    double newWidth = double.parse( this.getComputedStyle().width.replaceAll('px', '') );
    newWidth = min( videoCount*parentWidth - minVideoWidth , max(minVideoWidth, newWidth) );
    
    double newHeight = newWidth * ratioAsDouble(ratio);
    if (!(newHeight + controlbarHeight > document.documentElement.clientHeight)) {
      this.style.width = newWidth.toString() + "px";
      this.style.height = newHeight.toString() + "px";
    }  
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
