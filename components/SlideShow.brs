sub init()
  ' Sync loading keeps from showing a black screen
  m.Image = m.top.findNode("Image")
  m.Image.loadSync = true

  ' Start the downloader and watch for new downloads
  print "observing status"
  m.PrismDownloader = m.top.findNode("PrismDownloader")
  m.PrismDownloader.ObserveField("status", "onStatusChange")
  m.PrismDownloader.control = "RUN"

  ' Get the screen size in pixels
  device = CreateObject("roDeviceInfo")
  sizeData = device.GetDisplaySize()
  screenWidth = sizeData["w"]
  screenHeight = sizeData["h"]

  ' Adjust the loading label and background to fit the screen size
  m.Loading = m.top.findNode("Loading")
  m.BackgroundRectangle = m.top.findNode("BackgroundRectangle")
  m.BackgroundRectangle.height = screenHeight
  m.BackgroundRectangle.width = screenWidth
  m.Loading.height = screenHeight
  m.Width.height = screenHeight
end sub

sub onStatusChange()
  print "Status change, setting image to " + m.PrismDownloader.status

  ' Unless the image perfectly fits the screen it will need to be scaled
  device = CreateObject("roDeviceInfo")
  sizeData = device.GetDisplaySize()
  screenWidth = sizeData["w"]
  screenHeight = sizeData["h"]

  ' Set the image
  m.Loading.visible = false
  m.Image.uri = m.PrismDownloader.status

  ' Scale the image
  srcWidth = m.PrismDownloader.data["w"]
  srcHeight = m.PrismDownloader.data["h"]
  print "Fitting image " srcWidth ", " srcHeight " to a screen of size" screenWidth ", " screenHeight
  width = invalid
  height = invalid
  screenRatio = screenWidth / screenHeight
  srcRatio = srcWidth / srcHeight
  if srcRatio < screenRatio
    ' Landscape image
    height = screenHeight
    width = screenHeight / srcHeight * srcWidth
  else
    ' Portrait image
    width = screenWidth
    height = screenWidth / srcWidth * srcHeight
  end if

  ' Center the image on the screen
  translateX = max((screenWidth - width) / 2, 0)
  translateY = max((screenHeight - height) / 2, 0)

  print "Setting image to WxH=" width "," height " and position X,Y=" translateX "," translateY
  m.Image.translation = [translateX, translateY]
  m.Image.width = width
  m.Image.height = height
end sub

