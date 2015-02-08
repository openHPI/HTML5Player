library sliderBar;
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'package:paper_elements/paper_progress.dart';

@CustomTag('slider-bar')

class SliderBar extends PolymerElement{
  
  //published attributes
  @published int max = 1;
  @published int value = 0;
  @published int secondValue = 0;
  @published String bubbleText = null;
  
  //referenced elements
  PaperProgress paperProgress;

  var mouseMoveListener;
  var mouseUpListener;
  
  @observable
  SliderBar.created() : super.created() { }
  
  @override
  void attached() {
    super.attached();
    paperProgress = this.shadowRoot.querySelector('paper-progress');
  }
  
  void initDrag(Event e, var details, Node target){
    MouseEvent m = (e as MouseEvent);
    value = (paperProgress.max * (m.offset.x / getPaperProgressWidth())).floor();
    if(mouseMoveListener != null) stopDrag();
    mouseUpListener = window.onMouseUp.listen(stopDrag);
    mouseMoveListener = $['paperProgress'].onMouseMove.listen(doDrag);
  }
  
  doDrag([MouseEvent e]){
    value = (paperProgress.max * (e.offset.x / getPaperProgressWidth())).floor();
    if(bubbleText != null)
      $['valueBubble'].style
        ..left = e.offset.x.toString()+"px"
        ..visibility = "visible";
    //$['bubbleText'].text = value;
  }
  
  stopDrag([MouseEvent e]){
    $['valueBubble'].style.visibility = "hidden";
    mouseMoveListener.cancel();
    mouseMoveListener = null;
    mouseUpListener.cancel();
    mouseUpListener = null;
  }
  
  double getPaperProgressWidth(){
    return double.parse(paperProgress.getComputedStyle().width.replaceFirst('px', ''));
  }
}