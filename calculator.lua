require 'asi' -- serial lib
platform.apilevel = "3.0"
local screen = platform.window

local w = screen:width()

local h = screen:height()

local circ = "\\1circle "
local tri = "\\1tri "
local ang = "\\1angle "
local ray = "\\1ray "
local line = '\\1line '
local lineseg = "\\1lineseg "
local righttri = "\\1rtri "
local vector = "\\1vector "
local underline = "\\1title "
local bold = "\\1keyword "
local supersc = "\\1supersc "
local subscr = "\\1subscrp "
local italic = "\\1subhead "


local MessageBox = D2Editor.newRichText()
SendRecieveBox = D2Editor.newRichText()
reading = true 
msArr = {} -- array for messages
--[[ THIS IS THE FORMAT FOR MSARR
{
    {"SENT", "Hey, hows it going?"},
    {"RECIEVED", "We're Typing on calculators, how cool is that?"},
    {"SENT", "Thats pretty cool!"},
    {"RECIEVED", "Did you know that @danielduarte-baird on gihub made this?"},
    {"SENT", "Thats so neat!"},
    {"RECIEVED", "Cya!"},
}
]]--
function paintTable(arr)
    SendRecieveBox:setText("This is the beginning of ur convo")
    for k, v in pairs(arr) do
        if v[1] == "SENT" then
            appendMessageText('s', v[2])
        end
        if v[1] == "RECIEVED" then
            appendMessageText('r', v[2])
        end
    end
end
function addMessage(SorR, message)
    if SorR == 'r' then
        table.insert(msArr, {"RECIEVED", message})
    end
    if SorR == 's' then
        table.insert(msArr, {"SENT", message})
    end
    paintTable(msArr)
    
end
function appendMessageText(SorR, message)
    
    if SorR == 'r' then
        SendRecieveBox:setText(SendRecieveBox:getText() .. "\n" .. bold .. "Amigo: " .. message)
    end
    if SorR == 's' then
        SendRecieveBox:setText(SendRecieveBox:getText() .. "\n" .. "You: " .. message)
    end
end

print("#######LUA CONSOLE###################")
port = nil -- the serial port
string = "searching?" -- just for user interface
pv = "" -- port value, the read line. used to determine what a recieved line is
m = "baihbjg#####!" -- message to send

function on.mouseDown(x, y)
    if x<10 and y<10 then
        MessageBox:setFocus(boolean)
    end
end
--paints
function on.paint(gc)
    gc:drawString(string, 0 , 0)
    gc:fillRect(0, 318, 0, 212) -- w is 0-1023 so normalize by * 318/1023
end
--keymaps

function on.charIn(char)
    string = string .. "\n kd"
    platform.window:invalidate()
    if not port then
        error = asi.startScanning(portFoundCallback)
        string = string .. "\nscanning ..."
        platform.window:invalidate()
        timer.start(1)
        return
    end
    if char == "d" then
        port:disconnect(disconnectCallback)
        return
    end
    if char == "[" then
        paintTable(msArr)
        print("test")
        return
    end
    if char == "s" then
        print(port, port:getName(), port:getState(), port:getIdentifier())
        return
    end
    if char == "r" then
        read()
        return
    end
    if char == "]" then
        read() -- read a line
        return
    end
    if char == "c" then
        port:connect(portConnectCallback)
        return
    end
end

function on.enterKey()
    platform.window:invalidate()
    print(enter)
    write(MessageBox:getText())
    MessageBox:setText("")
end


function on.timer()
   if reading then read() end -- read if reading mode is on
end

function read() -- read one byte/char from serial
    if port then
        print("readFunc")
        port = port:setReadTimeout(40)
        port = port:setReadListener(readCallback)
        error = port:read(1)
        
    end
end
function write(message) -- check that there are no # and if there are then delete, # indicates end of line
    for i = 1, string.len(message) do
        if string.sub(message, i, i) == "#" then
            message = string.sub(message, 1, i-1) .. string.sub(message, i+1, -1)
            write(message)
            return
        end
    end
    if port then 
        print("writ?" .. string.sub(message, 0, -2) .. "#")
        error = port:write(string.sub(message, 0, -2) .. "#") 
    end
end 
function writeCallback()
    print("wrote ")
end
function initMessageBox()
    MessageBox:move(0.05*w, 0.8*h)
    MessageBox:setBorder(2)
    MessageBox:resize(0.9*w, 0.2*h)
    MessageBox:setFocus(true)
    MessageBox:setText("calc")
    MessageBox:setTextChangeListener(messageChangeCallback)
end
function initSendRecieveBox()
    SendRecieveBox:move(0.05*w, 0.05*h)
    :resize(0.9*w, 0.7*h)
    :setBorder(2)
    :setBorderColor(0x296ecf)
    :setColorable(false)
    :setDisable2DinRT(false)
    :setReadOnly(true)
    :setSelectable(true)
    :setTextColor(0x000000)
    :setVisible(true)
    :setText("This is the start of your chain with Amigo")
end
function messageChangeCallback(editor)
    if not(editor:getText()) then return end
    if string.sub(editor:getText(), -1, -1) == "\n" then 
        m = editor:getText()
        addMessage('s', string.sub(editor:getText(), 0, -2))
        write(editor:getText())
        editor:setText("")
        return
    end
end

-- CALLBACKS

function disconnectCallback()
    print("disconnected")
end
function readCallback() -- read serial one at a time and print when you get to a #, recurse is for making it read until one line has been read
   print("peeeeer")
   local val = port:getValue();
   if not(val) then return end
   print("proc")
   print(val)
   pv = pv .. port:getValue()
   if string.sub(pv, -1, -1) == "#" then
        pv = string.sub(pv, 1, -2)
        print(pv, port:getState(), port:getName())
        addMessage('r', pv)
        pv = ""
        return
   end
   read()
end
function portFoundCallback(foundPort) -- print out port data when found, ignore bluetooth/airplay
    initMessageBox()
    initSendRecieveBox()
    port = foundPort
    print('blue', port:getName())
    string = string .. "\n" .. port:getName()
    if port:getName()== "usbmodem141401" or port:getName()== "usbmodem141301" or port:getName()== "usbmodem142301" or port:getName()== "usbmodem142401" or port:getName()== "COM1" or port:getName()== "COM2" then
        asi.stopScanning()
        string = string .. "\nfound"
        port = port:setBaudRate(9600)
        error = port:connect(portConnectCallback) -- set reading to false, not doing that rn
        print(port)
    end
end
function portConnectCallback(port, event) -- state the states and stuff of a port after trying to connect
    print('state: ', port:getState(), port:getName())
    port = port:setWriteListener(writeCallback)
    port = port:setReadListener(readCallback)
end

