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
    document.onFullscreenChange.listen(handleFullscreenChanged);
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
    mouseUpListener = document.onMouseUp.listen(stopDrag);
    mouseMoveListener = document.onMouseMove.listen(doDrag);
  }
  
  void doDrag([MouseEvent e]){
    double controlbarHeight = 48.0;
    
    if (double.parse(videoStreamList[0].style.width.replaceAll('px', '')) < (startWidth + e.client.x - startX)){
      window.console.log("ziehe nach rechts");
      if ((double.parse(videoStreamList[0].style.height.replaceAll('px', '')) <= (double.parse(videoStreamList[1].style.height.replaceAll('px', '')))) && 
              (document.documentElement.clientHeight <= double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight ) || 
              (document.documentElement.clientHeight > double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight )) {
            videoStreamList[0].style.width = (startWidth + e.client.x - startX).toString() + "px";
      }
      videoStreamList.first.resize(videoStreamList.length);
      videoStreamList.last.resize(videoStreamList.length);
    }
    else if (double.parse(videoStreamList[0].style.width.replaceAll('px', '')) > (startWidth + e.client.x - startX)) {
      window.console.log("ziehe nach links");
      if ((double.parse(videoStreamList[0].style.height.replaceAll('px', '')) >= (double.parse(videoStreamList[1].style.height.replaceAll('px', '')))) && 
              (document.documentElement.clientHeight <= double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight ) || 
              (document.documentElement.clientHeight > double.parse( this.getComputedStyle().height.replaceAll('px', ''))+controlbarHeight )) {
            videoStreamList[0].style.width = (startWidth + e.client.x - startX).toString() + "px";
      }
      videoStreamList.last.resize(videoStreamList.length);
      videoStreamList.first.resize(videoStreamList.length);
    }
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
  
  // Fullscreen
  void toggleFullscreen(Event e, var details, Node target){
      isFullscreen = !isFullscreen;
  }
  
  void isFullscreenChanged(){
    if(isFullscreen){
      this.requestFullscreen();
    }else{
      document.exitFullscreen();      
    }
  }
  
  void handleFullscreenChanged(Event e){
    //updates the video size
    if (document.fullscreenElement==null)
      isFullscreen=false;
    else isFullscreen=true;
    videoStreamList[0].style.width = (double.parse( this.getComputedStyle().width.replaceAll('px', '')) / 2).toString() + "px";
    videoStreamList.forEach((stream) => stream.resize(videoStreamList.length));
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

