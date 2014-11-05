###
    This class handles the overlay for the most watched sections of a video.
    THe overlay consists of ranged in the timeline.
###
window.Html5Player or= {};

class window.Html5Player.MostWatched

  constructor : ( player, $baseElement ) ->
    @player   = player
    @$seeker  = $baseElement.find('.progress')

  updateMostWatched : ( mostWatchedSections ) ->
    @removeMostWatched()
    @showMostWatched(mostWatchedSections)

  showMostWatched : ( mostWatchedSections ) ->
    @addMostWatched  section for section in mostWatchedSections

  removeMostWatched : ->
    @$seeker.find('.mostWatched').remove()

  addMostWatched : ( section ) ->
    offset = Math.ceil( ( section.start / @player.videoA.duration ) * 100 )
    width = Math.ceil( ( ( section.end - section.start ) / @player.videoA.duration ) * 100 )
    @$seeker.prepend $('<div class="mostWatched" style="left:' + offset + '%; width:' + width + '%; display:none;"></div>')