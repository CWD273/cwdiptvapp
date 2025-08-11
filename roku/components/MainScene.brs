sub init()
    m.playingVideo = invalid
    m.top = m.top
    m.streamList = m.top.findNode("streamList")
    m.status = m.top.findNode("status")

    ' default test M3U (replace with your URL or blank -> will ask)
    m.defaultM3U = "https://example.com/playlist.m3u"

    ' Simple prompt: we call loadPlaylist with a URL; replace or provide UI to accept input.
    ' For this skeleton, we'll attempt default URL first.
    loadPlaylist(m.defaultM3U)
end sub

function loadPlaylist(m3uUrl as String) as Boolean
    m.status.text = "Loading playlist..."
    playlist = ParseM3U(m3uUrl)
    if playlist = invalid or playlist.count() = 0 then
        m.status.text = "Failed to load or no items in playlist."
        return false
    end if

    ' Build items for MarkupList
    items = []
    for each item in playlist
        row = {
            title: item.title
            url: item.url
            subtitle: item.duration
        }
        items.push(row)
    end for

    m.streamList.content = items
    m.streamList.observeField("itemSelected", "onItemSelected")
    m.status.text = "Loaded " + str(items.count()) + " items. Press OK to play."
    return true
end function

sub onItemSelected()
    idx = m.streamList.itemSelected
    if idx < 0 then return
    item = m.streamList.content[idx]
    playStream(item.url, item.title)
end sub

sub playStream(url as String, title as String)
    if m.playingVideo <> invalid then
        m.top.removeChild(m.playingVideo)
        m.playingVideo = invalid
    end if

    m.status.text = "Playing: " + title
    video = CreateObject("roSGNode", "Video")
    video.translation = [40,150]
    video.width = 1200
    video.height = 420
    video.uri = url
    m.top.appendChild(video)
    m.playingVideo = video

    video.control = "play"
end sub

' Called when the m3uUrl field changes (if ever used)
sub onM3UUrlChanged()
    url = m.top.m3uUrl
    if url <> invalid and url <> "" then
        loadPlaylist(url)
    end if
end sub
