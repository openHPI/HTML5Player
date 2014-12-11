library HTML5Player.video_player;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_fab.dart';
import 'package:paper_elements/paper_slider.dart';
import 'package:core_elements/core_splitter.dart';

@CustomTag('html5-video-player')
class Html5VideoPlayer extends PolymerElement {
  @published Map streams;
  
  DivElement container;
  DivElement knob;
  
  VideoElement leftVideo;
  VideoElement rightVideo;
  
  @observable Map leftStream;
  @observable Map rightStream;
  
  PaperFab menu;
  PaperSlider progress;
  CoreSplitter splitter;
  
  @observable String state;
  @observable int duration;
  @observable int currentTime = 0;
  @observable int buffered = 0;
  @observable String menuIcon = 'av:play-arrow';
  
  @observable bool isDual = false;
  bool isSeeking = false;
  
  //static EventStreamProvider<Event> itemOpenedEvent = new EventStreamProvider('open-item');
  
  Html5VideoPlayer.created() : super.created();
  
  @override
  attached() {
    super.attached();
    container   = $['container'];
    leftVideo   = $['leftVideo'];
    rightVideo  = $['rightVideo'];
    menu        = $['menu'];
    progress    = $['progress'];
    knob        = progress.$['sliderKnob'];
    splitter    = $['splitter'];
    state        = 'paused';
    
    registerEventHandlers();
  }
  
  void registerEventHandlers(){
    leftVideo.onTimeUpdate.listen((e) =>  handleTimeUpdate());
    leftVideo.onCanPlay.listen((e) =>  handleCanPlay());
    leftVideo.onEnded.listen((e) =>  handleEnded());
    leftVideo.onPause.listen((e) =>  handlePause());
  }
  
  void handleCanPlay(){
    duration = leftVideo.duration.ceil();
  }
  
  void handleTimeUpdate(){
    if (!isSeeking){
      currentTime = leftVideo.currentTime.ceil();
      buffered = leftVideo.buffered.end(leftVideo.buffered.length-1).ceil();
    }
  }
  
  void handleEnded(){
    state = 'ended';
    menuIcon = 'av:replay';
  }
  
  void handlePause(){

  }
  
  void startSeeking(){
    isSeeking = true;
    knob.hidden = false;
    currentTime = progress.value;
    pause();
  }
  
  void stopSeeking(){
    isSeeking = false;
    goToTime(progress.immediateValue);
  }
  
  void streamsChanged(){
    if (streams['left'] != null && streams['right'] != null){
      leftStream = streams['left'];
      rightStream = streams['right'];
      isDual = true;
    } else if (streams['left'] != null){
      leftStream = streams['left'];
      isDual = false;
      rightVideo.hidden = true;
      splitter.hidden = true;
    }
  }
  
  void goToTime(int time){
    if (time >= leftVideo.duration){
      time = leftVideo.duration.ceil();
      handleEnded();
    } else {
      leftVideo.currentTime = time;
      if ( rightStream != null){
        rightVideo.currentTime = time;
      }
      currentTime = time;
      play();
    }
  }
  
  void play(){
    leftVideo.play();
    if ( rightStream != null){
      rightVideo.play();
    }
    state = 'playing';
    menuIcon = 'av:pause';
    knob.hidden = true;
  }
  
  void pause(){
    leftVideo.pause();
    if ( rightStream != null){
      rightVideo.pause();
    }
    state = 'paused';
    menuIcon = 'av:play-arrow';
  }
  
  void replay(){
    goToTime(0);
  }
  
  void togglePlay(_){
    switch (state){
      case 'playing':
        pause();
        break;
      case 'paused':
        play();
        break;
      case 'ended':
        replay();
        break;
    }
  }
  
  void showMenu(){
    menu.classes.add('shown');
  }
  
  void hideMenu(){
    menu.classes.remove('shown');
  }
  
  void showKnob(){
    knob.hidden = false;
  }
  
  void hideKnob(){
    if (!leftVideo.paused && leftVideo.currentTime != 0.0){
      knob.hidden = true;
    }
  }
  
}