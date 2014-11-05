###
    This class handles the caption tracks for the video player.
    It supports currently only one (english) caption track.

    Possible improvements:
    - support mutliple caption tracks (different languages)
    - setCaptionsVisibility() should get an additional parameter which track should be enabled
###
window.Html5Player or= {};

class window.Html5Player.Captions

  constructor : ( player, $baseElement ) ->
    @player     = player

  updateCaptions : ( captionsUrl ) ->
    @removeCaptions()
    @addCaptions(captionsUrl)

  removeCaptions : ->
    $(@player.videoA).find('track').remove()

  addCaptions : ( captionsUrl ) ->
    $(@player.videoA).append $('<track label="English" kind="captions" srclang="en" src="' + captionsUrl + '" default>')
    @player.videoA.textTracks[0].mode = 'hidden';

  setCaptionsVisibility : ( visibility ) ->
    @player.videoA.textTracks[0].mode = visibility;