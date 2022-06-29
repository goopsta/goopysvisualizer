local muted = {}

local notif

local runService = game:GetService("RunService")

local eventLogs = {}



local function createDrawing(type, prop)
   local obj = Drawing.new(type)
   if prop then
       for i,v in next, prop do
           obj[i] = v
       end
   end
   return obj
end


function createEventLog(text)
   local eventLog = {
       text = "gv | "..text,
       startTick = tick(),
       lifeTime = 5,
       shadowText = createDrawing("Text", {
           Center = false,
           Outline = false,
           Color = Color3.new(),
           Transparency = 200/255,
           Text = "gv | "..text,
           Size = 13,
           Font = 2,
           Visible = false
       }),
       mainText = createDrawing("Text", {
           Center = false,
           Outline = false,
           Color = Color3.new(1, 1, 1),
           Transparency = 1,
           Text = "gv | "..text,
           Size = 13,
           Font = 2,
           Visible = false
       })
   }

   function eventLog:Destroy()
       local shadowTextOrigin = self.shadowText.Position
       local mainTextOrigin = self.mainText.Position
       local shadowTextTrans = self.shadowText.Transparency
       local mainTextTrans = self.mainText.Transparency
       for i = 0, 1, 1/60 do
           self.shadowText.Position = shadowTextOrigin:Lerp(Vector2.new(), i)
           self.mainText.Position = mainTextOrigin:Lerp(Vector2.new(), i)
           self.shadowText.Transparency = shadowTextTrans * (1 - i)
           self.mainText.Transparency = mainTextTrans * (1 - i)
           runService.RenderStepped:Wait()
       end
       self.mainText:Remove()
       self.shadowText:Remove()
       self.mainText = nil
       self.shadowText = nil
       table.clear(self)
       self = nil
   end


   table.insert(eventLogs, eventLog)
   return eventLog
end




runService.RenderStepped:Connect(function(deltaTime)
   local count = #eventLogs
   local removedFirst = false
   for i = 1, count do
       local curTick = tick()
       local eventLog = eventLogs[i]
       if eventLog then
           if curTick - eventLog.startTick > eventLog.lifeTime then
               task.spawn(eventLog.Destroy, eventLog)
               table.remove(eventLogs, i)
           elseif count > 10 and not removedFirst then
               removedFirst = true
               local first = table.remove(eventLogs, 1)
               task.spawn(first.Destroy, first)
           else
               local previousEventLog = eventLogs[i - 1]
               local basePosition
               if previousEventLog then
                   basePosition = Vector2.new(4, previousEventLog.mainText.Position.y + previousEventLog.mainText.TextBounds.y + 1)
               else
                   basePosition = Vector2.new(4, 400)
               end
               eventLog.shadowText.Position = basePosition + Vector2.new(1, 1)
               eventLog.mainText.Position = basePosition
               eventLog.shadowText.Visible = true
               eventLog.mainText.Visible = true
           end
       end
   end
end)

notif = createEventLog

-- filesystem stuff I HATE IT --
if not isfolder("goopysvisualizer") then
    notif('couldnt find "goopysvisualizer", creating folder...')
    makefolder("goopysvisualizer")
    wait(0.5)
end


if not isfolder("goopysvisualizer/audiolist") then
    notif('couldnt find "goopysvisualizer/audiolist", creating folder...')
    makefolder("goopysvisualizer/audiolist")
    wait(0.5)
end

wait(0.5)

if not isfile("goopysvisualizer/startup.mp3") then
    notif('couldnt find "goopysvisualizer/startup.mp3", creating file...')
    notif('getting "startup.mp3" from "https://goopy.club/gv/assets/startup.mp3"')
    local soundAsset = game:HttpGet("https://goopy.club/gv/assets/startup.mp3")
    writefile("goopysvisualizer/startup.mp3", game:HttpGet("https://goopy.club/gv/assets/startup.mp3"))
    wait(0.5)
end

if not isfolder("goopysvisualizer/audiolist/audios") then
    notif('couldnt find "goopysvisualizer/audiolist/audios", creating folder...')
    makefolder("goopysvisualizer/audiolist/audios")
    wait(0.5)
end

if not isfile("goopysvisualizer/audiolist/audios/rainingtacos.txt") then
    notif('couldnt find "goopysvisualizer/audiolist/audios/rainingtacos.txt", creating file...')
    writefile("goopysvisualizer/audiolist/audios/rainingtacos.txt", "142376088")
    wait(0.5)
end


local startup = Instance.new("Sound")
startup.SoundId = getsynasset("goopysvisualizer/startup.mp3")
startup.Parent = workspace
startup.Playing = true
startup.Volume = 5
startup:Play()

-- user stuff

printconsole("gv has been executed!")

-- v2 cuz this shit retarded fr

--[[
A start of something ne
]]

--[[
todo list:
everything
massplay
dupe
normal play 
sync
autosync
]]

local http = game:GetService("HttpService")
local plrs = game:GetService("Players")
local all  = plrs:GetPlayers()
local lp   = plrs.LocalPlayer



notif("welcome to goopy's visualizer, "..lp.DisplayName.."!")
notif("current build: v2 release")
notif("use /cmds to see your commands.")

-- functions

-- is radio equipped function
function radioEquipped(plr)
    if plr.Character:FindFirstChild("BoomBox") then
        return true
    else
        return false
    end
end

-- equip function

function equip(tool)
    tool.Parent = lp.Character 
end

-- play function

function play(id)
    if radioEquipped(lp) == true then
        game:GetService("Players").LocalPlayer.Character.BoomBox.Remote:FireServer("PlaySong", ""..id)
    else
        notif("equip your boombox before running this command!")
    end
end

-- massplay function 
function massplay(id)
    for i,v in pairs(lp.Backpack:GetChildren()) do
        if v.Name == "BoomBox" then
            equip(v)
            v.Remote:FireServer("PlaySong", ""..id)
            notif("boombox "..i.. " is now playing : "..id.."!")
        end
    end
    wait(0.5)
    sync()
    notif("successfully massplayed : "..id)
end

-- sync function

function sync()
    for i,v in pairs(lp.Character:GetChildren()) do
        if v.Name == "BoomBox" then
            v.Handle.Sound.TimePosition = 0
        end
    end
end

-- dupe function 

function dupe(num)
    local SAVE_CF = lp.Character.HumanoidRootPart.CFrame
    local RS = game:GetService('RunService').RenderStepped
    for i = 1,num do
        local start = tick()
        local dropped_tools = {}
        local CHAR = lp.Character
        lp.Character = Clone
        lp.Character = CHAR
        repeat RS:Wait() until tick() - start >= 4.8
        lp.Character.HumanoidRootPart.CFrame = SAVE_CF + Vector3.new(0,10000,0)
        repeat RS:Wait() until tick() - start >= 4.9
        for _,tool in next, lp.Backpack:GetChildren() do
                tool.Parent = lp.Character
        end
        for _, tool in next, lp.Character:GetChildren() do
                if tool:IsA'Tool' then
                        tool.Parent = game.Workspace
                        table.insert(dropped_tools, tool)
                end
        end
        lp.Character:BreakJoints()
        notif("dropped a boombox ( "..i.." | "..num.." )")
        lp.CharacterAdded:Wait()
        for _, tool in next, dropped_tools do
            lp.Character:WaitForChild'Humanoid':EquipTool(tool)
        end
        lp.Character:WaitForChild('HumanoidRootPart').CFrame = SAVE_CF
    end
end

-- get plr function v
function getPlayer(Input)
    for _, Player in ipairs(all) do
        if (string.lower(Input) == string.sub(string.lower(Player.Name), 1, #Input)) then
            return Player;
        end
    end
end

-- grab function v 
function grab(plr)
    notif(plr.Name.." is currently playing : "..string.sub(plr.Character.BoomBox.Handle.Sound.SoundId, 33))
    wait(0.1)
    setclipboard(tostring(string.sub(plr.Character.BoomBox.Handle.Sound.SoundId, 33)))
    notif("the id has been copied to your clipboard!")
end

-- mute function v 
function mute(plr)
    plr.Character:WaitForChild("BoomBox").Handle.Sound.Playing = false
end

-- mute thread v 
spawn(function()
    while task.wait(0.1) do
        for i,v in pairs(muted) do
            mute(v)
        end
    end
end)

-- commands start here

--[[ 

cmd template v

lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/cmd" then
        
    end
end)

]]


-- cmds cmd v
lp.Chatted:connect(function(msg)
local args = string.split(msg, " ")
    if args[1] == "/cmds" then
        print([[
                
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
                                
         __________________________________________________________
        | goopy.club/gv                                        - × |
        |__________________________________________________________|
        | cmds     | prints this command menu                      |
        | mass     | mass (id), massplays id                       |
        | play     | play (id), plays id                           |
        | dupe     | dupe (num), dupes num amt                     |
        | rmute    | rmute (plr), mutes player                     |
        | runmute  | runmute (plr), unmutes player                 |
        | demesh   | demesh, demeshes current tool                 |
        | sync     | manually sync current boxes                   |
        | grab     | grab (plr) copies plr's song id               |
        | playlist | playlist (songname), plays from audios folder |
        |__________|_______________________________________________|
        
        goopy's visualizer | ]]..lp.DisplayName" | "..os.date("%X",os.time()).. " " ..os.date("%p",os.time()).. [[


























]])
        notif("printed the command menu!")
        notif("check your console by pressing f9.")
    end
end)

-- massplay cmd v 
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/mass" then
        massplay(args[2])
    end
end)

-- sync cmd v 
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/sync" then
        sync()
    end
end)

-- demesh cmd v 
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/demesh" then
        demesh()
    end
end)

-- dupe cmd v 
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/dupe" then
        dupe(args[2])
        notif("duped "..args[2].." boomboxes!")
    end
end)

--grab cmd v
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/grab" then
        grab(getPlayer(args[2]))
    end
end)

--playlist cmd v 
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/playlist" then
        for i,v in pairs(listfiles("goopysvisualizer/audiolist/audios")) do
            print(i,v)
            print(string.sub(tostring(v), 35))
            if args[2] == string.sub(tostring(v), 35) then
                if readfile(v) == " " or "" then
                    print("readfile: "..readfile(v))
                    massplay(readfile(v))
                    notif("successfully played "..args[2].."!")
                end
            end
        end
    end
end)

-- mute cmd v
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/rmute" then
        table.insert(muted, 1, getPlayer(args[2]))
    end
end)

-- unmute cmd v
lp.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    if args[1] == "/runmute" then
        for i,v in pairs(all) do
            if v.Name == getPlayer(args[2]).Name then
                table.remove(muted, v)
            end
        end
    end
end)



local signalModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Signal/main/Manager.lua"))()
local manager = signalModule.new()

local secret = "goopy visualizer awsome wow amazing very awsome very good very nice"

local users1 = {}
local AllChatType = Enum.PlayerChatType.All

manager:Add("ExploiterJoined")

local ChatConnection
ChatConnection = plrs.PlayerChatted:Connect(function(chattype, plr, msg, target)
    if (Message == secret and chattype == AllChatType and target == nil and not table.find(users1, plr)) then
        table.insert(users1, plr)

        plrs:Chat(secret)

        manager:Fire("ExploiterJoined", plr)
    end
end)


manager:Connect("ExploiterJoined", function(plr)
    if plr.Name ~= lp.Name then
        notif("goopy's visualizer user "..plr.Name.." is in the server!")
    end
end)

plrs:Chat(secret)

















