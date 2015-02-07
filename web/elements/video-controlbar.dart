library videoControlBar;
import 'package:polymer/polymer.dart';
import 'video-thumbnail.dart';
import 'dart:html';

@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  //published attributes
  @published bool isPlaying;
  @published double setProgress;
  @published int progressIndicator;
  @published int duration;
  @published String quality;
  @published double speed;
  @published int volume;
  @published bool isFullscreen;
  @published bool showSubtitles = false;
  @published bool videoHasEnded;
  
  int returnVolume = 50;
  
  //referenced elements
  ElementList<VideoThumbnail> videoThumbnailList;
  
  @observable
  VideoControlBar.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
    showSubtitlesChanged();
  }
  
  //Thumbnails
  void initVideoThumbnailList(ElementList<VideoThumbnail> list){
    videoThumbnailList = list;
    
    double lastThumbnailTime = 0.0;
    double thumbnailTime = 0.0;
    double width = 0.0;
    for (int i=0;i<videoThumbnailList.length;i++){
      if (i+1 < videoThumbnailList.length) {
        thumbnailTime = videoThumbnailList[i+1].getStartTime();
        width = 100*(thumbnailTime-lastThumbnailTime)/duration;
        lastThumbnailTime = videoThumbnailList[i+1].getStartTime();
      } else if (i+1 == videoThumbnailList.length){
        width = 100*(duration-lastThumbnailTime)/duration;
      }
      if (width < 0.5) width = 0.5;
      videoThumbnailList[i].setThumbnailWidth(width);
      videoThumbnailList[i].onClick.listen(handleThumbnailClick);
    }
    
  }
  
  void handleThumbnailClick(MouseEvent e){
    VideoThumbnail thumbnail = e.currentTarget;
    setProgress = thumbnail.getStartTime();
  }
  
  
  //PlayPause
  void togglePlayPause(Event e, var details, Node target){
    isPlaying = !isPlaying;
  }
  
  void updateIcons(){
    if(isPlaying){
      $['playPauseButton'].attributes['icon'] = "av:pause";
      videoHasEnded = false;
    }
    else if(videoHasEnded){
      $['playPauseButton'].attributes['icon'] = "av:replay";
    } else {
      $['playPauseButton'].attributes['icon'] = "av:play-arrow";
    }  
  }
  
  void videoHasEndedChanged(){
    if (!isPlaying) updateIcons();
  }
  
  void isPlayingChanged(){
    updateIcons();
  }
  
  //Speed
  void toggleSpeed(Event e, var details, Node target){
    if(speed == 1.0){
      speed = 1.3;
    }
    else if(speed == 1.3){
      speed = 1.7;
    }
    else if(speed == 1.7){
      speed = 0.7;
    }
    else {
      speed = 1.0;
    }
  }
  
  //Volume
  void toggleMute(Event e, var details, Node target){
    if(volume>0){
      returnVolume = volume;
      volume = 0;
    }
    else{
      volume = returnVolume;
    } 
  }
  
  void volumeChanged(){
    if(volume==0){
      $['volumeButton'].attributes['icon'] = "av:volume-off";
    }
    if(volume>0 && volume<=30){
      $['volumeButton'].attributes['icon'] = "av:volume-mute";
    }
    if(volume>30 && volume<=70){
      $['volumeButton'].attributes['icon'] = "av:volume-down";
    }
    if(volume>70 && volume<=100){
      $['volumeButton'].attributes['icon'] = "av:volume-up";
    }
  }

  //Quality
  void toggleQuality(){
    if(quality == "sd"){
      quality = "hd";
    }
    else {
      quality = "sd";
    }
  }
  
  void qualityChanged(){
    if(quality == "sd"){
      $['qualityButton'].text = "HD";
    }
    if(quality == "hd"){
      $['qualityButton'].text = "SD";
    }
  }

  //Fullscreen
  void toggleFullscreen(){
    isFullscreen = !isFullscreen;
  }
  
  void isFullscreenChanged(){
    if(isFullscreen){
      $['fullscreenButton'].attributes['icon'] = "fullscreen-exit";
    }
    else{
      $['fullscreenButton'].attributes['icon'] = "fullscreen";
    }
  }
  
  //Subtitles
  void toggleSubtitles(){
    showSubtitles = !showSubtitles;
  }
  
  void showSubtitlesChanged(){
    if(showSubtitles){
      $['subtitlesButton'].style.color = "rgba(255, 255, 255, 1.0)";
    }else{
      $['subtitlesButton'].style.color = "rgba(255, 255, 255, 0.3)";
    }
    
  }
  
  String secondsToMinutes(int number){
    int minutes = number ~/ 60;
    int seconds = number % 60;
    String placeholder;
    if(seconds<10){placeholder="0";}else{placeholder="";}
    return '$minutes:$placeholder$seconds';
  }
  
  String doubleToSpeedRepresentation(double speed){
    return speed.toStringAsFixed(1)+'x';
  }
}