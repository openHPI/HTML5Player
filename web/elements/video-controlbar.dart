library videoControlBar;
import 'package:polymer/polymer.dart';
import 'video-player.dart';
import 'dart:html';
import 'dart:math';

@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

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
    $['progress'].onClick.listen(videoPlayer.toggleCurrentTime);
  }
  
  void updatePlayPauseButton(String iconPath){
    $['playPauseButton'].attributes['icon'] = iconPath;
  }
  
  void updateProgress(int currentTime, int duration){
    $['currentTime'].setInnerHtml(secondsToMinutes(currentTime));
    double percentage = min( ((currentTime / duration) * 100), 100 );
    $['slider'].style.width="$percentage%";
  }
  
  void updateDuration(int duration){
    $['durationTime'].setInnerHtml(secondsToMinutes(duration));
  }
  
  void updateSpeedButton(String speed){
    $['speedButton'].setInnerHtml(speed);
  }
  
  double getProgressBarWidth(){
    Element e = $['progress'];
    return double.parse(e.getComputedStyle().width.replaceFirst(new RegExp(r'px'), ''));
  }
  
  String secondsToMinutes(int number){
    int minutes = number ~/ 60;
    int seconds = number % 60;
    String placeholder;
    if(seconds<10){placeholder="0";}else{placeholder="";}
    return '$minutes:$placeholder$seconds';
  }
}