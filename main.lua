-- main.lua
-- A combined main that uses: menu.lua & survey.lua (optional),
-- plus the overshadow logic, day/night, quiz, rooftop, etc.

-- If you want a "menu" or "survey" state:
require("menu")   -- if you have menu.lua
require("survey") -- if you have survey.lua

local solarSystem   = require("solarSystem")
local gameFeatures  = require("gameFeatures")
local cash          = require("cash")

-- We'll control states: "menu", "survey", or "play" for the main overshadow logic
GameState = "menu"

--------------------------------
-- 1. Globals for the overshadow logic
--------------------------------
local player = { x=100,y=450, width=40,height=60, speed=200 }
local showSettings=false
local showStore=false
local showQuiz=false
local showDialog=false
local showIronMan=false
local dialogText=""

local isNight=false
local dayTimer=0
local dayDuration=120
local nightDuration=120

local batteryCapacity=1000
local batteryEnergy=0
local batteryChargeRate=2
local batteryTimer=0

local wireLevels = {"Normal","Good","Best"}
local solarLevels= {"Normal","Good","Best"}
local wirePrices = {0,50,100}
local solarPrices= {0,200,300}
local currentWireLevel=1
local currentSolarLevel=1

local upgradedWireOnce=false
local upgradedSolarOnce=false

local temperature=25  -- for AC
local AC_ON=false

-- Appliances
local masterAppliances={
  { name="Lights",    x=150,y=350,width=50,height=50,energy=0,requiredEnergy=20,level=1 },
  { name="Fans",      x=350,y=350,width=50,height=50,energy=0,requiredEnergy=30,level=1 },
  { name="Heater",    x=550,y=350,width=50,height=50,energy=0,requiredEnergy=40,level=2 },
  { name="Computers", x=750,y=350,width=50,height=50,energy=0,requiredEnergy=50,level=2 },
  { name="AirCond",   x=300,y=200,width=50,height=50,energy=0,requiredEnergy=50,level=3,auto=true }
}

-- Rooftop
local showRooftop=false
local portal={ x=900,y=500,width=50,height=50 }
local solarPanelImage=nil
local solarPanels={
  { x=200,y=200,width=80,height=50,isInShadow=false,wireThickness=2 },
}
local selectedPanelIndex=nil

local clouds={}
local cloudSpawnTimer=0
local cloudSpawnInterval=25
local wires={}

-- Quizzes
local quizAllQuestions={
  { question="What is the main source of solar power?", choices={"Wind","Sun","Water"}, correct=2 },
  { question="Which unit measures voltage?",           choices={"Amp","Volt","Watt"},  correct=2 },
  { question="Which measure is for power?",            choices={"Volts","Amps","Watts"},correct=3 },
  { question="Which measure is for energy over time?", choices={"Watt-hour","Amp-sec","Volt-min"}, correct=1 }
}
local quizRound={}
local quizIndex=1
local selectedChoice=1
local quizMessage=""
local quizPoints=0
local QUIZ_GOAL=300
local QUIZ_QUESTIONS_PER_SESSION=5
local answeredCount=0
local quizUpgradesLeft=0

-- IronMan
local ironmanImage=nil
local ironManText="It’s not about the suit—it's about you!"

-- Classroom & music
local classroomImage=nil
local backgroundMusic=nil
local volume=0.5
local musicMuted=false

-- Settings & Store
local settings={"New Game","Store","Take Quiz","Sound: ON","Quit"}
local selectedSetting=1

local storeItems={"Upgrade Wire","Upgrade Solar","Back"}
local selectedStoreItem=1

-------------------------------------------------------------------------------
-- local function getGameLevel
-------------------------------------------------------------------------------
local function getGameLevel()
  if currentWireLevel>=3 and currentSolarLevel>=3 then
    return 3
  elseif currentWireLevel>=2 and currentSolarLevel>=2 then
    return 2
  else
    return 1
  end
end

-- returns all appliances up to current level
local function getActiveAppliances()
  local lvl=getGameLevel()
  local list={}
  for _,ap in ipairs(masterAppliances) do
    if ap.level<=lvl then
      table.insert(list, ap)
    end
  end
  return list
end

-------------------------------------------------------------------------------
-- love.load
-------------------------------------------------------------------------------
function love.load()
  if Menu and Menu.load then Menu:load() end
  if Survey and Survey.load then Survey:load() end

  love.window.setMode(1000,600)
  love.window.setTitle("Solar Power School Game")

  classroomImage=love.graphics.newImage("classroom.png")
  ironmanImage  =love.graphics.newImage("ironman.png")
  solarPanelImage=love.graphics.newImage("solar.png")

  backgroundMusic=love.audio.newSource("solar_background_music.mp3","stream")
  backgroundMusic:setLooping(true)
  backgroundMusic:setVolume(volume)
  love.audio.play(backgroundMusic)

  solarSystem.init()
  gameFeatures.init()
  cash.init()

  -- ensure at least 2 panels
  while #solarPanels<2 do
    table.insert(solarPanels,{
      x=200+(#solarPanels*120), y=200,
      width=80,height=50, isInShadow=false, wireThickness=2
    })
  end
end

-------------------------------------------------------------------------------
-- love.update
-------------------------------------------------------------------------------
function love.update(dt)
  if GameState=="menu" then
    if Menu and Menu.update then Menu:update(dt) end
    return
  elseif GameState=="survey" then
    if Survey and Survey.update then Survey:update(dt) end
    return
  end

  -- Otherwise, we are in "play" state. (If you want that logic.)
  if showDialog or showSettings or showStore or showQuiz or showIronMan then
    return
  end

  local lvl = getGameLevel()

  -- possibly add new panels
  while #solarPanels<(lvl+1) do
    table.insert(solarPanels,{
      x=100+(#solarPanels*120), y=200,
      width=80,height=50,isInShadow=false,wireThickness=2
    })
  end

  -- day/night
  updateDayNight(dt)

  if not isNight then
    batteryTimer=batteryTimer+dt
    if batteryTimer>=1 then
      batteryEnergy=math.min(batteryEnergy+ batteryChargeRate, batteryCapacity)
      batteryTimer=0
    end
    solarSystem.update(dt)
  end

  -- level3 AC
  if lvl>=3 then
    if temperature>28 then AC_ON=true else AC_ON=false end
    for _,ap in ipairs(masterAppliances) do
      if ap.name=="AirCond" and ap.auto then
        if AC_ON then
          if not isNight and solarSystem.getEnergy()>=ap.requiredEnergy then
            solarSystem.setEnergy(solarSystem.getEnergy()-ap.requiredEnergy)
            ap.energy=ap.energy+ap.requiredEnergy
          elseif isNight and batteryEnergy>=ap.requiredEnergy then
            batteryEnergy=batteryEnergy-ap.requiredEnergy
            ap.energy=ap.energy+ap.requiredEnergy
          end
        end
      end
    end
  end

  -- If not on rooftop, let player move
  if not showRooftop then
    -- clamp
    player.x=math.min(math.max(player.x,0),1000-player.width)
    player.y=math.min(math.max(player.y,0),600-player.height)
    if love.keyboard.isDown("right") then
      player.x=math.min(player.x+player.speed*dt,1000-player.width)
    elseif love.keyboard.isDown("left") then
      player.x=math.max(player.x-player.speed*dt,0)
    end
    if love.keyboard.isDown("up") then
      player.y=math.max(player.y-player.speed*dt,0)
    elseif love.keyboard.isDown("down") then
      player.y=math.min(player.y+player.speed*dt,600-player.height)
    end
  else
    -- rooftop
    cloudSpawnTimer=cloudSpawnTimer+dt
    if cloudSpawnTimer>=cloudSpawnInterval then
      cloudSpawnTimer=0
      spawnCloud()
    end

    -- move clouds
    for i=#clouds,1,-1 do
      clouds[i].x=clouds[i].x-(clouds[i].speed*dt)
      if clouds[i].x+clouds[i].width<0 then
        table.remove(clouds,i)
      end
    end

    -- overshadow
    for _,pnl in ipairs(solarPanels) do
      local old=pnl.isInShadow
      pnl.isInShadow=false
      for _,c in ipairs(clouds) do
        if rectOverlap(pnl.x,pnl.y,pnl.width,pnl.height, c.x,c.y,c.width,c.height) then
          pnl.isInShadow=true
          if not old then
            openDialog("Warning: A solar panel is overshadowed!")
          end
          break
        end
      end
    end

    -- move selected panel
    if selectedPanelIndex then
      local sp=solarPanels[selectedPanelIndex]
      if love.keyboard.isDown("w") then sp.y=sp.y-100*dt end
      if love.keyboard.isDown("s") then sp.y=sp.y+100*dt end
      if love.keyboard.isDown("a") then sp.x=sp.x-100*dt end
      if love.keyboard.isDown("d") then sp.x=sp.x+100*dt end
    end
  end
end

-------------------------------------------------------------------------------
-- love.draw
-------------------------------------------------------------------------------
function love.draw()
  if GameState=="menu" then
    if Menu and Menu.draw then Menu:draw() end
    return
  elseif GameState=="survey" then
    if Survey and Survey.draw then Survey:draw() end
    return
  end

  -- else the "play" scene
  if showRooftop then
    drawRooftopScene()
  else
    drawMainFloor()
  end
end

function drawMainFloor()
  love.graphics.setColor(1,1,1)
  if classroomImage then
    love.graphics.draw(classroomImage,0,0)
  end
  if isNight then
    love.graphics.setColor(0,0,0,0.4)
    love.graphics.rectangle("fill",0,0,1000,600)
  end

  -- student
  love.graphics.setColor(1,1,1)
  drawPixelatedStudent(player.x,player.y)

  -- appliances
  local apps=getActiveAppliances()
  for _,a in ipairs(apps) do
    love.graphics.setColor(1,1,0)
    love.graphics.rectangle("fill", a.x,a.y, a.width,a.height)
    love.graphics.setColor(0,0,0)
    love.graphics.print(a.name..": "..a.energy.."/"..a.requiredEnergy, a.x+5,a.y+5)
  end

  love.graphics.setColor(1,1,1)
  love.graphics.print( isNight and "Nighttime" or "Daytime", 20,5 )
  local sVal=(isNight and "(off)" or (math.floor(solarSystem.getEnergy()).." units"))
  love.graphics.print("Solar: "..sVal, 20,25)
  love.graphics.print("Battery: "..math.floor(batteryEnergy).."/"..batteryCapacity, 20,45)

  -- portal
  love.graphics.setColor(1,0,1)
  love.graphics.rectangle("fill", portal.x,portal.y, portal.width,portal.height)
  love.graphics.setColor(1,1,1)
  love.graphics.print("Rooftop (SPACE)", portal.x-80, portal.y-20)

  -- menus
  if showSettings then
    drawMenu(settings, selectedSetting)
  elseif showStore then
    drawMenu(storeItems, selectedStoreItem)
  elseif showQuiz then
    drawQuiz()
  end

  if showDialog then
    drawDialogBox()
  end
  if showIronMan then
    drawIronManDialog()
  end
end

function drawRooftopScene()
  love.graphics.setColor(0.5,0.5,0.5)
  love.graphics.rectangle("fill",0,0,1000,600)

  -- clouds
  for _,c in ipairs(clouds) do
    love.graphics.setColor(0.9,0.9,0.9)
    local r=c.height/2
    local cy=c.y+r
    local cx=c.x+(c.width/2)
    love.graphics.circle("fill", c.x+(c.width*0.3), cy, r)
    love.graphics.circle("fill", c.x+(c.width*0.7), cy, r)
    love.graphics.circle("fill", cx, cy, r)
  end

  -- panels
  for i,p in ipairs(solarPanels) do
    local alpha=(p.isInShadow and 0.5) or 1
    love.graphics.setColor(1,1,1,alpha)
    local scaleX = p.width/(solarPanelImage:getWidth())
    local scaleY = p.height/(solarPanelImage:getHeight())
    love.graphics.draw(solarPanelImage, p.x,p.y, 0,scaleX,scaleY)

    if selectedPanelIndex==i then
      love.graphics.setColor(1,1,1)
      love.graphics.rectangle("line",p.x,p.y,p.width,p.height)
    end
  end

  -- wires
  for _,w in ipairs(wires) do
    local pi=w.panelIndex
    local sp=solarPanels[pi]
    local px,py= sp.x+sp.width/2, sp.y+sp.height/2
    local gx,gy=85,535
    local thick=(currentWireLevel==3 and 6) or (currentWireLevel==2 and 4) or 2
    if currentWireLevel==3 then
      love.graphics.setColor(1,0,0)
    elseif currentWireLevel==2 then
      love.graphics.setColor(0,1,0)
    else
      love.graphics.setColor(1,1,1)
    end
    love.graphics.setLineWidth(thick)
    love.graphics.line(px,py,gx,gy)
  end

  -- generator
  love.graphics.setColor(0.8,0.2,0.2)
  love.graphics.rectangle("fill",50,500,70,70)
  love.graphics.setColor(1,1,1)
  love.graphics.print("GEN",60,530)

  love.graphics.setColor(1,1,1)
  love.graphics.print("Rooftop:\n- Click panel => select\n- WASD => move\n- Cmd+Shift+Click => wire\n- ESC => exit\n- overshadow => 50% efficiency",
                      20,20)

  if showSettings then
    drawMenu(settings,selectedSetting)
  elseif showStore then
    drawMenu(storeItems,selectedStoreItem)
  elseif showQuiz then
    drawQuiz()
  end

  if showDialog then
    drawDialogBox()
  end
  if showIronMan then
    drawIronManDialog()
  end
end

-------------------------------------------------------------------------------
-- Key + Mouse
-------------------------------------------------------------------------------
function love.keypressed(key, scancode, isrepeat)
  if GameState=="menu" and Menu and Menu.keypressed then
    Menu:keypressed(key)
    return
  elseif GameState=="survey" and Survey and Survey.keypressed then
    Survey:keypressed(key)
    return
  end

  if showDialog then
    if key=="return" or key=="space" then
      closeDialog()
    end
    return
  end
  if showIronMan then
    if key=="return" or key=="space" then
      closeIronManDialog()
    end
    return
  end

  if showRooftop then
    if key=="escape" then
      showRooftop=false
    end
    return
  end

  if showSettings then
    handleSettingsKey(key)
    return
  elseif showStore then
    handleStoreKey(key)
    return
  elseif showQuiz then
    handleQuizKey(key)
    return
  else
    if key=="escape" then
      showSettings=not showSettings
    elseif key=="space" then
      -- check portal
      if rectOverlap(player.x,player.y,player.width,player.height,
                     portal.x,portal.y,portal.width,portal.height) then
        showRooftop=true
      else
        allocateEnergyToAppliance()
      end
    end
  end
end

function love.mousepressed(x,y,button,istouch,presses)
  if GameState~="menu" and GameState~="survey" and showRooftop and button==1 then
    local shiftHeld=(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))
    local cmdHeld  =(love.keyboard.isDown("lgui") or love.keyboard.isDown("rgui"))
    if shiftHeld and cmdHeld then
      -- wire
      local bestIndex=nil
      local bestDist=999999
      for i,p in ipairs(solarPanels) do
        local cx=p.x+p.width/2
        local cy=p.y+p.height/2
        local dx=x-cx
        local dy=y-cy
        local dist=dx*dx+dy*dy
        if dist<bestDist then
          bestDist=dist
          bestIndex=i
        end
      end
      if bestIndex then
        table.insert(wires,{ panelIndex=bestIndex })
        openDialog("Wired panel #"..bestIndex.." => generator.")
      end
    else
      -- select panel
      for i,p in ipairs(solarPanels) do
        if x>=p.x and x<=p.x+p.width and y>=p.y and y<=p.y+p.height then
          selectedPanelIndex=i
          return
        end
      end
      selectedPanelIndex=nil
    end
  end
end

-------------------------------------------------------------------------------
-- Allocation
-------------------------------------------------------------------------------
local function anyWireExists()
  return (#wires>0)
end

function allocateEnergyToAppliance()
  if not anyWireExists() then
    openDialog("No solar panel is wired to generator!")
    return
  end
  local threshold=60
  local apps=getActiveAppliances()
  local usedAny=false
  for _,ap in ipairs(apps) do
    local dx=(player.x+player.width/2)-(ap.x+ap.width/2)
    local dy=(player.y+player.height/2)-(ap.y+ap.height/2)
    local dist=math.sqrt(dx*dx+dy*dy)
    if dist<threshold then
      if isNight then
        if batteryEnergy>=ap.requiredEnergy then
          batteryEnergy=batteryEnergy-ap.requiredEnergy
          ap.energy=ap.energy+ap.requiredEnergy
          openDialog("Allocated "..ap.requiredEnergy.." battery => "..ap.name)
          usedAny=true
        else
          openDialog("Not enough battery for "..ap.name)
        end
      else
        -- overshadow factor
        local overshadow=1
        for _,pnl in ipairs(solarPanels) do
          if pnl.isInShadow then
            overshadow=0.5
            break
          end
        end
        local cost=math.floor(ap.requiredEnergy/overshadow)
        local have=solarSystem.getEnergy()
        if have>=cost then
          solarSystem.setEnergy(have-cost)
          ap.energy=ap.energy+ap.requiredEnergy
          local extra=(overshadow<1) and " (2x cost due to shadow)" or ""
          openDialog("Allocated "..ap.requiredEnergy.." solar => "..ap.name..extra)
          usedAny=true
        else
          openDialog("Not enough solar for "..ap.name)
        end
      end
    end
  end

  if not usedAny then
    openDialog("No appliance is near enough to allocate energy!")
  else
    -- check level unlock
    local function allAllocated()
      for _,ap in ipairs(apps) do
        if ap.energy<ap.requiredEnergy then return false end
      end
      return true
    end

    if allAllocated() and upgradedWireOnce and upgradedSolarOnce and getGameLevel()==1 then
      currentWireLevel=2
      currentSolarLevel=2
      openDialog("Level 2 Unlocked! Heater & Computers available.")
    elseif getGameLevel()==2 and allAllocated() and (currentWireLevel>=3) and (currentSolarLevel>=3) then
      openDialog("Level 3 Unlocked => AirCond if hot.")
    end
  end
end

-------------------------------------------------------------------------------
-- Menu Handlers
-------------------------------------------------------------------------------
function handleSettingsKey(key)
  if key=="up" then
    selectedSetting=selectedSetting-1
    if selectedSetting<1 then selectedSetting=#settings end
  elseif key=="down" then
    selectedSetting=selectedSetting+1
    if selectedSetting>#settings then selectedSetting=1 end
  elseif key=="return" then
    if selectedSetting==1 then
      -- new game
      resetGame()
      -- maybe we go directly to "play" or "survey"? Up to you
      -- let's say "play"
      GameState="play"
      showSettings=false
    elseif selectedSetting==2 then
      showStore=true
      showSettings=false
    elseif selectedSetting==3 then
      startQuiz()
      showQuiz=true
      showSettings=false
    elseif selectedSetting==4 then
      musicMuted=not musicMuted
      backgroundMusic:setVolume(musicMuted and 0 or volume)
      settings[4]=(musicMuted and "Sound: OFF" or "Sound: ON")
    elseif selectedSetting==5 then
      love.event.quit()
    end
  end
end

function handleStoreKey(key)
  if key=="up" then
    selectedStoreItem=selectedStoreItem-1
    if selectedStoreItem<1 then selectedStoreItem=#storeItems end
  elseif key=="down" then
    selectedStoreItem=selectedStoreItem+1
    if selectedStoreItem>#storeItems then
      selectedStoreItem=1
    end
  elseif key=="return" then
    if selectedStoreItem==1 then
      -- upgrade wire
      if quizUpgradesLeft<1 then
        openDialog("No quiz upgrade left. Pass quiz first.")
        return
      end
      if currentWireLevel<3 then
        local price=wirePrices[currentWireLevel+1]
        if cash.getUnits()>=price then
          cash.spendUnits(price)
          currentWireLevel=currentWireLevel+1
          gameFeatures.setWireLevel(currentWireLevel)
          quizUpgradesLeft=quizUpgradesLeft-1
          upgradedWireOnce=true
          openDialog("Wire => L"..currentWireLevel)
        else
          openDialog("Not enough money!")
        end
      else
        openDialog("Wire is already best!")
      end
    elseif selectedStoreItem==2 then
      -- upgrade solar
      if quizUpgradesLeft<1 then
        openDialog("No quiz upgrade left. Pass quiz first.")
        return
      end
      if currentSolarLevel<3 then
        local price=solarPrices[currentSolarLevel+1]
        if cash.getUnits()>=price then
          cash.spendUnits(price)
          currentSolarLevel=currentSolarLevel+1
          gameFeatures.setSolarLevel(currentSolarLevel)
          quizUpgradesLeft=quizUpgradesLeft-1
          upgradedSolarOnce=true
          openDialog("Solar => L"..currentSolarLevel)
        else
          openDialog("Not enough money!")
        end
      else
        openDialog("Solar is already best!")
      end
    elseif selectedStoreItem==3 then
      showStore=false
    end
  elseif key=="escape" then
    showStore=false
  end
end

-------------------------------------------------------------------------------
-- Quiz
-------------------------------------------------------------------------------
local function shuffle(t)
  for i=#t,2,-1 do
    local j=math.random(i)
    t[i],t[j]=t[j],t[i]
  end
end

function startQuiz()
  quizPoints=0
  quizMessage=""
  selectedChoice=1
  answeredCount=0
  quizRound={}

  local indices={}
  for i=1,#quizAllQuestions do indices[i]=i end
  shuffle(indices)
  for i=1,QUIZ_QUESTIONS_PER_SESSION do
    quizRound[i]=quizAllQuestions[indices[i]]
  end
  quizIndex=1
  showQuiz=true
end

function handleQuizKey(key)
  if key=="up" then
    selectedChoice=selectedChoice-1
    if selectedChoice<1 then
      selectedChoice=#quizRound[quizIndex].choices
    end
  elseif key=="down" then
    selectedChoice=selectedChoice+1
    if selectedChoice>#quizRound[quizIndex].choices then
      selectedChoice=1
    end
  elseif key=="return" then
    checkQuizAnswer()
  elseif key=="escape" then
    showQuiz=false
  end
end

function checkQuizAnswer()
  local q=quizRound[quizIndex]
  if selectedChoice==q.correct then
    quizPoints=quizPoints+100
    quizMessage="Correct! +100"
  else
    quizPoints=quizPoints-100
    quizMessage="Wrong! -100"
  end
  answeredCount=answeredCount+1

  if answeredCount>=QUIZ_QUESTIONS_PER_SESSION then
    finalizeQuiz()
  else
    quizIndex=quizIndex+1
    selectedChoice=1
  end
end

function finalizeQuiz()
  quizMessage=quizMessage.."\nQuiz ended. ESC to exit."
  openIronManDialog()
  -- must get all 5 correct => 500
  if quizPoints>=QUIZ_QUESTIONS_PER_SESSION*100 then
    quizUpgradesLeft=quizUpgradesLeft+1
    quizMessage=quizMessage.."\nALL correct => +1 upgrade!"
  else
    quizMessage=quizMessage.."\nNot perfect => no upgrade."
  end
end

function drawQuiz()
  local q=quizRound[quizIndex]
  love.graphics.setColor(0,0,0,0.8)
  love.graphics.rectangle("fill",100,50,800,500)
  love.graphics.setColor(1,1,1)
  love.graphics.print("Quiz Points: "..quizPoints,120,60)
  love.graphics.print("Question: "..(answeredCount+1).."/"..QUIZ_QUESTIONS_PER_SESSION,120,80)
  love.graphics.print(q.question,120,120)

  for i,choice in ipairs(q.choices) do
    local prefix = (i==selectedChoice) and "> " or ""
    love.graphics.print(prefix..choice, 140, 150+(i*30))
  end

  love.graphics.print(quizMessage,120,330)
end

-------------------------------------------------------------------------------
-- Reset
-------------------------------------------------------------------------------
function resetGame()
  player.x=100
  player.y=450
  batteryEnergy=0
  currentWireLevel=1
  currentSolarLevel=1
  quizUpgradesLeft=0
  upgradedWireOnce=false
  upgradedSolarOnce=false
  for _,ap in ipairs(masterAppliances) do
    ap.energy=0
  end
  solarPanels={}
  while #solarPanels<2 do
    table.insert(solarPanels,{
      x=200+(#solarPanels*120),
      y=200,
      width=80,height=50,
      isInShadow=false,
      wireThickness=2
    })
  end
  wires={}
  clouds={}
  cloudSpawnTimer=0
  dayTimer=0
  isNight=false
  temperature=25
  AC_ON=false
end
