library videoPlayer;
import 'package:polymer/polymer.dart';
import 'video-stream.dart';
import 'dart:html';
import 'dart:async';

@CustomTag('video-player')
class VideoPlayer extends PolymerElement {
  
  //published attributes
  @published bool autoplay = false;
  @published double setProgress = 0.0;
  @published int duration = 1;
  @published double speed = 1.0;
  @published String quality = "sd";
  @published int volume = 80;
  
  @observable bool isPlaying = false;
  @observable int progressIndicator = 0;
  @observable bool isFullscreen = false;
  
  //referenced elements
  ElementList<VideoStream> videoStreamList;

  @observable
  VideoPlayer.created() : super.created() { }
  
  @override
  void attached() {
    videoStreamList = this.querySelectorAll("video-stream");
    
    this.querySelector("video-stream:last-child").setAttribute("flex", "");
    
    videoStreamList.forEach(
        (stream) => stream..resize()
    );
    
    progressIndicator = setProgress.floor();
    isPlaying = autoplay;
    
    new Timer.periodic(const Duration(milliseconds: 500), (timer) {
      progressIndicator = videoStreamList[0].getProgress().floor();
      isPlaying = videoStreamList[0].isPlaying();
    });
  }
  
  //PlayPause
  void isPlayingChanged([Event e]){
    if(isPlaying){
      play();
    }
    else{
      pause();
    }
  }
  
  void play([Event e]){
    videoStreamList.forEach(
        (stream) => stream.play()
    );
    isPlaying = true;
  }
  
  void pause([Event e]){
    videoStreamList.forEach(
        (stream) => stream.pause()
    );
    isPlaying = false;
  }
  
  //Progress
  void setProgressChanged(){
    videoStreamList.forEach(
      (stream) => stream.setProgress(setProgress)
    );
  }
  
  //Speed  
  void speedChanged() {
    videoStreamList.forEach(
      (stream) => stream.setSpeed(speed)
    );
  }
  
  //Volume
  void volumeChanged(){
    videoStreamList.forEach(
      (stream) => stream.setVolume(volume)
    );
  }
  
}

