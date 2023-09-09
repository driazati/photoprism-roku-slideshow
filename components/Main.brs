sub init()
  print "Init for Main"
  m.top.setFocus(true)
  m.SlideShow = m.top.findNode("SlideShow")
  m.Options = m.top.findNode("Options")


  reg = RegistryUtil()
  if reg.read("prism_url") = invalid
    ' No URL, so go straight to options page
    m.SlideShow.visible = false
    m.Options.visible = true
  else
    ' Load the Photos page by default
    m.SlideShow.visible = true
    m.Options.visible = false
  end if



  m.Options.ObserveField("status", "onOptionsStatusChange")

  m.Options.setFocus(true)
end sub

sub onOptionsStatusChange()
  if m.Options.status = "back"
    m.SlideShow.visible = true
    m.Options.visible = false
  end if
end sub


function onKeyEvent(key as string, press as boolean) as boolean
  ' Check if the options screen should be shown
  if press and key = "options"
      print "Showing options screen"

      if m.SlideShow.visible = true
        m.SlideShow.visible = false
        m.Options.visible = true

        m.Options.status = invalid
      end if
    return true
  end if

  ' Check if the slide show should be shown
  if press and key = "back"
    if m.Options.visible = true
      m.SlideShow.visible = true
      m.Options.visible = false
    end if
    return true
  end if

  print "Unhandled key press key=" key
  return false
end function