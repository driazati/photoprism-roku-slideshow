sub Main(input as Dynamic)
  startSlideShow()
end sub

sub startSlideShow()
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("Main")
  screen.show()

  while(true)
    msg = wait(0, m.port)
    msgType = type(msg)
    print "Got message" msgType
    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed() then return
    end if
  end while
end sub
