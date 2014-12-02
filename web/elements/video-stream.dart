import 'package:polymer/polymer.dart';

/**
 * A Polymer element.
 */
@CustomTag('video-stream')
class VideoStream extends PolymerElement {
  @published String sd_src;
  @published String hd_src;
  @published String poster;
  @published String ratio;
  @published String speed;

  @observable
  VideoStream.created() : super.created() {
  }
  
  void resize() {
    double width = double.parse( this.getComputedStyle().width.replaceAll('px', '') );
    double newHeight = width * ratioAsDouble(ratio);
    this.style.height = newHeight.toString() + "px";
  }
  
  void speedChanged() {
    this.shadowRoot.querySelector("video").playbackRate = speed;
  }
  
  double ratioAsDouble(String ratio){
    if(ratio == "4:3"){
      return 3/4;
    }
    else if(ratio == "16:9"){
      return 9/16;
    }
    else{
      // default ratio = 16:9
      return 9/16;
    }
  }
  
  void test(){
    alert("asd");
  }
  
}
