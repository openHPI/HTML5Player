###
  This class is responsible for the slide previewing functionality

###
window.Html5Player or= {};

class window.Html5Player.SlideViewer

  slideContainer: null
  slideData: null
  slidePreview: null
  player: null
  controlsContainer: null

  constructor : ( player, $baseElement, thumbnails ) ->
    @player = player
    @slideContainer = $baseElement.find(".slideContainer")
    @slideData = @getSlideData(thumbnails)
    @slidePreview = $baseElement.find(".slidePreview")
    @controlsContainer = $baseElement.find(".controlsContainer")

  buildSlidePreview : ->
    ###
      create needed divs for holding the preview images
    ###
    $container = $("<div>")
    for imageIndex in [0..@slideData.length - 1]

      $slideDiv = $("""<div class="slideDiv" data-slideindex="#{imageIndex}" data-slideurl="#{@slideData[imageIndex].path}">""")
      $slideDiv.width(@calcSlideWidth(imageIndex) + "%")

      #$previewImage = @createImageElement imageIndex
      #$slideDiv.append($previewImage)
      @attachMouseEvents $slideDiv, imageIndex, @controlsContainer, @slidePreview

      $container.append($slideDiv)

    # append all at once
    @slideContainer.append($container)
  #@slideContainer.append($("""<div class="overlayDiv">"""))



  calcSlideWidth : ( index ) ->
    videoDuration = @player.videoA.duration

    if index >= @slideData.length - 1
      endValue = videoDuration
      lastDiv = true
    else
      endValue = @slideData[index + 1].start

    if index == 0
      startValue = 0
    else
      startValue = @slideData[index].start

    slideDuration =  endValue - startValue
    slideWidth = slideDuration * 100 / videoDuration
    #if index % 2 == 0
    #  slideWidth = Math.floor( slideDuration * 100 / videoDuration )
    #else
    #  slideWidth = Math.ceil( slideDuration * 100 / videoDuration )

    return slideWidth


  createImageElement : ( index ) ->
    ###
      create an image element where we will store the preview of the slide
      when we need that preview
    ###
    $image = $("""<img class="previewImg">""")
    $image.attr("src", "#{ @slideData[index].path }")
    return $image


  attachMouseEvents : ( $element, index, $controlsContainer, $slidePreview ) ->

    $element.on "click", ( event ) =>
      @player.gototime @slideData[index].start

    $element.hover(
      (->
        imgHeight = parseInt $slidePreview.css("height")
        x = $element.offset().left - 20
        y = $controlsContainer.offset().top - imgHeight - 2
        #y = $element.offset().top - imgHeight
        $slidePreview.find("img").attr("src", $element.attr("data-slideurl"));
        $slidePreview.css("display", "block")
        $slidePreview.offset({ top: y, left: x })
      ),
      (->
        $slidePreview.css("display", "none")
      )
    )

  getSlideData : ( thumbnails ) ->
    ###
      parse the JSON and transform the time values into seconds
    ###
    # TODO Refactor!!
    slides = thumbnails.images
    slides.forEach ( slide ) =>
      timeparts = slide.start.split(":")
      slide.start = parseInt(timeparts[2]) + 60 * parseInt(timeparts[1]) + 3600 * parseInt(timeparts[0])
      slide.path = slide.path
    return slides

#    basepath = "data/lectures/#{thumbnails.lectureId}/"
#    slides = thumbnails.images
#    slides.forEach ( slide ) =>
#      timeparts = slide.start.split(":")
#      slide.start = parseInt(timeparts[2]) + 60 * parseInt(timeparts[1]) + 3600 * parseInt(timeparts[0])
#      slide.path = basepath + slide.path
#    return slides

