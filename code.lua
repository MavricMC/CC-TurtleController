//How to return a value
//{"to":"turtle0", "type":"return", "message":"return  turtle.getFuelLevel()"}
local ws, err = http.websocket("ws://localhost:3000")
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
            if msg.type == "code" or msg.type == "return" then
                local func = load(msg.message)
                local ret = func()
                if msg.type == "return" then
                    retur = {to = "website", type = "webreturn", message = tostring(ret)}
                    local returnMsg = json.encode(retur)
                    ws.send(returnMsg)
                    printError("Return msg:", returnMsg)
                end
            end
        end
    end
end
