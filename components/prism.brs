function PrismSession(fields)
    instance = {}
    instance.baseUrl = fields["baseUrl"]
    instance.username = fields["username"]
    instance.password = fields["password"]

    instance.sessionId = prismLogin(instance)

    instance.get = function(url)
        return getPrism(m, url)
    end function

    instance.downloadImage = sub(url, destination)
        downloadImagePrismImage(m, url, destination)
    end sub

    return instance
end function

function getPrism(instance, url)
    url = instance.baseUrl + url
    print "requesting url " url
    conn = CreateObject("roUrlTransfer")
    if url.inStr(0, "https") = 0
        conn.setCertificatesFile("common:/certs/ca-bundle.crt")
        conn.initClientCertificates()
    end if
    conn.SetUrl(url)
    conn.AddHeader("X-Session-ID", instance.sessionId)
    data = conn.GetToString()
    return ParseJson(data)
end function

sub downloadImagePrismImage(instance, url, destination)
    conn = CreateObject("roUrlTransfer")
    url = instance.baseUrl + url
    print "requesting url " url
    if url.inStr(0, "https") = 0
        conn.setCertificatesFile("common:/certs/ca-bundle.crt")
        conn.initClientCertificates()
    end if
    conn.SetUrl(url)
    conn.AddHeader("X-Session-ID", instance.sessionId)
    conn.GetToFile(destination)
end sub


function prismLogin(partialSession)
    http = CreateObject("roUrlTransfer")
    http.RetainBodyOnError(true)
    messagePort = CreateObject("roMessagePort")
    http.SetPort(messagePort)
    http.setCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()

    ' http.addHeader("Some-Random-Header", "header stuff")
    http.SetUrl(partialSession.baseUrl + "/api/v1/session")

    post = {
        username: partialSession.username,
        password: partialSession.password
    }
    postJSON = FormatJson(post)

    response = ""
    lastresponsecode = ""
    lastresponsefailurereason = ""
    responseheaders = []
    if http.AsyncPostFromString(postJSON) then
        event = Wait(10000, http.GetPort())
        if Type(event) = "roUrlEvent" then
            response = event.getString()
            responseheaders = event.GetResponseHeaders()
            lastresponsecode = event.GetResponseCode()
            lastresponsefailurereason = event.GetFailureReason()
        else if event = invalid then
            http.asynccancel()
            lastresponsefailurereason = "HTTP timed out. Configured Timeout: 10s"
            lastresponsecode = 0
        else
            ? "AsyncPostFromString unknown event"
        end if
    end if

    ' print "Response Headers: " responseheaders
    print "Response Code: " lastresponsecode
    print "Failure Reason: " lastresponsefailurereason

    data = ParseJson(response)
    prism_sessionId = data["id"]
    return prism_sessionId
end function