library videoPlayer;
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_icon.dart';
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
  @published bool showSubtitles = false;
  
  @observable bool isPlaying = false;
  @observable int progressIndicator = 0;
  @observable bool isFullscreen = false;
  
  bool canTogglePlayPause;
  double startX;
  double startWidth;
  var mouseMoveListener;
  var mouseUpListener;
  
  //referenced elements
  ElementList<VideoStream> videoStreamList;

  @observable
  VideoPlayer.created() : super.created() { }
  
  @override
  void attached() {
    videoStreamList = this.querySelectorAll("video-stream");
    
    this.querySelector("video-stream:last-child").setAttribute("flex", "");
    
    progressIndicator = setProgress.floor();
    isPlaying = autoplay;

    for(int i=0; i<videoStreamList.length-1; i++){
      CoreIcon resizer = new Element.tag('core-icon');
      resizer.id = "resizer";
      resizer.icon = "polymer";
      resizer.onMouseDown.listen((MouseEvent e) => initDrag(e, i));
      this.insertBefore(resizer, videoStreamList[i].nextNode);
    }
    
    videoStreamList.forEach((stream) => stream.resize(videoStreamList.length));
    
    new Timer.periodic(const Duration(milliseconds: 500), (timer) {
      progressIndicator = videoStreamList[0].getProgress().floor();
      isPlaying = videoStreamList[0].isPlaying();
      canTogglePlayPause = true;
    });
  }
  
  void togglePlayPause(Event e, var details, Node target){
    if (canTogglePlayPause)
      isPlaying = !isPlaying;
  }
  
  void initDrag([MouseEvent e, int scopeVideo]){
    window.console.log(e);
    startX = e.client.x;
    startWidth = double.parse( videoStreamList[scopeVideo].getComputedStyle().width.replaceAll('px', '') );
    mouseUpListener = window.onMouseUp.listen(stopDrag);
    mouseMoveListener = window.onMouseMove.listen(doDrag);
  }
  
  void doDrag([MouseEvent e]){
    videoStreamList[0].style.width = (startWidth + e.client.x - startX).toString() + "px";
    videoStreamList.forEach((stream) => stream.resize(videoStreamList.length));
  }
  
  void stopDrag([MouseEvent e]){
    mouseMoveListener.cancel();
    mouseUpListener.cancel();
    
    // dragging shouldnt trigger a togglePlayPause
    canTogglePlayPause = false;
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
  
  // Quality
  void qualityChanged(){
    if(quality == "sd"){
      videoStreamList.forEach(
            (stream) => stream.setSD()
      );
    }
    else {
      videoStreamList.forEach(
        (stream) => stream.setHD()
      );
    }
  }
  
  //Subtitles
  void showSubtitlesChanged(){
    if(showSubtitles){
      videoStreamList.forEach(
        (stream) => stream.showSubtitles()
      );
    }
    else {
      videoStreamList.forEach(
        (stream) => stream.hideSubtitles()
      );
    }
  }
  
}

