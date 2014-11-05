###
    This class handles the loading overlay for the video.
      It offers the action to play or preview a video.
###
window.Html5Player or= {};

class window.Html5Player.LoadingOverlay

  constructor : ( player, $baseElement ) ->
    @player   = player
    @$overlay  = $baseElement.find('.loadingOverlay')

    # methods get called after videos are loaded, buffered and basic sync is in place
    $(window).on "videosReady", => @showActions()

    @$overlay.on "click", ".icon-play", =>
      @player.controls.$playButton.click()
      @$overlay.hide()

    @$overlay.on "click", ".icon-preview", =>
      @player.controls.$previewButton.click()
      @$overlay.hide()

  showActions : ->
    if @player.hasPreview
      @$overlay.html("""
        <i class="xikolo-icon icon-play" style="
          line-height: 5rem;
          padding-right: 1rem;
          cursor: pointer;"></i>
        <i class="xikolo-icon icon-preview" style="
          vertical-align: 0;
          line-height: 5rem;
          font-size: 4rem;
          padding-left: 1rem;
          margin-right: 0;
          cursor: pointer;"></i>
      """ )
    else
      @$overlay.html("""
        <i class="xikolo-icon icon-play" style="
          line-height: 5rem;
          padding-right: 1rem;
          cursor: pointer;"></i>
      """ )
  hidePreviewAction : ->
    @$overlay.find('.icon-preview').hide()

  showPreviewAction : ->
    @$overlay.find('.icon-preview').show()