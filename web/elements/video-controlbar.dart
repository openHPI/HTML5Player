library videoControlBar;
import 'package:polymer/polymer.dart';
import 'video-player.dart';

@CustomTag('video-controlbar')

class VideoControlBar extends PolymerElement {

  //referenced elements
  VideoPlayer videoPlayer;
  
  @observable
  VideoControlBar.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
    videoPlayer = (this.parentNode).host;
    $['playPauseButton'].onClick.listen(videoPlayer.togglePlayPause);
    $['speedButton'].onClick.listen(videoPlayer.toggleSpeed);
  }
  
  void updatePlayPauseButton(String iconPath){
    $['playPauseButton'].attributes['icon'] = iconPath;
  }
  
  void updateSpeedButton(String d){
    $['speedButton'].setInnerHtml(d);
  }
}