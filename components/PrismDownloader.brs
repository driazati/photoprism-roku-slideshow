sub init()
  m.top.functionName = "go"
end sub


sub go()
  ' Get and validate credentials
  reg = RegistryUtil()
  baseUrl = reg.read("prism_url")
  username = reg.read("prism_username")
  password = reg.read("prism_password")
  if baseUrl = invalid
    print "Missing baseUrl"
    return
  end if
  if username = invalid
    print "Missing username"
    return
  end if
  if password = invalid
    print "Missing password"
    return
  end if

  ' Connect to the PhotoPrism instance
  session = PrismSession({
    baseUrl: baseUrl,
    username: username,
    password: password,
  })
  
  ' To get a random photo, this gets the total number of photos N then picks
  ' a random index [0, N), downloads it, and sleeps for a bit
  print "Getting total num photos"
  config = session.get("/api/v1/config")
  photosCount = config["count"]["photos"]
  print "Found " photosCount " total photos"

  i = 0
  while true
    randomPhotoIdx = Rnd(photosCount)
    print "Choosing random photo " randomPhotoIdx

    results = session.get("/api/v1/photos/view?count=1&offset=" + randomPhotoIdx.ToStr())
    photoData = results[0]
    fit_1920 = photoData["Thumbs"]["fit_1920"]
    thumbUrl = fit_1920["src"]

    destination = "tmp:/image" + randomPhotoIdx.ToStr() + ".jpg"
    backupDestination = "tmp:/image" + randomPhotoIdx.ToStr() + "AAAA.jpg"
    session.downloadImage(thumbUrl, destination)

    ' Check that the file was correctly downloaded
    text = ReadAsciiFile(destination)
    print "Read ascci " Len(text)

    ' The default Len(text) for a successful image is 4 (> 20 is there to detect
    ' the PhotoPrism error SVG), it's probably the JPG magic bytes but whatever
    if Len(text) > 20
      print "Error reading file from " thumbUrl ", skipping"
      ' NOTE: I tried to use the DownloadUrl to get the full resolution, but
      ' the Roku won't display it for some reason, so just skip this image and
      ' select another
    else
      m.top.data = fit_1920
      m.top.status = destination
      intervalS = reg.read("prism_interval_s").toInt()
      sleep(intervalS * 1000)
    endif

    i = i + 1
  end while
end sub
