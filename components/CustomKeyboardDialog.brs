function init()
    m.buttonArea = m.top.findNode("buttonArea")

    m.top.width = 1552

    m.kbItem = m.top.findNode("kbItem")
    m.kbItem.observeFieldScoped("text", "textChanged")
    m.kbItem.setFocus(true)
    m.top.kbItem = m.kbItem

    m.top.observeFieldScoped("buttonSelected", "printSelectedButtonAndClose")
    m.top.observeFieldScoped("wasClosed", "wasClosedChanged")
end function

sub printFocusButton()
    print "m.buttonArea button ";m.buttonArea.getChild(m.top.buttonFocused).text;" focused"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    print "Handling key from dialog"

    return false
end function

sub printSelectedButtonAndClose()
    button = m.buttonArea.getChild(m.top.buttonSelected).text
    if button = "OK"
        ' Change the 'value' for listeners
        m.top.value = m.kbItem.text
    end if
    m.top.close = true
    m.top.status = "closed"
end sub

sub wasClosedChanged()
    m.top.status = "closed"
end sub
