window.Html5Player or= {};

class window.Html5Player.Chapter

  constructor : (title, time, thumb) ->

    @title = title
    @time  = time
    @thumb = thumb
    @active = false


  seconds : ->
    ###
      returns chapter time in seconds-from-start;
      only works if @time format is HH:MM:SS
    ###
    time = @time.split(":", 3).map (i) -> parseInt i
    return time[0] * 3600 + time[1] * 60 + time[2]


class window.Html5Player.Chapters


  constructor : (player, chapterData, container) ->

    @player = player
    @container = container
    @chapters = []
    @parseChapters(chapterData)
    @lastActiveChapter = null

    @$chapterContent = container.find("#chapterContent")


  parseChapters : (data) ->
    ###
      parse chapter information from videodata JSON
    ###
    $.each data, (key, chapter) =>
      chapter = new Chapter( chapter['title'], chapter['time'], chapter['imagePath'] )
      @chapters.push chapter


  setActiveChapter : (time) ->

    chapter.active = false for chapter in @chapters
    for i in [@chapters.length - 1 .. 0] by - 1
      if time >= @chapters[i].seconds()
        @chapters[i].active = true
        break

    #remove CSS class if necessary
    unless i == @lastActiveChapter
      @container.find("li").eq( @lastActiveChapter ).removeClass "active"
      @container.find("li").eq( i ).addClass "active"
      @lastActiveChapter = i


  generateChapterList : ->

    @container.empty()
    for chapter in @chapters
      do (chapter) =>
        li = $("
                  <li>
                    <p>#{chapter.title}</p>
                    <p>#{chapter.time}</p>
                  </li>")
        li.addClass 'active' if chapter.active
        @bindClickEvent li, chapter.seconds()
        @container.append li

    return true


  bindClickEvent : (element, seconds) ->

    element.on "click", (event) =>
      @player.gototime seconds

      if @$chapterContent.hasClass "visible"
        @$chapterContent.removeClass "visible"


  jumpToChapter: (number) ->

    @player.seek @chapters[number-1].seconds()
