' Simple M3U parser
function ParseM3U(m3uUrlOrContent as String) as Object
    content = m3uUrlOrContent

    ' If it looks like a URL (http/https), fetch it
    if Left(LCase(content), 7) = "http://" or Left(LCase(content), 8) = "https://" then
        url = CreateObject("roUrlTransfer")
        url.SetUrl(content)
        url.SetCertificatesFile("") ' use default
        xml = url.GetToString()
        if xml = invalid then
            return invalid
        end if
        content = xml
    end if

    lines = Split(content, Chr(10))
    items = []

    current = {}
    for each rawLine in lines
        line = Trim(rawLine)
        if line = "" then continue
        if Left(line,1) = "#" then
            ' EXTINF: format: #EXTINF:-1,Display title
            if Instr(line, "#EXTINF:") = 1 then
                ' extract text after comma
                commaPos = Instr(line, ",")
                title = ""
                if commaPos > 0 then
                    title = Mid(line, commaPos + 1)
                else
                    title = line
                end if
                current = { title: title, url: "" }
            end if
            ' (We skip other tags in this simple parser)
        else
            ' This is a URL line
            if current = {} then
                ' no preceding EXTINF: create title from url
                current = { title: line, url: line }
            else
                current.url = line
            end if
            items.push(current)
            current = {}
        end if
    end for

    return items
end function
