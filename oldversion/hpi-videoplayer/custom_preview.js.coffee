###
    This class handles all the actions and events for a custom video preview.
    This is used for tagged comments.
###
window.Html5Player or= {};

class window.Html5Player.CustomPreview

  constructor : ( player, $baseElement ) ->
    @player    = player
    @$seeker   = $baseElement.find('.progress')
    @startTime = -1
    @endTime   = -1

  show : ( startTime , endTime )->
    @startTime = startTime
    @endTime = endTime
    # stop normal preview is necessary
    if @player.hasPreview
      @player.preview.stop() 
    @player.customPreviewIsShown = true
    @addPreviewRange( startTime , endTime )
    @start()

  addPreviewRange : ( startTime , endTime ) ->
    offset = ( startTime / @player.videoA.duration ) * 100
    width = ( ( endTime - startTime ) / @player.videoA.duration ) * 100
    @$seeker.prepend $('<div class="previewRange" style="left:' + offset + '%; width:' + width + '%;"></div>')

  stop : ->
    @$seeker.find('.previewRange').remove()
    @player.pause()
    @player.customPreviewIsShown = false

  update : ->
    if @player.currentTime() > @endTime
      @stop()

  start : ->
    @player.gototime(@startTime)
    @player.play

  seekTimeInPreviewRange : ( time ) ->
    if @startTime <= time <= @endTime
      return true
    return false