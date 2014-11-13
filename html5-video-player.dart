library html5videoplayer;

import 'package:polymer/polymer.dart';

@CustomTag('html5-video-player')
class Html5VideoPlayer extends PolymerElement {
  //@published VideoElement video;
  //@observable bool enableMore = false;
  
  //static EventStreamProvider<Event> itemOpenedEvent = new EventStreamProvider('open-item');
  
  Html5VideoPlayer.created() : super.created();
  
  @override
  attached() {
    super.attached();

  }
  
}