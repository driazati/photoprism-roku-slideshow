sub init()
    m.top.functionName = "go"
end sub


sub go()
    reg = RegistryUtil()
    baseUrl = reg.read("prism_url")
    username = reg.read("prism_username")
    password = reg.read("prism_password")
    session = PrismSession({
        "baseUrl": baseUrl,
        "username": username,
        "password": password,
    })
    testphotos = session.get("/api/v1/photos/view?count=1")

    if testphotos.Count() = 1
        testphoto = testphotos[0]
        print testphoto
        m.top.status = "ok"
    else
        m.top.status = "Connected, but got unexpected response"
    end if
    
end sub