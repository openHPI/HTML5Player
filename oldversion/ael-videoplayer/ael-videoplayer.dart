library ael.videoplayer;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:js';
import 'dart:convert';
import 'dart:math';
import 'dart:collection';

@CustomTag('ael-videoplayer')
class AelVideoplayer extends PolymerElement {
  
  @published bool wasPlayed = false;
  
  @observable Map video;
  DivElement videoPlayerElement;
  JsObject videoPlayer;
  
  AelVideoplayer.created() : super.created();
  
  @override
  attached() {
    super.attached();
    videoPlayerElement = $['televideoplayer'];
  }
  
  /* ======================== VIDEOPLAYER handling ================== */

  void videoChanged() {
    String captionsBlobUrl = Url.createObjectUrl(new Blob([video['captions']]));
    sortVideoData();
    List<Map<String,int>> previewRanges = generatePreview(video['cuepoints']);
    Map data = new Map();
    //only mixed video formats are found
    if (video['audioFormats'].isEmpty && video['videoFormats'].isEmpty && video['mixedFormats'].isNotEmpty){
      data = {
                "streams":
                  {
                    "right":
                      {
                        "url": video['mixedFormats'].last['url'],
                        "poster": video['thumbnail'],
                        "width": 1920,
                        "height": 1080
                      }
                  },
                  "captions": captionsBlobUrl,
                  "handleKeyboardEvents": false,
                  "previewRanges": previewRanges,
                  "taggingActive": true,
                  "initialVideoWidth": video['initialVideoWidth'],
                  "hasLoadingOverlay": true,
                  "format": "webm",
                  "hasCustomPreview": true,
      };
    // mixed formats are found
    } else if (video['audioFormats'].isNotEmpty && video['videoFormats'].isNotEmpty){
      data = {
                "streams":
                  {
                    "right":
                      {
                        "poster": video['thumbnail'],
                        "width": 1920,
                        "height": 1080,
                        "audio": video['audioFormats'],
                        "video": video['videoFormats']
                      }
                  },
                  "captions": captionsBlobUrl,
                  "handleKeyboardEvents": false,
                  "previewRanges": previewRanges,
                  "taggingActive": true,
                  "initialVideoWidth": video['initialVideoWidth'],
                  "hasLoadingOverlay": true,
                  "format": "webm",
                  "hasCustomPreview": true,
      };
    } else if (video['mixedFormats'].isNotEmpty){
      // fallback solution
      data = {
        "streams":
          {
            "right":
              {
                "url": video['mixedFormats'].last['url'],
                "poster": video['thumbnail'],
                "width": 1920,
                "height": 1080
              }
          },
          "captions": captionsBlobUrl,
          "handleKeyboardEvents": false,
          "previewRanges": previewRanges,
          "taggingActive": true,
          "initialVideoWidth": video['initialVideoWidth'],
          "hasLoadingOverlay": true,
          "format": "webm",
          "hasCustomPreview": true,
      };

    }
    videoPlayerElement.dataset['videodata'] = JSON.encode(data);
    videoPlayer = new JsObject(context['Html5Player']['VideoPlayer'],[context.callMethod('\$',[videoPlayerElement]),new JsObject.jsify(data)]);
    updateMostWatched();
    
    // register listener for history update
    VideoElement videoEl = videoPlayerElement.querySelector('video');
    videoEl.onPlay.listen((Event e) => wasPlayed = true);
  }
  
  void sortVideoData(){
    List<Map> audioFormats = new List();
    List<Map> videoFormats = new List();
    List<Map> mixedFormats = new List();
    for (Map<String,String> format in video['content']) {
      String formatLabel = format['label'];
      if (format['label'].contains('(')){
        format['label'] = format['label'].substring(0,format['label'].indexOf('(')); // remove e.g. '(no audio)'
      }
      format['label'] = format['label']
        .replaceAll(new RegExp(r'WebM'), '')
        .trim();
      Map item = {
                   'url': format['url'],
                   'label': format['label'],
                   'format': format['format']
                 };
      if (formatLabel.contains('only audio')) {
        audioFormats.add(item);
      } else if (formatLabel.contains('no audio')) {
        videoFormats.add(item);
      } else {
        mixedFormats.add(item);
      }
    }
    video['audioFormats'] = audioFormats;
    video['videoFormats'] = videoFormats;
    video['mixedFormats'] = mixedFormats;
  }

  List<Map<String,int>> generatePreview(cuepoints){
    if(cuepoints.isEmpty){
      return [];
    }

    SplayTreeSet<int> seconds = new SplayTreeSet();
    for (Map<String,dynamic> cuepoint in cuepoints.sublist(0,5)) {
      seconds.addAll(cuepoint['cuepoints']);
    }
    List<Map<String,int>> previewRanges = new List();
    int max= -1;
    for (int second in seconds) {
      int start = second - 5;
      int end   = second + 5;
      if (start < 0){
        start = 0;
      } 
      if (start > max){
        previewRanges.add({
          'start': start,
          'end':   end,
        });
      } else {
        previewRanges.last['end'] = end;
      }
      max = end;
    }
    return previewRanges;
  }
  
  void stopVideo(){
    if (videoPlayer != null) {
      videoPlayer.callMethod('pause', []);
    }
    window.location.hash="";
  }
  
  void updateCuePoints(List cuePoints){
    videoPlayer.callMethod('updateCuePoints', [new JsObject.jsify(cuePoints)]);
  }
  
  void updateMostWatched(){ //TODO replace with data from database!!!
    VideoElement video = videoPlayer['videoA'];
    video.onLoadedMetadata.listen(onLoadedVideoMetadata);
  }
  
  void onLoadedVideoMetadata(Event e){
    VideoElement video = e.currentTarget as VideoElement;
    // mock 3 most watched sections
    List sections = new List<Map>();
    int sectionSize = (video.duration/3).ceil();
    var random = new Random();
    for (var i = 0; i <= 2; i++) {
      int offset = sectionSize * i;
      int halfSection = (sectionSize/2).ceil();
      int start = random.nextInt(halfSection) + offset;
      int end = random.nextInt(halfSection) + halfSection + offset;
      sections.add({'start': start, 'end': end});
    }
    videoPlayer.callMethod('updateMostWatched', [new JsObject.jsify(sections)]);
  }
  
  void resize(){
    videoPlayer['ui'].callMethod('resizePlayer', [true]);
  }
  
  void resizeHard(double width){
    videoPlayer['ui'].callMethod('resizeSingleStreamPlayerHard', [width]);
  }
  
  void activateMiniMode(){
    if (videoPlayer == null){
      return;
    }
    videoPlayer['controls'].callMethod('activateMiniMode');
  }

  void deactivateMiniMode(){
    if (videoPlayer == null){
      return;
    }
    videoPlayer['controls'].callMethod('deactivateMiniMode');
  }
  
  List<Map<String, double>> flushHistory(){
    List<Map<String, double>> mostWatchedSections = new List();
    JsArray<Map> mostWatchedSectionsJs = videoPlayer['history'].callMethod('flush');
    if (mostWatchedSectionsJs != null) {
      mostWatchedSections = mostWatchedSectionsJs.toList();
    }
    return mostWatchedSections;
  }
  
  bool isLoading(){
    bool isInitiated = videoPlayer['playerInitiated'];
    return !isInitiated;
  }
  
  void clearTaggedSection(){
    videoPlayer['tagging'].callMethod('remove');
  }
  
  void startCustomPreview(int start, int end){
    videoPlayer.callMethod('startCustomPreview', [start, end]);
  } 
  
}


// original xikolo code for initialization
/*
.televideoplayer data-videodata=videodata
javascript:
  new Html5Player.VideoPlayer( $('.televideoplayer'), $('.televideoplayer').data('videodata') );
*/