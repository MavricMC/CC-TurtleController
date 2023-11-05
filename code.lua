local ws, err = http.websocket("wss://localhost:3000")
os.loadAPI("turtleController/json.lua")

if err then
    error(err)
elseif ws then
    while true do
        local m = ws.receive()
        term.clear()
        term.setCursorPos(1, 1)
        if m == "" then
            m = "{}"
        end
        print(m)
        local msg = json.decode(m)
        printError(msg.to)
        if msg.to ~= "turtle0" then
            print("Not for me")
        else
            print(msg.type, ":", msg.message)
            if msg.type == "code" then
                local func = load(msg.message)
                local ret, retErr = func()
                retur = {to = "website", type = "webreturn", success = tostring(ret), err = tostring(retErr)}
                local returnMsg = json.encode(retur)
                ws.send(returnMsg)
                printError("Return msg:", returnMsg)
            elseif msg.type == "sign" then
                local ret, retErr = turtle.place(msg.message)
                retur = {to = "website", type = "webreturn", success = tostring(ret), err = tostring(retErr)}
                local returnMsg = json.encode(retur)
                ws.send(returnMsg)
            end
        end
    end
end
