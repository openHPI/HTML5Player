###
    This class handles all the actions and events for cue points of clicked tags.
    When one clicks on a cue point, the player will jump to the according position.
###
window.Html5Player or= {};

class window.Html5Player.CuePoints

  constructor : ( player, $baseElement ) ->
    @player   = player
    @$seeker  = $baseElement.find('.progress')

  updateCuePoints : ( cuePoints ) ->
    @removeCuePoints()
    @showCuePoints(cuePoints)

  showCuePoints : ( cuePoints ) ->
    @addCuePoint cuePoint for cuePoint in cuePoints

  removeCuePoints : ->
    @$seeker.find('.cuePoint').remove()

  addCuePoint : ( cuePointTime ) ->
    offset = Math.ceil( ( cuePointTime / @player.videoA.duration ) * 100 )
    # 7 = half of the width of the cue point circle
    diff = Math.ceil( ( 7 / @$seeker.width() ) * 100 )
    offset -= diff
    cuePoint = $('<div class="cuePoint" data-seconds=' + cuePointTime + ' style="left:' + offset + '%;"></div>').prependTo(@$seeker)
    cuePoint.on 'click', (event) =>
      event.preventDefault()
      event.stopPropagation()
      @player.gototime(cuePointTime)