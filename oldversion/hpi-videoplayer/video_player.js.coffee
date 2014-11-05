
###
    This is the main class for the video player.
    It is in charge of:
    - public interface to control video player
    - syncing between the 2 videos
    - bootstrapping the whole player
###
window.Html5Player or= {};

class window.Html5Player.VideoPlayer

  constructor : ( @$baseElement, @videoData )->

    @hasChapters = @videoData.chapters?
    @hasSlides = @videoData.thumbnails?
    @isSingle = @checkSingle()
    @hasCaptions = @videoData.captions?
    @hasLoadingOverlay = @videoData.hasLoadingOverlay
    @hasPreview = @videoData.previewRanges?
    @hasTaggingActive = @videoData.taggingActive
    @hasCustomPreview = @videoData.hasCustomPreview

    if @videoData.handleKeyboardEvents?
      @handleKeyboardEvents = @videoData.handleKeyboardEvents
    else
      @handleKeyboardEvents = true

    builder = new Html5Player.HtmlBuilder( @$baseElement, @videoData.streams, @hasChapters, @hasSlides, @isSingle, @hasCaptions, @hasPreview, @videoData.previewRanges, @videoData.initialVideoWidth, @hasLoadingOverlay, @videoData.format )

    @videoA = @$baseElement.find('.a video')[0]
    @audioA = @$baseElement.find('.a audio')[0]

    # create media controller for synchronized video and audio track
    if @videoA and @audioA
      @mediaController = new MediaController()
      @videoA.controller = @mediaController
      @audioA.controller = @mediaController

    unless @isSingle
      @videoB = @$baseElement.find('.b video')[0]

    @ui = new Html5Player.UserInterface(@, @$baseElement)
    @controls = new Html5Player.Controls( @, @$baseElement )
    @cuePoints = new Html5Player.CuePoints( @, @$baseElement )
    @captions = new Html5Player.Captions( @, @$baseElement )
    @mostWatched = new Html5Player.MostWatched( @, @$baseElement )
    @history = new Html5Player.History( @ )

    if @hasSlides
      @slideViewer = new Html5Player.SlideViewer( @, @$baseElement, @videoData.thumbnails )
    if @hasChapters
      chaptersContainer = @$baseElement.find('.chapters ul')
      @chapters = new Html5Player.Chapters( @, @videoData.chapters, chaptersContainer )
    if @hasLoadingOverlay
      @loadingOverlay = new Html5Player.LoadingOverlay( @, @$baseElement )
    if @hasPreview
      @preview = new Html5Player.Preview( @, @$baseElement, @videoData.previewRanges )
    if @hasTaggingActive
      @tagging = new Html5Player.Tagging( @, @$baseElement )
    if @hasCustomPreview
      @customPreview = new Html5Player.CustomPreview( @, @$baseElement )

    @playbackRate = 1.0
    @volume = 1.0
    @muted = false
    @hd = true
    @sourceChanged = false
    @playingState = false
    @playerInitiated = false
    @loadCount = 0
    @dostuff_after_videos_load = true
    @cc = false
    @mostWatchedShown = false
    @previewShown = false
    @customPreviewIsShown = false

    # add text tracks to video if captions exist
    if @hasCaptions
      @captions.updateCaptions( @videoData.captions )

    # methods get called after videos are loaded, buffered and basic sync is in place
    $(window).on "videosReady", =>
      if @playerInitiated == false
        @playerInitiated = true
        @initPlayer()
      else
        if @dostuff_after_videos_load
          @dostuff_after_videos_load = false
          preseek = parseInt window.location.hash.substring(1)
          @gototime(preseek) if not isNaN preseek
        else
          @play

    $(window).on "ready", =>
      @ui.resizePlayer(true)

    # either wait for the video to buffer or
    # if it is allready buffered just go head
    $(@videoA).on "canplay", =>
      @loadCount++
      @attachEventHandlers()
      return

    unless @isSingle
      $(@videoB).on "canplay", =>
        @loadCount++
        @attachEventHandlers()
        return

    if @videoA.readyState >= @videoA.HAVE_FUTURE_DATA
      $(@videoA).trigger "canplay"

    if !@isSingle && @videoB.readyState >= @videoB.HAVE_FUTURE_DATA
      $(@videoB).trigger "canplay"


  initPlayer : ->

    @$baseElement.find(".totalTime").text @durationToTime @videoA.duration
    @ui.aRatio = $(@videoA).height() / $(@videoA).width()
    unless @isSingle
      @ui.bRatio = $(@videoB).height() / $(@videoB).width()
    @ui.resizePlayer(true)

    #evalutate hashtag to jump to time frame in video
    preseek = parseInt window.location.hash.substring(1)
    @gototime(preseek) if not isNaN preseek

    if @hasSlides && !@sourceChanged
      @slideViewer.buildSlidePreview()
    if @hasChapters && !@sourceChanged
      @chapters.generateChapterList()
    unless @isSingle
      @syncVideo()
    if @playingState
      @play()

  # public interface
  play : ->
    if @mediaController
      @mediaController.play()
    else
      @videoA.play()

  pause : ->
    if @mediaController
      @mediaController.pause()
    else
      @videoA.pause()


  togglePlay : ->
    if @mediaController
      if @mediaController.paused
        @play()
      else
        @pause()
    else
      if @videoA.paused
        @play()
      else
        @pause()

  gototime : (time) ->
    # end the preview if it is currently running and the user clicks outside the preview ranges
    if @previewShown and not @preview.seekTimeInPreviewRange(time)
      @controls.$previewButton.click()
    if @customPreviewIsShown and not @customPreview.seekTimeInPreviewRange(time)
      @customPreview.stop()

    if @mediaController
      try
        # pause event is missing when seeking while playing
        if @mediaController.playbackState is "playing"
          @history.handlePause(@videoA.currentTime)
          @mediaController.currentTime = time
          @history.handlePlay(@videoA.currentTime)
        else
          @mediaController.currentTime = time
          if @mediaController.playbackState is "waiting" and not @mediaController.paused
            @history.handlePlay(videoA.currentTime)
      catch error

      try
        @play()
      catch error

    else
      try
        # pause event is missing when seeking while playing
        unless @videoA.paused
          @history.handlePause(@videoA.currentTime)
          @videoA.currentTime = time
          @history.handlePlay(@videoA.currentTime)
        else
          @videoA.currentTime = time
          history.handlePlay(@videoA.currentTime)
      catch error

      try
        @play()
      catch error
     #do nothing
    return false

  seekForward : ( seconds ) ->
    if @mediaController
      @mediaController.currentTime += seconds
    else
      @videoA.currentTime += seconds

  seekBack : ( seconds ) ->
    if @mediaController
      @mediaController.currentTime -= seconds
    else
      @videoA.currentTime -= seconds

  changeSpeed : ( speed ) ->
    @playbackRate = speed
    if @mediaController
      @mediaController.playbackRate = speed
    else
      @videoA.playbackRate = speed
      unless @isSingle
        @videoB.playbackRate = speed

  mute : ( bool ) ->
    @muted = bool
    if @mediaController
      @mediaController.muted = bool
    else
      @videoA.muted = bool

  currentTime : ->
    return @videoA.currentTime

  videoState : ->
    if @mediaController
      if @mediaController.paused
        return "paused"
      else
        return "playing"
    else
      if @videoA.paused
        return "paused"
      else
        return "playing"

  changeSource : ( streamUrl ) ->
    currenttime = parseInt @videoA.currentTime if not isNaN @videoA.currentTime
    window.location.hash = "#" + parseInt @videoA.currentTime if not isNaN @videoA.currentTime
    @loadCount = 0
    @sourceChanged = true
    @playingState = !@videoA.paused
    @dostuff_after_videos_load = true
    # switching between different sources (240p, 480p, ...)
    if streamUrl? and @isSingle
      @videoA.src = streamUrl
    else
      if @hd
        unless @isSingle
          @videoA.src = @videoData.streams.left.url_hd if @videoData.streams.left.url_hd
          @videoB.src = @videoData.streams.right.url_hd if @videoData.streams.right.url_hd
        else
          @videoA.src = @videoData.streams.right.url_hd if @videoData.streams.right.url_hd

      else
        unless @isSingle
          @videoA.src = @videoData.streams.left.url
          @videoB.src = @videoData.streams.right.url
        else
          @videoA.src = @videoData.streams.right.url

    if @videoA.readyState >= @videoA.HAVE_FUTURE_DATA
      $(@videoA).trigger "canplay"

    if !@isSingle && @videoB.readyState >= @videoB.HAVE_FUTURE_DATA
      $(@videoB).trigger "canplay"

  updateCuePoints : ( cuePoints ) ->
    # hide the loading overlay if there is any (especially for first tag click)
    if @hasLoadingOverlay
      @loadingOverlay.$overlay.hide()
    @cuePoints.updateCuePoints( cuePoints )

  setCaptionsVisibility : ( visibility ) ->
    @captions.setCaptionsVisibility( visibility )

  updateMostWatched : ( mostWatchedSections ) ->
    @controls.addMostWatchedButton()
    @mostWatched.updateMostWatched( mostWatchedSections )

  startCustomPreview : ( start, end ) ->
    # hide the loading overlay if there is any (especially for first tag click)
    if @hasLoadingOverlay
      @loadingOverlay.$overlay.hide()
    @customPreview.show( start, end )


  # internal stuff

  durationToTime : ( duration ) ->
    seconds = Math.floor(duration)
    minutes = Math.floor(seconds / 60)
    hours = Math.floor(seconds / 3600)
    seconds = seconds % 60
    minutes = minutes % 60
    if hours > 0
      time = hours + ":" + @zeroPadInt(minutes)
    else
      time = minutes

    time += ":" + @zeroPadInt(seconds)

  zeroPadInt : ( value ) ->
    if value < 10
      value = "0" + value
    value

  attachEventHandlers : ->

    if !@isSingle && @loadCount == 2

      events = ["play", "pause", "timeupdate", "seeking"]

      events.forEach (evt) =>
        $(@videoA).on evt, =>
          if evt is "seeking" && Math.abs(@videoB.currentTime - @videoA.currentTime) > 1
            @videoB.currentTime = @videoA.currentTime if @videoA.currentTime
            #@videoB.play( @videoA.currentTime)
          if evt is "play"
            @videoB.play(@videoA.currentTime) if @videoA.currentTime

          if evt is "pause"
            @videoB.pause()

          if evt is "ratechange"
            @videoB.playbackRate = @playbackRate
      $(window).trigger("videosReady")
    if @isSingle && @loadCount > 0
      $(window).trigger("videosReady")

    return

  syncVideo : ->
    if Math.abs(@videoB.currentTime - @videoA.currentTime) > 1
      try
        @videoB.currentTime = @videoA.currentTime if @videoA.currentTime
      catch error
        #
      #@videoB.play(@videoA.currentTime)
    if @hasChapters
      @chapters.setActiveChapter(@videoB.currentTime) if @videoB.currentTime
    setTimeout ( => @syncVideo() ), 1000

  checkSingle : ->
    if @videoData.streams.left && @videoData.streams.left.url && @videoData.streams.right && @videoData.streams.right.url
      return false
    return true