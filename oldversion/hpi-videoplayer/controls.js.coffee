###
    This class handles all the buttons/controls on the player.
    - Play / Pause button
    - Mute Button
    - Playback speed button
    - Fullscreen button
    - Progress bar
    - Volume bar

    Additonal optional buttons:
    - video quality (240p -> 1080p)
    - captions (cc)
    - most watched sections
    - preview
###
window.Html5Player or= {};

class window.Html5Player.Controls

  player : null

  constructor : ( player, $baseElement ) ->

    @player = player

    @$controls              = $baseElement.find('.controls')
    @$playButton            = $baseElement.find('.play')
    @$muteButton            = $baseElement.find('.mute')
    @$hdButton              = $baseElement.find('.hd')
    @$chapterButton         = $baseElement.find('.toc')
    @$chapterContent        = $baseElement.find('.chapterContent')
    @$timer                 = $baseElement.find('.currentTime')
    @$seeker                = $baseElement.find('.progress')
    @$seekSlider            = $baseElement.find('.progress .slider')
    @$bufferSlider          = $baseElement.find('.progress .buffer')
    @$volumeBar             = $baseElement.find('.volumebar')
    @$volume                = $baseElement.find('.volume')
    @$volumeSlider          = $baseElement.find('.volume .slider')
    @$fullscreenButton      = $baseElement.find('.fullscreen')
    @$playbackRateButton    = $baseElement.find('.speed')

    # additional buttons
    @$control               = $baseElement.find('.control')
    @$ccButton              = $baseElement.find('.cc')
    @$previewButton         = $baseElement.find('.preview')
    @$streamSelectionButton = $baseElement.find('.streamselection')
    @$streamSelectionEntry  = $baseElement.find('.streamselectionentry')

    $(@player.videoA).on "play pause", => @updatePlayButton()
    $(@player.videoA).on "ended", => @setReplayButton()
    $(@player.videoA).on "progress", => @updateSeek()
    $(@player.videoA).on "volumechange",  => @updateVolume()
    $(@player.videoA).on "timeupdate", =>
      @updateSeek()
      @updateTime()
      # jump to next preview range if preview is shown and and of current range is reached
      if @player.previewShown
        @player.preview.update()
      if @player.customPreviewIsShown
        @player.customPreview.update()
    $(window).on "toggleFullscreen", => @updateSeek()

    $(@$muteButton).on "hover", => @hoverVolumeBox()

    # additional event handling of media controller is used (seperate video and audio streams)
    if @player.mediaController
      $(@player.mediaController).on "play pause", => @updatePlayButton()
      $(@player.mediaController).on "ended", => @setReplayButton()
      $(@player.mediaController).on "volumechange",  => @updateVolume()

    @updateTime()
    @updateVolume()
    @attachButtonHandlers()
  # No key events due to feedback form
    if @player.handleKeyboardEvents
      @attachKeyboardHandlers()

    @rightClickActive = false
    @miniModeActive = false

  attachButtonHandlers : ->

    @$hdButton.click =>
      if @player.hd
        @player.hd = false
        @$hdButton.find('i').removeClass('primary-color').addClass('white')
      else
        @player.hd = true
        @$hdButton.find('i').removeClass('white').addClass('primary-color')
      @player.changeSource()

    @$playButton.click =>
      if @player.mediaController
        if @player.mediaController.playbackState is "ended"
          @player.gototime(0)
        else if @player.mediaController.paused or @player.mediaController.playbackState is "waiting"
          # there seems to be a bug in the media controller where the first play event does not get triggered
          if @player.mediaController.playbackState is "waiting" and not @player.mediaController.paused
            $(@player.mediaController).trigger "play"
          @player.gototime(@player.videoA.currentTime)
        else
          @player.pause()
      else
        if @player.videoA.paused
          @player.play()
        else
          @player.pause()

    @$chapterButton.click =>
      if @$chapterContent.hasClass "visible"
        @$chapterContent.removeClass "visible"
      else
        @$chapterContent.addClass "visible"

    @$muteButton.click =>
      unless @player.muted
        @player.mute(true)
      else
        @player.mute(false)

    @$playbackRateButton.click =>

      playbackRate = switch @player.playbackRate
        when 1.0 then 1.5
        #when 1.5 then 2.0
        #when 2.0 then 0.7
        when 1.5 then 0.7
        when 0.7 then 1.0

      @$playbackRateButton.children().html "#{playbackRate.toFixed(1)}x"
      @player.changeSpeed playbackRate

    @$fullscreenButton.click =>
      @player.ui.toggleFullscreen()
      @$fullscreenButton.find('i').toggleClass('icon-fullscreen-on').toggleClass('icon-fullscreen-off')

    @$seeker.click (event) =>
      vid = @player.videoA
      pos = (event.pageX - @$seeker.get()[0].getBoundingClientRect().left) / @$seeker.width()
      sec = Math.round(pos * vid.duration)
      window.location.hash = sec
      @player.gototime(sec)

    @$volume.click (event) =>
      if @player.muted
        @player.mute(false)
      diff = ((@$volume.width() - (event.pageX - @$volume.get()[0].getBoundingClientRect().left)) / @$volume.width())
      if diff <= 0
        diff = 0
      vol = 1 - diff
      if @player.mediaController
        @player.mediaController.volume = vol
      else
        @player.videoA.volume = vol

    @$ccButton.click =>
      if @player.cc
        @player.cc = false
        @$ccButton.find('i').removeClass('primary-color').addClass('white')
        @player.setCaptionsVisibility('hidden')
      else
        @player.cc = true
        @$ccButton.find('i').removeClass('white').addClass('primary-color')
        @player.setCaptionsVisibility('showing')

    @$previewButton.click =>
      if @player.previewShown
        @$previewButton.find('i').removeClass('primary-color').addClass('white')
        @player.preview.stop()
      else
        @$previewButton.find('i').removeClass('white').addClass('primary-color')
        @player.preview.show()

    @$streamSelectionButton.click =>
      menu = @$streamSelectionButton.find('.dropdown-menu')
      if menu.css('display') is 'none'
        menu.css('display', 'block')
      else
        menu.css('display', 'none')

    @$streamSelectionEntry.click (event) =>
      event.preventDefault()
      event.stopPropagation()
      url =  $(event.currentTarget).data('videourl')
      if url?
        $(event.currentTarget).siblings().removeClass('selected')
        $(event.currentTarget).addClass('selected')
        @$streamSelectionButton.find('.dropdown-menu').css('display', 'none')
        @player.changeSource(url)

    # Detection of right click and hold on seeker for tag/keyword submission
    if @player.hasTaggingActive
      @$seeker
        .on "mousedown", (event)  => 
          if event.which is 3
            @rightClickActive = true
            startPosition = ((event.pageX - @$seeker.get()[0].getBoundingClientRect().left) / @$seeker.width())
            if startPosition < 0
              startPosition = 0
            if startPosition > 1
              startPosition = 1
            @player.tagging.start(startPosition)
          event.preventDefault()
        .on "contextmenu", (event) =>
          event.preventDefault()

      $(window)
        .on "mousemove", (event) =>
          if @rightClickActive
            endPosition = ((event.pageX - @$seeker.get()[0].getBoundingClientRect().left) / @$seeker.width())
            if endPosition < 0
              endPosition = 0
            if endPosition > 1
              endPosition = 1
            @player.tagging.update(endPosition)
          event.preventDefault()

      $(window)
        .on "mouseup", (event) =>
          if @rightClickActive
            @rightClickActive = false
            @player.tagging.stop()
          event.preventDefault()
    
    return

  attachKeyboardHandlers : ->

    # key events for arrow keys; 37=left, 39=right, #p , #f
    keyboardControlsUp =
      37  : => @player.seekBack(10)
      39  : => @player.seekForward(10)
    keyboardControlsPress =
      112 : => @player.togglePlay()
      102 : => @player.ui.toggleFullscreen()
    $(window).on "keyup", (evt) ->
      for key, callback of keyboardControlsUp
        currentTag = $(document.activeElement).prop("tagName")
        unless (currentTag == 'INPUT' || currentTag == 'TEXTAREA')
          keyCode = evt.keyCode || evt.charCode
          if keyCode.toString() == key
            callback()
    $(window).on "keypress", (evt) ->
      for key, callback of keyboardControlsPress
        currentTag = $(document.activeElement).prop("tagName")
        unless (currentTag == 'INPUT' || currentTag == 'TEXTAREA')
          keyCode = evt.keyCode || evt.charCode
          if keyCode.toString() == key
            callback()
    return

  hoverVolumeBox : ->
    @$volumeBar.toggleClass('hovering')

  updatePlayButton : ->
    if @player.videoA.paused or @player.mediaController and @player.mediaController.paused
      @$playButton.find('i').removeClass('icon-reload').removeClass('icon-pause').addClass('icon-play')
    else
      @$playButton.find('i').removeClass('icon-reload').removeClass('icon-play').addClass('icon-pause')

  setReplayButton : ->
    @$playButton.find('i').removeClass('icon-pause').removeClass('icon-play').addClass('icon-reload')

  updateSeek : ( progressWidth ) ->
    vid = @player.videoA
    vidbuf = vid.buffered
    bufId = vidbuf.length - 1

    if !progressWidth
      progressWidth = @$seeker.width()

    seekWidth = vid.currentTime / vid.duration * 100

    if vidbuf.length > 0
      bufferWidth = vidbuf.end(bufId) / vid.duration * 100
      # The seek slider cuts into the buffer
      bufferWidth -= seekWidth
    else
      bufferWidth = 0

    @$bufferSlider.width("#{bufferWidth}%")
    @$seekSlider.width("#{seekWidth}%")

  updateTime : ->
    time = @player.durationToTime @player.videoA.currentTime
    @$timer.text(time)

  updateVolume : ->
    if @player.muted
      @$volumeSlider.width("0%")
      @$muteButton.find('i').removeClass('icon-volume-on').addClass('icon-volume-off')
    else
      if @player.mediaController
        @$volumeSlider.width("#{@player.mediaController.volume * 100}%")
      else
        @$volumeSlider.width("#{@player.videoA.volume * 100}%")
      @$muteButton.find('i').removeClass('icon-volume-off').addClass('icon-volume-on')

  ###
  The current implementation for most watched sections is mocked/random.
  It is based on the length of the video which will be aggregated when the video is loaded
  and the metadata is present.
  Therefore the associated button will be added to the controls after the metadata is fully loaded
  and the sections are generated.
  This will later be replaced with just the click event handler.
  ###
  addMostWatchedButton : ->
    unless @miniModeActive
      if !@$controls.find('.most-watched.button').length
        mostWatchedButton = $( '<td class="most-watched button"><i class="xikolo-icon icon-most-watched"></i></td>' ).insertAfter(@$ccButton)
        mostWatchedButton.click =>
          if @player.mostWatchedShown
            @player.mostWatchedShown = false
            mostWatchedButton.find('i').removeClass('primary-color').addClass('white')
            @$controls.find( '.mostWatched' ).hide()
          else
            @player.mostWatchedShown = true
            mostWatchedButton.find('i').removeClass('white').addClass('primary-color')
            @$controls.find( '.mostWatched' ).show()
      else
        @$controls.find('.most-watched.button > i').removeClass('primary-color').addClass('white')
        @player.mostWatchedShown = false

  # the mini mode deactivates a lot of controls / hides them
  activateMiniMode : ->
    @$control.hide()
    @$playbackRateButton.hide()
    @$streamSelectionButton.hide()
    @$controls.find('.most-watched.button').hide()
    @$previewButton.hide()
    @$volumeBar.hide()
    @$fullscreenButton.hide()
    if @player.hasLoadingOverlay
      @player.loadingOverlay.hidePreviewAction()
    @miniModeActive = true

  deactivateMiniMode : ->
    @$control.show()
    @$playbackRateButton.show()
    @$streamSelectionButton.show()
    @$controls.find('.most-watched.button').show()
    @$previewButton.show()
    @$volumeBar.show()
    @$fullscreenButton.show()
    if @player.hasLoadingOverlay
      @player.loadingOverlay.showPreviewAction()
    @miniModeActive = false
