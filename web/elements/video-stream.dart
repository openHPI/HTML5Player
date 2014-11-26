import 'package:polymer/polymer.dart';

/**
 * A Polymer element.
 */
@CustomTag('video-stream')
class VideoStream extends PolymerElement {
  @published String sd_src;
  @published String hd_src;
  @published String poster;
  @published String ratio = "4:3";

  @observable
  VideoStream.created() : super.created() {
  }
  
  
  double ratioToDouble(String ratio){
    if(ratio == "4:3"){
      return 4/3;
    }
    else if(ratio == "16:9"){
      return 16/9;
    }
    else{
      return 1.0;
    }
    
  }
  
}

