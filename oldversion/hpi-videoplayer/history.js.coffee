###
    This class saves all the watched sections of a user.
    On flush() the History returns all watched sections (watchedRanges) and clears the list.
    It listens on all play and pause events as well as handles the last view range before closing the tab/website.
###
window.Html5Player or= {};

class window.Html5Player.History

  constructor : ( player ) ->
    @player = player
    @watchedRanges = []
    @tmpStartTime = -1

    if player.mediaController
      $(player.mediaController).on "play", => @handlePlay()
      $(player.mediaController).on "pause", => @handlePause()
    else
      $(player.videoA).on "play", => @handlePlay()
      $(player.videoA).on "pause", => @handlePause()
  
  handlePlay : ( time ) ->
    if @player.previewShown or @player.customPreviewIsShown then @tmpStartTime = -1
    else if time then @tmpStartTime = time
    else @tmpStartTime = @player.currentTime()
    return

  handlePause : ( time ) ->
    unless @player.previewShown or @player.customPreviewIsShown
      if time then endTime = time else endTime = @player.currentTime()
      # ignore preseek range
      unless @tmpStartTime is -1 or @tmpStartTime is endTime
        @watchedRanges.push {'start': @tmpStartTime, 'end': endTime}

  flush : ->
    # save last range before leaving website
    if @player.mediaController and @player.mediaController.playbackState is "playing" and not @player.previewShown and not @player.customPreviewIsShown and @tmpStartTime != -1
      @watchedRanges.push {'start': @tmpStartTime, 'end': @player.currentTime()}
      @handlePlay()
    else if not @player.mediaController and not @player.videoA.paused and not @player.previewShown and not @player.customPreviewIsShown and @tmpStartTime != -1
      @watchedRanges.push {'start': @tmpStartTime, 'end': @player.currentTime()}
      @handlePlay()
    returnValues = @watchedRanges
    @watchedRanges = []
    return returnValues