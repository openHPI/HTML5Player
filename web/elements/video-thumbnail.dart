library videoThumbnail;
import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('video-thumbnail')

class VideoThumbnail extends PolymerElement{
  
  //published attributes
  @published String img_src; 
  @published String starttime;
  
  //referenced elements
  DivElement thumb;
  
  @observable
  VideoThumbnail.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
    thumb = this.shadowRoot.querySelector('.thumb');
    this.onMouseOver.listen(setThumbnailVisible);
    this.onMouseLeave.listen(setThumbnailInvisible);
  }
  
  double getStartTime(){
    return double.parse(starttime);
  }
  
  void setThumbnailWidth(double width){
    this.style.width=(width).toString()+"%";
  }
  
  void setThumbnailVisible(Event e){
    thumb.style.visibility = "visible";
  }

  void setThumbnailInvisible(Event e){
    thumb.style.visibility = "hidden";
  }
  
}