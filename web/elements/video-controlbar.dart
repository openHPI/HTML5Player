library videoControlBar;
import 'package:polymer/polymer.dart';
import 'video-player.dart';
import 'dart:html';

@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  //published attributes
  @published int duration = 1;
  @published int progress = 0;
  @published int volume;
  @published double speed;
  
  //referenced elements
  VideoPlayer videoPlayer;
  
  @observable
  VideoControlBar.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
    videoPlayer = (this.parentNode as ShadowRoot).host;
    $['playPauseButton'].onClick.listen(videoPlayer.togglePlayPause);
    $['speedButton'].onClick.listen(videoPlayer.toggleSpeed);
    $['progressBar'].on['sliderMoved'].listen(videoPlayer.setCurrentTime);
  }
  
  void updatePlayPauseButton(String iconPath){
    $['playPauseButton'].attributes['icon'] = iconPath;
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