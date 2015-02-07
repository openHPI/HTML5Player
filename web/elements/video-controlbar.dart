library videoControlBar;
import 'package:polymer/polymer.dart';
import 'video-thumbnail.dart';
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
    
    //set ThumbnailWidth and add Eventlistener
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
    
    if (videoThumbnailList.length > 0) {
      this.shadowRoot.querySelector("#progressBar").setAttribute("id", "progressBarWithThumbnails");
    }
  }
  
  void handleThumbnailClick(MouseEvent e){
    VideoThumbnail thumbnail = e.currentTarget;
    progress = thumbnail.getStartTime().floor();
  }
  
  
  //PlayPause
  void togglePlayPause([Event e, var details, Node target]){
    isPlaying = !isPlaying;
  }
  
  void updateIcons(){
    if(isPlaying){
      $['playPauseButton'].attributes['icon'] = "av:pause";
    }
    else{
      $['playPauseButton'].attributes['icon'] = "av:play-arrow";
      if(duration - progress < 1){
        $['playPauseButton'].attributes['icon'] = "av:replay";
      }
    }
  }
  

void isPlayingChanged(){
    updateIcons();
  }
  
  void progressChanged(){
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