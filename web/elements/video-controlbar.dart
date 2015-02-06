library videoControlBar;
import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  //published attributes
  @published bool isPlaying = false;
  @published int progress;
  @published int buffered;
  @published int duration;
  @published bool isHD;
  @published double speed;
  @published int volume;
  @published bool isFullscreen;
  
  @published bool showSubtitles = false;
  
  
  int returnVolume = 50;
  
  @observable
  VideoControlBar.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
    showSubtitlesChanged();
  }
  
  //PlayPause
  void togglePlayPause([Event e, var details, Node target]){
    isPlaying = !isPlaying;
  }
  
  void isPlayingChanged(){
    if(isPlaying){
      $['playPauseButton'].attributes['icon'] = "av:pause";
    }
    else{
      $['playPauseButton'].attributes['icon'] = "av:play-arrow";
    }
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
    isHD = !isHD;
  }
  
  void isHDChanged(){
    if(isHD){
      $['qualityButton'].text = "HD";
    }
    else{
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