###
    This class is in charge of the user interface. It handles:
    - resizing bar between videos
    - toggle fullscreen mode
###
window.Html5Player or= {};

class window.Html5Player.UserInterface

  $videoPlayer: null
  lastPageX: 0

  player: null
  videoA: null
  videoB: null

  fullscreenPlayerWidth: 0

  playerWidth: 0
  controlsHeight: 0
  aRatio: 16/9
  bRatio: 4/3
  splitRatio: [0.5, 0.5]
  minVideoWidth: 0.2

  constructor: (player, $baseElement) ->
    @player = player
    @videoA = $(player.videoA)
    @videoB = $(player.videoB)

    @isSingle = player.isSingle

    @$videoPlayer = $baseElement.find(".videoPlayer")
    if device.ios()
      @$videoPlayer.find('.mute').remove()
      @$videoPlayer.find('.volumebar').remove()
      @$videoPlayer.find('.fullscreen').css('border-right', 'none')
    #@$videoPlayer.find('.fullscreen').remove()
    @$chapterContent = $baseElement.find(".chapterContent")

    @playerWidth = @$videoPlayer.outerWidth()
    @controlsHeight = @$videoPlayer.find('.controlsContainer').outerHeight()

    # event handlers for mouse dragging of resize slider
    @$videoPlayer.find(".resizer").mousedown (event) =>
      event.preventDefault()
      @lastPageX = event.pageX

      @$videoPlayer.mousemove (event) =>
        @resizeVideo(event)

    $(window).mouseup (event) =>
      event.preventDefault()
      @$videoPlayer.off 'mousemove'

    $(window).resize (event) =>
      @resizePlayer(true)

    $(window).load (event) =>
      @resizePlayer(true)

    $(document).ready () =>
      @resizePlayer(true)

    @originalWidth = @$videoPlayer.width()
    @originalHeight = @$videoPlayer.height()

    @ratioA = @videoA.width() / @originalWidth
    @ratioB = @videoB.width() / @originalWidth

    @resizePlayer(true)
    # for better rendering
    @$videoPlayer.width('100%')

  toggleFullscreen: ->
    if screenfull.isFullscreen
      screenfull.exit()
      return

    screenfull.onchange = @fullscreenOnchange
    if(screenfull.enabled)
      screenfull.request @$videoPlayer[0]
    else
      video = @$videoPlayer.find('video')
      $(video).attr('controls', 'controls')
  #window.alert('Your browser does not support fullscreen mode.')


  fullscreenOnchange: =>
    @fullscreenPlayerWidth = @playerWidth
    @checkFullscreenChange()
    $(window).trigger("toggleFullscreen")
    if !(document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen || document.msFullscreenElement?)
      @$videoPlayer.find('.fullscreen.button > i').removeClass('icon-fullscreen-off').addClass('icon-fullscreen-on')

  resizePlayer: (byDataOnly) ->
    if @isSingle
      @resizeSingleStreamPlayer(byDataOnly)
    else
      @resizeDualStreamPlayer(byDataOnly)

  resizeSingleStreamPlayer: (byDataOnly) ->
    @playerWidth = @$videoPlayer.outerWidth()
    if (byDataOnly)
      orgRatio = @$videoPlayer.find('video').data('height') / @$videoPlayer.find('video').data('width')
      h = @playerWidth * orgRatio
      @$videoPlayer.find('.a').width(@playerWidth)
      @$videoPlayer.find('.a').height(h)
      playerHeight = h + @controlsHeight
      @$videoPlayer.height(playerHeight) if playerHeight > 0
    else
      aWidth = @playerWidth
      aHeight = aWidth * @aRatio
      playerHeight = aHeight + @controlsHeight
      @$videoPlayer.find('.a').width(aWidth) if aWidth > 0
      @$videoPlayer.find('.a').height(aHeight) if aHeight > 0
      @$videoPlayer.height(playerHeight) if playerHeight > 0

  resizeDualStreamPlayer: (byDataOnly) ->
    if byDataOnly
      @playerWidth = @$videoPlayer.outerWidth()
      aWidth = @playerWidth * @splitRatio[0]
      bWidth = @playerWidth * @splitRatio[1]
      aRatio = @$videoPlayer.find('.video.a > video').data('height') / @$videoPlayer.find('.video.a > video').data('width')
      bRatio = @$videoPlayer.find('.video.b > video').data('height') / @$videoPlayer.find('.video.b > video').data('width')

      aHeight = aWidth * aRatio
      bHeight = bWidth * bRatio
      playerHeight = Math.max(aHeight, bHeight) + @controlsHeight

      @$videoPlayer.find('.a').width(aWidth)
      @$videoPlayer.find('.a').height(aHeight)
      @$videoPlayer.find('.b').width(bWidth)
      @$videoPlayer.find('.b').height(bHeight)
      @$videoPlayer.height(playerHeight)
      @$videoPlayer.find('.resizer').css({top: Math.round(playerHeight / 3), left: aWidth})

    else
      @playerWidth = @$videoPlayer.outerWidth()
      aWidth = @playerWidth * @splitRatio[0]
      bWidth = @playerWidth * @splitRatio[1]
      aHeight = aWidth * @aRatio
      bHeight = bWidth * @bRatio
      playerHeight = Math.max(aHeight, bHeight) + @controlsHeight

      @$videoPlayer.find('.a').width(aWidth)
      @$videoPlayer.find('.a').height(aHeight)
      @$videoPlayer.find('.b').width(bWidth)
      @$videoPlayer.find('.b').height(bHeight)
      @$videoPlayer.height(playerHeight)
      @$videoPlayer.find('.resizer').css({top: Math.round(playerHeight / 3), left: aWidth})

  # additional method for reseize the player hard to a given width (better rendering)
  resizeSingleStreamPlayerHard: (aWidth) ->
      aHeight = aWidth * @aRatio
      playerHeight = aHeight + @controlsHeight
      @$videoPlayer.find('.a').width(aWidth) if aWidth > 0
      @$videoPlayer.find('.a').height(aHeight) if aHeight > 0
      @$videoPlayer.height(playerHeight) if playerHeight > 0

  resizeVideo: (event) ->
    delta = @lastPageX - event.pageX
    @lastPageX = event.pageX

    newSplitRatio = @splitRatio[0] - delta / @playerWidth
    if (newSplitRatio < @minVideoWidth || newSplitRatio > 1 - @minVideoWidth)
      return
    @splitRatio[0] = newSplitRatio
    @splitRatio[1] = 1 - @splitRatio[0]
    @resizePlayer(true)

  checkFullscreenChange: ->
    @resizePlayer(true)
    #@player.controls.updateSeek(@originalProgressWidth)
    if @$playerWidth != @fullscreenPlayerWidth
      setTimeout ( =>
        @checkFullscreenChange() ), 50
