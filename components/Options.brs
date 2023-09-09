sub init()
    print "Init options"
    m.HostInput = m.top.findNode("HostInput")
    m.UsernameInput = m.top.findNode("UsernameInput")
    m.PasswordInput = m.top.findNode("PasswordInput")
    m.IntervalSecondsInput = m.top.findNode("IntervalSecondsInput")
    m.ConnectionStatusLabel = m.top.findNode("ConnectionStatus")
    m.CheckConnectionButton = m.top.findNode("CheckConnectionButton")
    m.SaveButton = m.top.findNode("SaveButton")
    m.BackButton = m.top.findNode("BackButton")
    m.PrismChecker = m.top.findNode("PrismChecker")
    m.currDialog = invalid
    m.top.status = invalid

    m.PrismChecker.ObserveField("status", "onStatusChange")
    

    m.Group = m.top.findNode("group")
    spaceAfterLabel = 10
    spaceBetweenItems = 20
    m.Group.itemSpacings = [
        spaceAfterLabel,
        spaceBetweenItems,
        spaceAfterLabel,
        spaceBetweenItems,
        spaceAfterLabel,
        spaceBetweenItems,
        spaceAfterLabel,
        spaceBetweenItems + 20,
        spaceBetweenItems,
        spaceBetweenItems,
        spaceBetweenItems
    ]

    m.ignoreNextDialog = false
    m.items = [
        { node: m.HostInput, kind: "text", title: "Host IP", value: "" },
        { node: m.UsernameInput, kind: "text", title: "Username", value: "" },
        { node: m.PasswordInput, kind: "text", title: "Password", value: "" },
        { node: m.IntervalSecondsInput, kind: "text", title: "Interval Between Photos (seconds)", value: "" },
        { node: m.CheckConnectionButton, kind: "check" },
        { node: m.SaveButton, kind: "save" },
        { node: m.BackButton, kind: "back" }
    ]
    ' set default interval if necessary
    reg = RegistryUtil()
    interval = reg.read("prism_interval_s")
    if interval = invalid
        reg.write("prism_interval_s", "8")
    end if

    ' load saved settings
    load()
    setState()
    m.items[0].node.setFocus(true)

    m.pos = 0

end sub

sub updateFocus(delta)
    for i = 0 to m.items.Count() - 1
        if m.items[i].kind = "text"
            m.items[i].node.active = false
            m.items[i].node.setFocus(false)
        end if
    end for

    ' Check the bounds
    if m.pos + delta >= m.items.Count()
        return
    end if
    if m.pos + delta < 0
        return
    end if

    ' Update the focused item
    m.pos = m.pos + delta

    m.items[m.pos].node.setFocus(true)
    if m.items[m.pos].kind = "text"
        m.items[m.pos].node.active = true
    end if
end sub

sub saveState()
    print "Saving values"
    for i = 0 to m.items.Count() - 1
        if m.items[i].kind = "text"
            print "Saving " m.items[i].node.text " (overwrite " m.items[i].value ") for " m.items[i].title
            m.items[i].value = m.items[i].node.text
        end if
    end for
    print "Done saving values to .value"
end sub

sub setState()
    print "Setting values from .value on the textboxes"
    for i = 0 to m.items.Count() - 1
        if m.items[i].kind = "text"
            print "Setting " m.items[i].value
            m.items[i].node.text = m.items[i].value
        end if
    end for
end sub

function getMarkupListData() as object
    data = CreateObject("roSGNode", "ContentNode")

    for i = 1 to 10
        dataItem = data.CreateChild("SimpleListItemData")
        dataItem.posterUrl = "http://devtools.web.roku.com/samples/images/Portrait_2.jpg"
        dataItem.labelText = "This is list item " + stri(i)
        dataItem.label2Text = "Subitem " + stri(i)
    end for
    return data
end function

function getData()
    saveState()
    data = {}
    for i = 0 to m.items.Count() - 1
        if m.items[i].kind = "text"
            print "Setting " m.items[i].value
            data[m.items[i].title] = m.items[i].value
        end if
    end for
    return data
end function

sub load()
    reg = RegistryUtil()
    print "prism_url=" reg.read("prism_url")
    print "prism_username=" reg.read("prism_username")
    print "prism_password=" reg.read("prism_password")
    print "prism_interval_s=" reg.read("prism_interval_s")
    m.HostInput.text = reg.read_or_default("prism_url", "")
    m.UsernameInput.text = reg.read_or_default("prism_username", "")
    m.PasswordInput.text = reg.read_or_default("prism_password", "")
    m.IntervalSecondsInput.text = reg.read_or_default("prism_interval_s", "")

    print "Set m.HostInput.text=" m.HostInput.text " from reg " reg.read_or_default("prism_url", "<none>")
    saveState()
end sub

sub save()
    reg = RegistryUtil()
    data = getData()
    reg.write("prism_url", data["Host IP"])
    reg.write("prism_username", data["Username"])
    reg.write("prism_password", data["Password"])
    reg.write("prism_interval_s", data["Interval Between Photos (seconds)"])
    print "Saving to registry..." data
end sub

sub onStatusChange()
    print "Status changed"
    m.ConnectionStatusLabel.text = "Connection status: " + m.PrismChecker.status
end sub

sub check()
    print "Checking connection"
    save()
    reg = RegistryUtil()

    baseUrl = reg.read("prism_url")
    username = reg.read("prism_username")
    password = reg.read("prism_password")
    intervalS = reg.read("prism_interval_s")

    if baseUrl = invalid
        m.ConnectionStatusLabel.text = "Cannot check connection, Host IP is not set"
        return 
    end if
    if username = invalid
        m.ConnectionStatusLabel.text = "Cannot check connection, username is not set"
        return 
    end if
    if password = invalid
        m.ConnectionStatusLabel.text = "Cannot check connection, password is not set"
        return 
    end if
    if intervalS = invalid
        m.ConnectionStatusLabel.text = "Cannot check connection, interval is not set"
        return 
    end if

    intervalSInt = intervalS.toInt()
    if intervalSInt = 0
        m.ConnectionStatusLabel.text = "Invalid value for photo interval (must be a whole number)"
    end if
    if intervalSInt < 0
        m.ConnectionStatusLabel.text = "Invalid value for photo interval (must be positive)"
    end if

    m.ConnectionStatusLabel.text = "Checking connection to " + baseUrl + "..."
    m.PrismChecker.control = "RUN"
end sub

sub back()
    m.top.status = "back"
end sub

function handleEnter()
    if m.ignoreNextDialog
        m.ignoreNextDialog = false
        m.currDialog = invalid
        return false
    end if

    if m.currDialog <> invalid
        return false
    end if

    curr = m.items[m.pos]
    parent = m.top.getParent()

    if curr.kind = "text"
        dialog = createObject("roSGNode", "CustomKeyboardDialog")
        dialog.title = curr.title
        dialog.kbItem.text = curr.value
        dialog.observeField("value", "onValueChange")
        dialog.observeField("status", "onKBStatusChange")
        parent.dialog = dialog
        m.currDialog = dialog
    else if curr.kind = "check"
        check()
    else if curr.kind = "save"
        save()
    else if curr.kind = "back"
        back()
    end if
    return true
end function

function onKeyEvent(key as string, press as boolean) as boolean
    m.items[m.pos].node.setFocus(true)
    if press and key = "OK"
        return false
    end if

    if not press and key = "OK"
        return handleEnter()
    end if

    if not press and key = "down"
        updateFocus(1)
        return true
    end if
    if not press and key = "up"
        updateFocus(-1)
        return true
    end if
    return false
end function

function onValueChange()
    m.items[m.pos].value = m.currDialog.value
    m.items[m.pos].node.text = m.items[m.pos].value
    saveState()
    setState()
    m.ignoreNextDialog = true
end function

function onKBStatusChange()
    m.ignoreNextDialog = true
end function