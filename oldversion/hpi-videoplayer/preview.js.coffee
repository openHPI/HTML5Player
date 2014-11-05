###
    This class handles all the actions and events for video previews.
    If one ranges end, it will jump to the next.
###
window.Html5Player or= {};

class window.Html5Player.Preview

  constructor : ( player, $baseElement, previewRanges ) ->
    @player                     = player
    @$seeker                    = $baseElement.find('.progress')
    @previewRanges              = previewRanges
    @currentPreviewRangeIndex   = -1

  show : ->
    # stop custom preview is necessary
    if @player.hasCustomPreview
      @player.customPreview.stop() 
    @addPreviewRange  range for range in @previewRanges
    @player.previewShown = true
    @start()

  addPreviewRange : ( previewRange ) ->
    offset = ( previewRange.start / @player.videoA.duration ) * 100
    width = ( ( previewRange.end - previewRange.start ) / @player.videoA.duration ) * 100
    @$seeker.prepend $('<div class="previewRange" style="left:' + offset + '%; width:' + width + '%;"></div>')

  stop : ->
    @$seeker.find('.previewRange').remove()
    @currentPreviewRangeIndex = -1
    @player.pause()
    @player.previewShown = false

  update : ->
    if @player.currentTime() > @previewRanges[@currentPreviewRangeIndex].end
      @jumpToNextPreview()

  start : ->
    @currentPreviewRangeIndex = 0
    @player.gototime @previewRanges[@currentPreviewRangeIndex].start
    @player.play

  jumpToNextPreview : ->
    unless @currentPreviewRangeIndex is @previewRanges.length - 1
      @currentPreviewRangeIndex++
      @player.gototime @previewRanges[@currentPreviewRangeIndex].start
    else
      @player.controls.$previewButton.click()

  seekTimeInPreviewRange : ( time ) ->
    for range, i in @previewRanges
      if range.start <= time <= range.end
        @currentPreviewRangeIndex = i
        return true
    return false