sub init()
  m.Image = m.top.findNode("Image")
  m.Loading = m.top.findNode("Loading")
  m.BackgroundRectangle = m.top.findNode("BackgroundRectangle")
  m.Image.loadSync = true
  m.PrismDownloader = m.top.findNode("PrismDownloader")

  print "observing status"
  m.PrismDownloader.ObserveField("status", "onStatusChange")
  m.PrismDownloader.control = "RUN"

  device = CreateObject("roDeviceInfo")
  sizeData = device.GetDisplaySize()
  screenWidth = sizeData["w"]
  screenHeight = sizeData["h"]

  m.BackgroundRectangle.height = screenHeight
  m.BackgroundRectangle.width = screenWidth
end sub

sub onStatusChange()
  print "Status change, setting image to " + m.PrismDownloader.status

  device = CreateObject("roDeviceInfo")
  sizeData = device.GetDisplaySize()
  screenWidth = sizeData["w"]
  screenHeight = sizeData["h"]

  srcWidth = m.PrismDownloader.data["w"]
  srcHeight = m.PrismDownloader.data["h"]

  m.Loading.visible = false
  m.Image.uri = m.PrismDownloader.status

  print "Fitting image " srcWidth ", " srcHeight " to a screen of size" screenWidth ", " screenHeight

  width = invalid
  height = invalid
  screenRatio = screenWidth / screenHeight
  srcRatio = srcWidth / srcHeight
  if srcRatio < screenRatio
    ' landscape
    height = screenHeight
    width = screenHeight / srcHeight * srcWidth
  else
    ' portrait
    width = screenWidth
    height = screenWidth / srcWidth * srcHeight
  end if

  translateX = max((screenWidth - width) / 2, 0)
  translateY = max((screenHeight - height) / 2, 0)

  print "Setting image to WxH=" width "," height " and position X,Y=" translateX "," translateY
  m.Image.translation = [translateX, translateY]
  m.Image.width = width
  m.Image.height = height
end sub

