$ ->

  typingTimer = undefined
  currentSearchTerm = undefined
  currentVideoID = undefined

  getLang = ->
    lang = (if (navigator.language) then navigator.language else navigator.userLanguage)
    if lang
      return lang
    else
      return "en"

  getSuggestions = (query) ->
    unless currentSearchTerm is $("#query").val()
      currentSearchTerm = $("#query").val()
      $.ajax
        type: "GET"
        url: "http://suggestqueries.google.com/complete/search?hl=" + getLang + "&gl=" + getLang + "&ds=yt&client=youtube&hjson=t&q=" + encodeURIComponent(query) + "&cp=1"
        dataType: "jsonp"
        success: (result) ->
          if result and result[1].length > 1
            getTopSearchResults result[1][0][0]
          else
            $.jGrowl "Couldn't find any videos matching your query \"" + query + "\"",
              theme: "light"
              header: "Error"

  getTopSearchResults = (keyword) ->
    $.ajax
      type: "GET"
      url: "http://gdata.youtube.com/feeds/api/videos?q=" + encodeURIComponent(keyword) + "&format=5&max-results=1&v=2&alt=jsonc"
      dataType: "jsonp"
      success: (result) ->
        #console.log result
        insertVideoID result.data.items[0].id
        $.jGrowl result.data.items[0].title,
          theme: "light"
          header: "Playing now"
        document.title = result.data.items[0].title + " \u00bb YTinstant"

  insertVideoID = (videoid) ->
    unless currentVideoID is videoid
      currentVideoID = videoid

      params = allowScriptAccess: "always"
      atts = 
        id: "ytplayer"
        allowFullScreen: "true"
        wmode: "opaque"
      swfobject.embedSWF("http://www.youtube.com/v/" + videoid + 
      "?enablejsapi=1" +
      "&playerapiid=ytplayer" +
      "&version=3" +
      "&disablekb=1" +
      "&autoplay=1" +
      "&rel=0" +
      "&showinfo=0" +
      "&theme=light" +
      "&loop=1" +
      "&playlist=" + videoid + 
      "&wmode=transparency" +
      "&iv_load_policy=3" +
      "&vq=hd1080", 
      "ytplayer", 
      "100%", 
      "100%", 
      "8", # flash player version
      null, 
      null, 
      params, 
      atts,
      (e) ->
        $("#ytplayer").html "Error: You need Adobe Flash Player!"  unless e.success
      );

  # check if hash given
  if window.location.hash
    hash = decodeURIComponent(window.location.hash.substring(1))
    $("#query").val(hash)
    getSuggestions hash
  else
    # default video id, shown on startup
    insertVideoID "_2c5Fh3kfrI"

  $("#query").keyup ->
    clearTimeout typingTimer
    val = @value
    if(val)
      typingTimer = setTimeout(->
        window.location.hash = encodeURIComponent(val)
        getSuggestions val
      , 1000)


