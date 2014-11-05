###
    This class sets up the HTML for the video player.

    Additional constructor parameters:
    - hasCaptions
    - hasPreview & previewRanges
    - initialVideoWidth (hard set video width for better rendering in AEL)
    - hasLoadingOverlay
    - videoFormat (default is mp4)
###
window.Html5Player or= {};

class window.Html5Player.HtmlBuilder

  constructor : ( $baseElement, videoStreams, hasChapters, hasSlides, isSingle = false, hasCaptions, hasPreview, previewRanges, initialVideoWidth, hasLoadingOverlay , format )->

    unless isSingle
      if videoStreams.left.url_hd
        videoA = videoStreams.left.url_hd
      else
        videoA = videoStreams.left.url
      if videoStreams.right.url_hd
        videoB = videoStreams.right.url_hd
      else
        videoB = videoStreams.right.url
      posterA = videoStreams.left.poster
      posterB = videoStreams.right.poster
      widthA = videoStreams.left.width
      widthB = videoStreams.right.width
      heightA = videoStreams.left.height
      heightB = videoStreams.right.height
    else
      if videoStreams.right.url_hd
        videoA = videoStreams.right.url_hd
      else if videoStreams.right.url
        videoA = videoStreams.right.url
        # special case for seperate audio and video track (Youtube Webm)
        # the best of both will be used initially
      else if videoStreams.right.video and videoStreams.right.audio
        [..., bestVideo] = videoStreams.right.video
        [..., bestAudio] = videoStreams.right.audio
      posterA = videoStreams.right.poster
      widthA = videoStreams.right.width
      heightA = videoStreams.right.height

    if videoStreams && videoStreams.right && videoStreams.right.duration
      duration = @durationToTime videoStreams.right.duration
    else
      duration = ''

    if hasPreview
      previewDuration = @durationToTime @calcPreviewDuration previewRanges

    if format then videoFormat = "video/" + format else videoFormat = "video/mp4"
    if format then audioFormat = "audio/" + format else audioFormat = "audio/mp4"

    if initialVideoWidth?
      new_html = """
          <div class="videoPlayer" style="width: #{initialVideoWidth}px;">
          """
    else
      new_html = """
          <div class="videoPlayer">
          """

    # case for seperate audio and video tracks
    if videoStreams.right.video and videoStreams.right.audio
      # the video with the best quality is rendered by default
      new_html += """
          <div class="video a">
            <video poster="#{posterA}" data-format="#{bestVideo.format}" data-width="#{widthA}" data-height="#{heightA}" style="background: black;">
                <source src="#{bestVideo.url}" type="#{videoFormat}">
            </video>
            <audio data-format="#{bestAudio.format}" >
                <source src="#{bestAudio.url}" type="#{audioFormat}">
            </audio>
          </div>
        """
    # else show only normal video a
    else 
      new_html += """
            <div class="video a">
                <video poster="#{posterA}" data-width="#{widthA}" data-height="#{heightA}" style="background: black;">
                    <source src="#{videoA}" type="#{videoFormat}">
                </video>
            </div>
        """

    unless isSingle
      new_html += """
            <div class="resizer">
                <i class="xikolo-icon icon-slide"></i>
            </div>
            <div class="video b">
                <video poster="#{posterB}" data-width="#{widthB}" data-height="#{heightB}" style="background: black;">
                    <source src="#{videoB}" type="#{videoFormat}">
                    <p>Fallback</p>
                </video>
            </div>
        """

    if hasChapters
      new_html += """
            <div class="chapterContent">
                <div class="chapters">
                    <ul>
                    </ul>
                </div>
            </div>
            """

    new_html += """
            <div class="clear"></div>
            <div class="slidePreview"><img src="" />
              <div class="arrow"></div>
            </div>
            <div class="controlsContainer">
                <table class="controls"><tr>
                    <td class="play button">
                        <i class="xikolo-icon icon-play"></i>
                    </td>
                    <td class="progressbar">
        """

    if hasSlides
      new_html += """
                        <span class="slideContainer"></span>
            """

    new_html += """
                        <span class="progress">
                            <span class="slider"></span><span class="buffer"></span>
                        </span>
                    </td>
                    <td class="control">
                        <span class="currentTime">0:00</span> / <span class="totalTime">#{duration}</span>
                    </td>
                    <td class="speed button">
                        <span>1.0x</span>
                    </td>
        """

    # different video quality levels are currently only supported in single stream mode
    if isSingle and videoStreams.right.url_hd or not isSingle
      new_html += """
                    <td class="hd button">
                        <i class="xikolo-icon icon-HD primary-color"></i>
                    </td>
            """

    if isSingle and videoStreams.right.video? and videoStreams.right.video.length > 1
      new_html += """
                    <td class="streamselection button">
                      <i class="xikolo-icon icon-stream-selection"></i>
                      <ul class="dropdown-menu">
            """
      for video in videoStreams.right.video[0...-1]
        new_html += """
                        <li class="streamselectionentry" data-videourl="#{video.url}"><span>#{video.label}</span></li>
          """
      new_html += """
                      <li class="streamselectionentry selected" data-videourl="#{bestVideo.url}"><span>#{bestVideo.label}</span></li>
                      </ul>
                    </td>
            """

    if isSingle and hasCaptions
      new_html += """
                    <td class="cc button">
                        <i class="xikolo-icon icon-cc"></i>
                    </td>
            """

    if isSingle and hasPreview
      new_html += """
                    <td class="preview button">
                        <i class="xikolo-icon icon-preview"></i><span>#{previewDuration}</span>
                    </td>
            """

    if hasChapters
      new_html += """
                    <td class="toc button">
                        <i class="xikolo-icon icon-list"></i>
                    </td>
            """

    new_html += """
                    <td class="mute button">
                        <i class="xikolo-icon icon-volume-on"></i>
                    </td>
                    <td class="volumebar">
                        <span class="volume">
                          <span class="slider"></span>
                        </span>
                    </td>
                    <td class="fullscreen button">
                        <i class="xikolo-icon icon-fullscreen-on"></i>
                    </td>
                </tr></table>
            </div>
        </div>
        """

    if hasLoadingOverlay
      new_html += """
        <div class="loadingOverlay">
          <i class="xikolo-icon icon-loading"></i>
          <div class="loadingText">Loading</div>
        </div>
      """

    $baseElement.html(new_html)

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

  calcPreviewDuration : ( previewRanges ) ->
    previewDuration = 0
    for range in previewRanges
      previewDuration += range.end - range.start
    return previewDuration
