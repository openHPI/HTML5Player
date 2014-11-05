###
    This class handles the overlay for the tags/keywords for a video.
    Tagging means that the user can right-click in the timeline and hold the mouse.
    When he releases the mouse the created range (a preview is shown in the timeline)
    will be used as additional information for a comment on the video (start and end time).
    It will fire an event when the users finishes the action.
###
window.Html5Player or= {};

class window.Html5Player.Tagging

  constructor : ( player, $baseElement ) ->
    @player   = player
    @$seeker  = $baseElement.find('.progress')
    @startTime = -1
    @endTime = -1
    @startPosition = -1
    @endPosition = -1

    @addPreview()

  update: ( endPosition ) ->
    @endPosition = endPosition
    diff = @endPosition - @startPosition
    if diff < 0
      @$seeker.find('.taggingPreview').css({
        'left': ( @endPosition * 100) + '%',
        'width': ( -diff * 100 ) + '%'
      })
    else
      @$seeker.find('.taggingPreview').css({
        'width': (diff * 100) + '%'
      })

  start: ( startPosition ) ->
    @startPosition = startPosition
    @$seeker.find('.taggingPreview')
      .css({
        'left': ( startPosition * 100) + '%',
        'width': '0%'
      })
      .show()

  stop: ->
    if @endPosition < @startPosition
      @startTime = Math.floor(@endPosition * @player.videoA.duration)
      @endTime = Math.floor(@startPosition * @player.videoA.duration)
    else
      @startTime = Math.floor(@startPosition * @player.videoA.duration)
      @endTime = Math.floor(@endPosition * @player.videoA.duration)
    event = new CustomEvent( "newTag", {
      "detail": {
        "startTime":  @startTime,
        "endTime":    @endTime,
        "totalTime":  @endTime - @startTime,
        "time":       new Date()
      },
      "bubbles": true,
      "cancelable": true
    })
    document.dispatchEvent(event)
    return

  remove : ->
    @$seeker.find('.taggingPreview')
      .hide()
      .css({
        'left': '0%',
        'width': '0%'
      })

  addPreview : ->
    @$seeker.prepend $('<div class="taggingPreview" style="left:0%; width:0%; display:none;"></div>')