local server = "ws://localhost:8000"
local ws, err = http.websocket(server)
os.loadAPI("turtleController/json.lua")
local id = tostring(os.getComputerID())
local left = false

function getItemIndex(itemName)
    --loops through all slots and checks if there is the chosen item--
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item ~= nil then
            if item.name == itemName then
                return slot
            end
        end
    end
    return false
end

function create()
    local invSlot = getItemIndex("computercraft:turtle_advanced")
    if invSlot == false then
        invSlot = getItemIndex("computercraft:turtle_normal")
    end
    if invSlot ~= false then
        turtle.select(invSlot)
        turtle.place()
        if (turtle.up()) then
            invSlot = getItemIndex("computercraft:disk_drive")
            if invSlot ~= false then
                turtle.select(invSlot)
                turtle.place()
                invSlot = getItemIndex("computercraft:disk")
                if invSlot ~= false then
                    turtle.select(invSlot)
                    turtle.drop()
                    fs.delete("disk/startup.lua")
                    fs.delete("disk/code.lua")
                    fs.delete("disk/json.lua")
                    fs.copy("startup.lua", "disk/code.lua")
                    fs.copy("turtleController/json.lua", "disk/json.lua")
                    fs.copy("turtleController/create.lua", "disk/startup.lua")
                    turtle.down()
                    sleep(1)
                    peripheral.call("front", "turnOn")
                    --dont want to break the turtle just placed if it runs out of fuel--
                    if (turtle.up()) then
                        sleep(1)
                        turtle.suck()
                        turtle.dig()
                        turtle.down()
                    end
                    return true
                end
            end
        end
    end
    return false
end

function sendMine(suc, errr, tagg)
    local up1, up2 = turtle.inspectUp()
    local fwd1, fwd2 = turtle.inspect()
    local down1, down2 = turtle.inspectDown()
    local fuelLevel = turtle.getFuelLevel()
    retur = { to = "website", from = id, type = "move", success = suc, err = errr, tag = tagg, fuel = fuelLevel, up = up1, upD = up2.name, fwd = fwd1, fwdD = fwd2.name, down = down1, downD = down2.name }
    local returnMsg = json.encode(retur)
    ws.send(returnMsg)
    printError("Mine msg:", returnMsg)
end

function tunnel(length)
    for i = 1, length do
        turtle.dig()
        ret, retErr = turtle.forward()
        sendMine(ret, retErr, "forward")
        ret, retErr = turtle.turnLeft()
        sendMine(ret, retErr, "left")
        ret, retErr = turtle.turnRight()
        sendMine(ret, retErrr, "right")
        ret, retErr = turtle.turnRight()
        sendMine(ret, retErr, "right")
        ret, retErr = turtle.turnLeft()
        sendMine(ret, retErr, "left")
    end
end

if err then
    printError(err, "| Reboot in 3 seconds")
    sleep(3)
    os.reboot()
elseif ws then
    local isAdvanced = term.isColour()
    start = { to = "website", from = id, type = "start", advanced = isAdvanced}
    local startMsg = json.encode(start)
    ws.send(startMsg)
    printError("Startup msg:", startMsg)
    while true do
        local m = ws.receive()
        if m == nil then
            printError("Closed | Reboot in 3 seconds")
            sleep(3)
            os.reboot()
        elseif m == "" then
            print("Empty")
            m = "{}"
        else
            print(m)
            local msg = json.decode(m)
            printError(msg.to)
            if msg.to ~= id then
                print("Not for me")
            else
                if msg.type == 'inv' then
                    print(msg.type)
                    local detail = {}
                    for i = 1, 16 do
                        detail[i] = turtle.getItemDetail(i)
                        --print(detail[i])
                    end
                    local slot = turtle.getSelectedSlot()
                    local fuelLevel = turtle.getFuelLevel()
                    retur = { to = "website", from = id, type = "inv", fuel = fuelLevel, selected = slot, slot1 = detail[1], slot2 = detail[2], slot3 = detail[3], slot4 = detail[4], slot5 = detail[5], slot6 = detail[6], slot7 = detail[7], slot8 = detail[8], slot9 = detail[9], slot10 = detail[10], slot11 = detail[11], slot12 = detail[12], slot13 = detail[13], slot14 = detail[14], slot15 = detail[15], slot16 = detail[16] }
                    local returnMsg = json.encode(retur)
                    ws.send(returnMsg)
                    printError("Return msg:", returnMsg)
                elseif msg.type == 'move' then
                    print(msg.type, ":", msg.message)
                    local func = load(msg.message)
                    ret, retErr = func()
                    local up1, up2 = turtle.inspectUp()
                    local fwd1, fwd2 = turtle.inspect()
                    local down1, down2 = turtle.inspectDown()
                    local fuelLevel = turtle.getFuelLevel()
                    retur = { to = "website", from = id, type = "move", success = ret, err = retErr, tag = msg.tag, fuel = fuelLevel, up = up1, upD = up2.name, fwd = fwd1, fwdD = fwd2.name, down = down1, downD = down2.name }
                    local returnMsg = json.encode(retur)
                    ws.send(returnMsg)
                    printError("Return msg:", returnMsg)
                elseif msg.type == 'code' then
                    print(msg.type, ":", msg.message)
                    if msg.tag == "sign" then
                        ret, retErr = turtle.place(msg.message)
                    else
                        func, retErr = load(msg.message)
                        if retErr == nil then
                            local status, suc, erro = pcall(func)
                            if (status) then
                                print("Code run without errors")
                                printError(suc, erro)
                                ret = suc
                                retErr = erro
                            else
                                print("Error in code: ", suc)
                                ret = false
                                retErr = suc
                            end
                            
                        else
                            print("Error loading: ", err)
                            ret = false
                        end
                    end
                    retur = { to = "website", from = id, type = "code", success = ret, err = retErr, tag = msg.tag }
                    local returnMsg = json.encode(retur)
                    ws.send(returnMsg)
                    printError("Return msg:", returnMsg)
                elseif msg.type == 'create' then
                    print(msg.type)
                    local ret = create()
                    retur = { to = "website", from = id, type = "create", success = ret }
                    local returnMsg = json.encode(retur)
                    ws.send(returnMsg)
                    printError("Return msg:", returnMsg)
                elseif msg.type == 'mine' then
                    if msg.tag == "continue" then
                        if (left) then
                            left = false
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErrr, "right")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErr, "left")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErr, "left")
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErrr, "right")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErr, "left")
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErrr, "right")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErr, "left")
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErrr, "right")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErr, "left")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErr, "left")
                        else
                            left = true
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErrr, "left")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErr, "right")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErr, "right")
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErrr, "left")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErr, "right")
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErrr, "left")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErr, "right")
                            turtle.dig()
                            ret, retErr = turtle.forward()
                            sendMine(ret, retErr, "forward")
                            ret, retErr = turtle.turnLeft()
                            sendMine(ret, retErrr, "left")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErr, "right")
                            ret, retErr = turtle.turnRight()
                            sendMine(ret, retErr, "right")
                        end
                    else
                        --set mine direction here later
                        left = false
                    end
                    tunnel(msg.length)
                    retur = { to = "website", from = id, type = "continue", tag = msg.length }
                    local returnMsg = json.encode(retur)
                    ws.send(returnMsg)
                    printError("Continue msg:", returnMsg)
                end
            end
        end
    end
end
