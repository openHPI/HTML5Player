library videoThumbnail;
import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('video-thumbnail')

class VideoThumbnail extends PolymerElement{
  
  //published attributes
  @published String img_src; 
  @published String starttime;
  
  //referenced elements
  ImageElement img;
  
  @observable
  VideoThumbnail.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
    img = this.shadowRoot.querySelector('img');
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
    img.style.visibility = "visible";
  }

  void setThumbnailInvisible(Event e){
    img.style.visibility = "hidden";
  }
  
}