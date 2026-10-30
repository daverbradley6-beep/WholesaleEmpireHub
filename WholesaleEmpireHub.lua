-- Wholesale Empire Hub v3.4 | Potassium Luau
-- Safe automation: stock alerts, worker alerts, optional nearby non-purchase prompts.
-- Remote purchasing/order fulfilment requires verified argument schemas and is NOT fired.
local P=game:GetService('Players').LocalPlayer
local U=game:GetService('UserInputService')
local R=game:GetService('RunService')
local Pathfinding=game:GetService('PathfindingService')
local TweenService=game:GetService('TweenService')
if _G.WEHubCleanup then pcall(_G.WEHubCleanup) end
local g=Instance.new('ScreenGui');g.Name='WholesaleEmpireHub';g.ResetOnSpawn=false;g.Parent=P:WaitForChild('PlayerGui')
local hoverLevel=1;local hoverSpeed=16;local hoverTween=nil;local hoverActive=false
local con={};local alive=true;local speed=false;local jump=false;local noclip=false;local target=24;local saved={};local running={alerts=false,workerAlerts=false,nearby=false};local threshold=10;local maxDistance=9;local lastPrompt={};local notice='Ready';local lastPos=(_G.WEHubPosition or UDim2.new(.5,-305,.5,-210))
local function on(s,f)local c=s:Connect(f);table.insert(con,c);return c end
local function obj(t,p,at)local x=Instance.new(t);for k,v in pairs(p)do x[k]=v end;x.Parent=at;return x end
local bg=Color3.fromRGB(25,28,37);local panel=Color3.fromRGB(39,45,59);local fg=Color3.fromRGB(240,244,250);local accent=Color3.fromRGB(45,105,190)
local main=obj('Frame',{Size=UDim2.fromOffset(610,420),Position=lastPos,BackgroundColor3=bg,BorderSizePixel=0,Active=true},g)
obj('UICorner',{CornerRadius=UDim.new(0,10)},main)
local bar=obj('Frame',{Size=UDim2.new(1,0,0,45),BackgroundColor3=panel,BorderSizePixel=0,Active=true},main)
obj('TextLabel',{Size=UDim2.new(1,-100,1,0),Position=UDim2.fromOffset(12,0),BackgroundTransparency=1,Text='WHOLESALE EMPIRE HUB  v3.4',TextColor3=fg,Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},bar)
local function btn(parent,text,x,y,w,h)
 local border=obj('Frame',{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0},parent)
 obj('UICorner',{CornerRadius=UDim.new(0,7)},border)
 local b=obj('TextButton',{Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,1,-4),BackgroundColor3=panel,TextColor3=fg,Text=text,TextSize=13,Font=Enum.Font.GothamBold,BorderSizePixel=0},border)
 obj('UICorner',{CornerRadius=UDim.new(0,5)},b)
 return b
end
local close=btn(bar,'X',565,7,35,30);local mini=btn(bar,'-',524,7,35,30);local bubble=btn(g,'WE',15,170,46,46);bubble.Visible=false
local function show(v)main.Visible=v;bubble.Visible=not v end
on(mini.MouseButton1Click,function()show(false)end);on(bubble.MouseButton1Click,function()show(true)end)
on(U.InputBegan,function(i,processed)if not processed and i.KeyCode==Enum.KeyCode.RightShift then show(not main.Visible)end end)
local dragging=false;local start;local pos
on(bar.InputBegan,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;start=i.Position;pos=main.Position end end)
on(U.InputEnded,function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false;_G.WEHubPosition=main.Position end end)
on(U.InputChanged,function(i)if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-start;main.Position=UDim2.new(pos.X.Scale,pos.X.Offset+d.X,pos.Y.Scale,pos.Y.Offset+d.Y)end end)
local pages={};local tabs={'Dashboard','Inventory','Orders','Workers','Automation','Movement','Settings'}
local function label(parent,txt,y,h)return obj('TextLabel',{Position=UDim2.fromOffset(8,y),Size=UDim2.new(1,-16,0,h),BackgroundTransparency=1,Text=txt,TextColor3=fg,TextSize=13,Font=Enum.Font.Code,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top},parent)end
for i,name in ipairs(tabs)do
 local b=btn(main,name,10,52+(i-1)*51,140,43)
 local page=obj('ScrollingFrame',{Position=UDim2.fromOffset(160,53),Size=UDim2.new(1,-170,1,-62),CanvasSize=UDim2.fromOffset(0,850),ScrollBarThickness=4,BackgroundColor3=panel,BorderSizePixel=0,Visible=i==1},main)
 pages[name]=page;on(b.MouseButton1Click,function()for n,p in pairs(pages)do p.Visible=n==name end end)
end
local dashboard=label(pages.Dashboard,'Loading...',12,310)
local inventory=label(pages.Inventory,'Loading...',12,790)
local orders=label(pages.Orders,'Loading...',12,450)
local workers=label(pages.Workers,'Loading...',12,750)
local autoTitle=label(pages.Automation,'',12,160)
local alertBtn=btn(pages.Automation,'Stock alerts: OFF',8,175,205,36)
local workerBtn=btn(pages.Automation,'Worker alerts: OFF',220,175,195,36)
local less=btn(pages.Automation,'Threshold -5',8,221,130,34)
local more=btn(pages.Automation,'Threshold +5',148,221,130,34)
local nearbyBtn=btn(pages.Automation,'Nearby prompts: OFF',8,265,205,36)
local pickupBtn=btn(pages.Automation,'Auto pickup: OFF',8,312,200,36)
local placeBtn=btn(pages.Automation,'Auto place: OFF',215,312,200,36)
local scanBtn=btn(pages.Automation,'Scan interactions',8,357,200,36)
local travelBtn=btn(pages.Automation,'Auto travel: OFF',8,405,200,36)
local buyBtn=btn(pages.Automation,'Auto Buy: OFF',215,405,200,36)
local ordersBtn=btn(pages.Automation,'Auto Orders: OFF',215,452,200,36)
local masterBtn=btn(pages.Automation,'MASTER: OFF',8,452,200,36)
local budgetLess=btn(pages.Automation,'Budget -100',8,497,130,34)
local budgetMore=btn(pages.Automation,'Budget +100',148,497,130,34)
local status=label(pages.Automation,'',545,280)
local pickupOn=false;local placeOn=false;local autoTravel=false;local autoBuy=false;local autoOrders=false;local storageBlocked=false;local master=false;local budget=500;local busy=false;local jobStatus='Idle';local purchaseSchemaVerified=false;local interactionReport='Not scanned';local lastAction=0

local movement=label(pages.Movement,'',12,85)
local function hum()local c=P.Character;return c and c:FindFirstChildOfClass('Humanoid')end
local function updateMovement()movement.Text='Walk speed '..target..' ('..(speed and 'ON' or 'OFF')..')\nHover speed '..hoverLevel..'/10 ('..math.floor(hoverSpeed)..' studs/sec)\nInfinite jump '..tostring(jump)..' | Noclip '..tostring(noclip) end
local bSpeed=btn(pages.Movement,'Toggle speed',8,110,150,36)
local bDown=btn(pages.Movement,'Speed -4',8,155,100,36)
local bUp=btn(pages.Movement,'Speed +4',116,155,100,36)
local bJump=btn(pages.Movement,'Toggle infinite jump',8,200,210,36)
local bNoclip=btn(pages.Movement,'Toggle noclip',8,245,210,36)
on(bSpeed.MouseButton1Click,function()speed=not speed;if not speed and hum()then hum().WalkSpeed=16 end;updateMovement()end)
on(bDown.MouseButton1Click,function()target=math.max(16,target-4);updateMovement()end)
on(bUp.MouseButton1Click,function()target=math.min(100,target+4);updateMovement()end)
on(bJump.MouseButton1Click,function()jump=not jump;updateMovement()end)
on(bNoclip.MouseButton1Click,function()noclip=not noclip;updateMovement()end)

local hoverTitle=label(pages.Movement,'Hover speed (1–10)',300,24)
local track=obj('Frame',{Position=UDim2.fromOffset(15,338),Size=UDim2.fromOffset(385,10),BackgroundColor3=Color3.fromRGB(10,12,16),BorderSizePixel=0},pages.Movement)
obj('UICorner',{CornerRadius=UDim.new(1,0)},track)
local fill=obj('Frame',{Size=UDim2.fromScale((hoverLevel-1)/9,1),BackgroundColor3=accent,BorderSizePixel=0},track)
obj('UICorner',{CornerRadius=UDim.new(1,0)},fill)
local knob=obj('Frame',{Size=UDim2.fromOffset(18,18),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale((hoverLevel-1)/9,.5),BackgroundColor3=fg,BorderSizePixel=0},track)
obj('UICorner',{CornerRadius=UDim.new(1,0)},knob)
obj('UIStroke',{Color=Color3.new(0,0,0),Thickness=2},knob)
local hoverNumber=obj('TextLabel',{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new((hoverLevel-1)/9,0,0,-11),Size=UDim2.fromOffset(32,22),BackgroundColor3=Color3.fromRGB(12,14,20),TextColor3=fg,Text=tostring(hoverLevel),TextSize=14,Font=Enum.Font.GothamBold,BorderSizePixel=0,ZIndex=8},track)
obj('UICorner',{CornerRadius=UDim.new(0,6)},hoverNumber)
obj('UIStroke',{Color=Color3.new(0,0,0),Thickness=2},hoverNumber)
local sliding=false
local function setHoverSpeed(x)
 hoverLevel=math.clamp(math.floor(1+9*math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)+.5),1,10)
 hoverSpeed=12+4*hoverLevel
 local ratio=(hoverLevel-1)/9
 fill.Size=UDim2.fromScale(ratio,1);knob.Position=UDim2.fromScale(ratio,.5);hoverNumber.Position=UDim2.new(ratio,0,0,-11);hoverNumber.Text=tostring(hoverLevel)
 updateMovement()
end
on(track.InputBegan,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true;setHoverSpeed(input.Position.X) end end)
on(knob.InputBegan,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true;setHoverSpeed(input.Position.X) end end)
on(U.InputChanged,function(input)if sliding and input.UserInputType==Enum.UserInputType.MouseMovement then setHoverSpeed(input.Position.X)end end)
on(U.InputEnded,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
local function stop()if hoverTween then hoverTween:Cancel();hoverTween=nil end;hoverActive=false;if hum() then hum().PlatformStand=false;hum().AutoRotate=true end;master=false;autoTravel=false;autoBuy=false;autoOrders=false;storageBlocked=false;pickupOn=false;placeOn=false;speed=false;jump=false;noclip=false;for k in pairs(running)do running[k]=false end;if hum()then hum().WalkSpeed=16 end;for part,old in pairs(saved)do if part.Parent then part.CanCollide=old end end;table.clear(saved);updateMovement()end
local stopBtn=btn(pages.Settings,'STOP ALL',8,15,220,42)
on(stopBtn.MouseButton1Click,function()stop();notice='All local features stopped' end)
label(pages.Settings,'Right Shift: toggle window\nDrag: top bar\nClose: unload\n\nNo unverified remote purchases or orders.\nNearby prompts are opt-in and limited to non-purchase actions.',75,250)
on(U.JumpRequest,function()if jump and hum()then hum():ChangeState(Enum.HumanoidStateType.Jumping)end end)
on(R.Stepped,function()if speed and hum()then hum().WalkSpeed=target end;if (noclip or hoverActive) and P.Character then for _,part in ipairs(P.Character:GetDescendants())do if part:IsA('BasePart')then if saved[part]==nil then saved[part]=part.CanCollide end;part.CanCollide=false end end end end)
local function plot()local world=workspace:FindFirstChild('World');local plots=world and world:FindFirstChild('Plots');if not plots then return nil end;for _,p in ipairs(plots:GetChildren())do if tonumber(p:GetAttribute('OwnerUserId'))==P.UserId then return p end end end
local function refresh()
 local runtime=workspace:FindFirstChild('Runtime');local stock=runtime and runtime:FindFirstChild('Stock');local work=runtime and runtime:FindFirstChild('Workers')
 local cartons,units,count=0,0,0;local products={};local states={};local stored={};local wlines={};local orderids={};local idle=0
 if stock then for _,item in ipairs(stock:GetChildren())do if tonumber(item:GetAttribute('OwnerUserId'))==P.UserId then
 cartons+=1;local n=tonumber(item:GetAttribute('Units'))or 0;units+=n;local id=tostring(item:GetAttribute('ProductId')or 'Unknown');products[id]=(products[id]or 0)+n
 local state=tostring(item:GetAttribute('State')or '?');states[state]=(states[state]or 0)+1;if state=='Stored' then stored[id]=(stored[id]or 0)+n end
 local order=item:GetAttribute('OrderId');if order then orderids[tostring(order)]=true end
 end end end
 if work then for _,w in ipairs(work:GetChildren())do if tonumber(w:GetAttribute('OwnerUserId'))==P.UserId and w:GetAttribute('WorkerId')then
 count+=1;local state=tostring(w:GetAttribute('Status')or '?');if state=='IDLE' then idle+=1 end;table.insert(wlines,tostring(w:GetAttribute('Role')or 'Worker')..' | '..state..' | Tier '..tostring(w:GetAttribute('Tier')or '?'))
 end end end
 local lines={'Cartons: '..cartons,'Units (all states): '..units,'','PRODUCTS (all states)'};local keys={};for id in pairs(products)do table.insert(keys,id)end;table.sort(keys)
 local low={};for _,id in ipairs(keys)do local n=stored[id]or 0;table.insert(lines,id..': '..products[id]..' total / '..n..' stored');if n<threshold then table.insert(low,id..' ('..n..')')end end
 table.insert(lines,'\nSTATES');for state,n in pairs(states)do table.insert(lines,state..': '..n)end;inventory.Text=table.concat(lines,'\n')
 workers.Text='Workers: '..count..' | Idle: '..idle..'\n\n'..table.concat(wlines,'\n')
 local ids={};for id in pairs(orderids)do table.insert(ids,id)end;table.sort(ids);orders.Text='Order IDs visible on your cartons (not the complete order queue):\n\n'..table.concat(ids,'\n')
 local myplot=plot();dashboard.Text='WAREHOUSE OVERVIEW\n\nPlot: '..(myplot and myplot.Name or 'not found')..'\nCartons: '..cartons..'\nUnits: '..units..'\nWorkers: '..count..'\nOrder references: '..#ids..'\n\nUpdates every 2 seconds.'
 if running.alerts and #low>0 then notice='Low stored stock: '..table.concat(low,', ') end
 if running.workerAlerts and count>0 and idle>0 then notice=idle..' worker(s) idle' end
end
local function updateAuto()
 pickupBtn.Text='Auto pickup: '..(pickupOn and 'ON' or 'OFF')
 placeBtn.Text='Auto place: '..(placeOn and 'ON' or 'OFF')
 alertBtn.Text='Stock alerts: '..(running.alerts and 'ON' or 'OFF');workerBtn.Text='Worker alerts: '..(running.workerAlerts and 'ON' or 'OFF');nearbyBtn.Text='Nearby prompts: '..(running.nearby and 'ON' or 'OFF')
 autoTitle.Text='WAREHOUSE AUTOMATION\n\nStock threshold: '..threshold..' stored units\nInteraction range: '..maxDistance..' studs\nPurchase cap: '..budget..' currency / transaction\nPurchase protocol: '..(purchaseSchemaVerified and 'VERIFIED' or 'UNVERIFIED - BLOCKED')
 travelBtn.Text='Auto travel: '..(autoTravel and 'ON' or 'OFF');buyBtn.Text='Auto Buy: '..(autoBuy and 'ON' or 'OFF');ordersBtn.Text='Auto Orders: '..(autoOrders and 'ON' or 'OFF');masterBtn.Text='MASTER: '..(master and 'ON' or 'OFF');status.Text='STATUS: '..notice..'\nTASK: '..jobStatus..'\n\nSCAN: '..interactionReport..'\n\nAuto Orders: accept customer orders (awaiting verified interaction). Auto Buy: purchase only missing products for accepted orders (awaiting verified product IDs and purchase arguments).'
end
on(alertBtn.MouseButton1Click,function()running.alerts=not running.alerts;notice='Stock alerts toggled';updateAuto()end)
on(workerBtn.MouseButton1Click,function()running.workerAlerts=not running.workerAlerts;notice='Worker alerts toggled';updateAuto()end)
on(less.MouseButton1Click,function()threshold=math.max(0,threshold-5);updateAuto()end)
on(more.MouseButton1Click,function()threshold=math.min(1000,threshold+5);updateAuto()end)
on(nearbyBtn.MouseButton1Click,function()running.nearby=false;notice='Nearby prompts disabled: sequential controller handles interactions';updateAuto()end)
on(pickupBtn.MouseButton1Click,function()pickupOn=not pickupOn;notice='Auto pickup '..tostring(pickupOn);updateAuto()end)
on(placeBtn.MouseButton1Click,function()placeOn=not placeOn;notice='Auto place '..tostring(placeOn);updateAuto()end)
local function promptPosition(prompt)
 local a=prompt.Parent
 if a and a:IsA('Attachment') then return a.WorldPosition end
 if a and a:IsA('BasePart') then return a.Position end
 local part=a and a:FindFirstAncestorWhichIsA('BasePart')
 return part and part.Position or nil
end
local function ownedCarton(model)
 local node=model
 while node and node~=workspace do
  local owner=node:GetAttribute('OwnerUserId')
  if owner~=nil then return tonumber(owner)==P.UserId end
  node=node.Parent
 end
 return false
end
local function stockFolder()
 local rt=workspace:FindFirstChild('Runtime')
 return rt and rt:FindFirstChild('Stock')
end
local function myCartons()
 local result={};local folder=stockFolder()
 if folder then for _,box in ipairs(folder:GetChildren())do
  if tonumber(box:GetAttribute('OwnerUserId'))==P.UserId then table.insert(result,box) end
 end end
 return result
end
local function cartonPrompt(box,verb)
 for _,p in ipairs(box:GetDescendants())do
  if p:IsA('ProximityPrompt') and p.Enabled then
   local action=(p.ActionText or ''):lower()
   if verb=='pickup' and (action:find('pick up',1,true) or action:find('pickup',1,true)) then return p end
   if verb=='putdown' and (action:find('put down',1,true) or action:find('putdown',1,true)) then return p end
  end
 end
end
local function cartonPosition(box)
 if box:IsA('Model') then return box:GetPivot().Position end
 if box:IsA('BasePart') then return box.Position end
end
local function scanActions()
 local pickupCount,putdownCount=0,0;local lines={}
 for _,box in ipairs(myCartons())do
  local pick=cartonPrompt(box,'pickup');local put=cartonPrompt(box,'putdown')
  if pick then pickupCount+=1 end
  if put then putdownCount+=1 end
  if pick or put then table.insert(lines,tostring(box.Name)..' ['..tostring(box:GetAttribute('State'))..'] '..(put and 'PUT DOWN' or 'PICK UP')) end
 end
 interactionReport=pickupCount..' pickup / '..putdownCount..' put-down prompts on owned cartons. '..table.concat(lines,' | '):sub(1,290)
end
on(scanBtn.MouseButton1Click,function()scanActions();notice='Interaction scan completed';updateAuto()end)
on(travelBtn.MouseButton1Click,function()autoTravel=not autoTravel;notice='Auto travel '..tostring(autoTravel);updateAuto()end)
on(buyBtn.MouseButton1Click,function()autoBuy=not autoBuy;notice=autoBuy and 'Auto Buy enabled; purchases blocked until order/product mapping is verified' or 'Auto Buy disabled';updateAuto()end)
on(ordersBtn.MouseButton1Click,function()autoOrders=not autoOrders;notice=autoOrders and 'Auto Orders enabled; accepting orders blocked until order interaction is verified' or 'Auto Orders disabled';updateAuto()end)
on(masterBtn.MouseButton1Click,function()master=not master;if master then storageBlocked=false end;notice='Master automation '..tostring(master);updateAuto()end)
on(budgetLess.MouseButton1Click,function()budget=math.max(0,budget-100);updateAuto()end)
on(budgetMore.MouseButton1Click,function()budget=math.min(100000,budget+100);updateAuto()end)
-- Single sequential batch controller. No parallel pickup/place loops.
-- No BuyStock remote is called: purchase schema and prices remain unknown.
local controllerGeneration=0
local batchActive=false
local batchIDs={}
local function isDelivered(box)
 local state=tostring(box:GetAttribute('State') or ''):lower()
 return state=='delivered' or state=='delivery' or state=='shipping' or state=='waiting'
end
local function isCarried(box)
 return tostring(box:GetAttribute('State') or ''):lower()=='carried'
end
local function availableBoxes()
 local result={}
 for _,box in ipairs(myCartons())do
  if isDelivered(box) and cartonPrompt(box,'pickup') then table.insert(result,box) end
 end
 return result
end
local function carriedBox()
 for _,box in ipairs(myCartons())do if isCarried(box) then return box end end
end
local function rootPart()
 return P.Character and P.Character:FindFirstChild('HumanoidRootPart')
end
local function moveToPosition(position,range,gen)
 local h=hum();local root=rootPart()
 if not h or not root then return false end
 if (root.Position-position).Magnitude<=range then return true end
 if not autoTravel then notice='Auto Travel must be ON';return false end
 local wasPlatformStand=h.PlatformStand
 local wasAutoRotate=h.AutoRotate
 hoverActive=true
 h.PlatformStand=true;h.AutoRotate=false
 local function finish(ok)
  if hoverTween then hoverTween:Cancel();hoverTween=nil end
  hoverActive=false
  if h and h.Parent then h.PlatformStand=wasPlatformStand;h.AutoRotate=wasAutoRotate end
  if root and root.Parent then root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero end
  return ok
 end
 local direction=position-root.Position
 local distance=direction.Magnitude
 local destination=position
 if distance>range and distance>0 then destination=position-direction.Unit*math.max(1,range-2) end
 -- Travel at a modest elevated height, then descend into prompt range.
 local raised=Vector3.new(destination.X,math.max(root.Position.Y,destination.Y)+3,destination.Z)
 local function glide(point)
  local length=(point-root.Position).Magnitude
  if length<.1 then return true end
  local duration=length/math.max(8,hoverSpeed)
  local tween=TweenService:Create(root,TweenInfo.new(duration,Enum.EasingStyle.Linear),{CFrame=CFrame.new(point)*root.CFrame.Rotation})
  hoverTween=tween;tween:Play()
  local started=os.clock()
  while alive and master and autoTravel and gen==controllerGeneration and tween.PlaybackState==Enum.PlaybackState.Playing do
   if not root.Parent or os.clock()-started>duration+3 then break end
   root.AssemblyLinearVelocity=Vector3.zero
   task.wait(.05)
  end
  return alive and master and autoTravel and gen==controllerGeneration and root.Parent~=nil and (root.Position-point).Magnitude<3
 end
 jobStatus='Hovering to destination at '..math.floor(hoverSpeed)..' studs/sec'
 if not glide(raised) then return finish(false) end
 if not glide(destination) then return finish(false) end
 return finish((root.Position-position).Magnitude<=range+1)
end
local function triggerAndConfirm(box,verb,expected,gen)
 local prompt=cartonPrompt(box,verb)
 if not prompt then notice='Missing '..verb..' prompt';return false end
 local pos=promptPosition(prompt) or cartonPosition(box)
 if not pos then return false end
 jobStatus='Moving to '..verb..' / '..box.Name
 local range=math.max(2,math.min(maxDistance,prompt.MaxActivationDistance)-1)
 if not moveToPosition(pos,range,gen) then notice='Could not reach '..verb;return false end
 if not alive or not master or gen~=controllerGeneration then return false end
 if type(fireproximityprompt)~='function' then notice='Potassium does not expose fireproximityprompt';return false end
 jobStatus='Activating '..verb
 local ok,err=pcall(fireproximityprompt,prompt)
 if not ok then notice='Interaction failed: '..tostring(err):sub(1,90);return false end
 for i=1,12 do
  if not alive or not master or gen~=controllerGeneration then return false end
  if tostring(box:GetAttribute('State') or ''):lower()==expected then return true end
  task.wait(.25)
 end
 notice='No confirmed state change after '..verb
 return false
end
-- Storage location must be inside the player's plot. Rack 1 is only a
-- navigation target, not proof of an available slot.
local function rackTargets()
 local myplot=plot();local result={}
 if not myplot then return result end
 -- Do not treat generic rack bays, plot slots or placeholder parts as built racks.
 -- Only target a real rack model with a storage interaction prompt.
 local seen={}
 for _,node in ipairs(myplot:GetDescendants())do
  if node:IsA('ProximityPrompt') and node.Enabled then
   local action=(node.ActionText or ''):lower()
   local parentName=(node.Parent and node.Parent.Name or ''):lower()
   local ancestor=node:FindFirstAncestorWhichIsA('Model')
   local modelName=(ancestor and ancestor.Name or ''):lower()
   if (action:find('store',1,true) or action:find('place',1,true) or action:find('stock',1,true))
     and (parentName:find('rack',1,true) or modelName:find('rack',1,true) or modelName:find('shelf',1,true)) then
    local pos=promptPosition(node)
    if pos and not seen[node] then seen[node]=true;table.insert(result,pos) end
   end
  end
 end
 return result
end
local rackReport=label(pages.Settings,'Rack scan not run',425,400)
local calibratedRack=_G.WEHubRackCalibration
local rackCalStatus=label(pages.Settings,calibratedRack and 'Rack position saved for this session' or 'Rack position not set',375,42)
local setRackBtn=btn(pages.Settings,'SET RACK POSITION',8,335,220,36)
on(setRackBtn.MouseButton1Click,function()
 local root=P.Character and P.Character:FindFirstChild('HumanoidRootPart')
 local myplot=plot()
 if not root or not myplot then notice='Stand at your installed rack before setting position';return end
 calibratedRack={position=root.Position,lookVector=root.CFrame.LookVector,plotName=myplot.Name}
 _G.WEHubRackCalibration=calibratedRack
 rackCalStatus.Text='Saved rack approach: '..myplot.Name
 notice='Rack approach saved. Start MASTER to test placement.'
end)
local shippingReport=label(pages.Settings,'Shipping areas not scanned',425,750)
local scanShipBtn=btn(pages.Settings,'SCAN SHIPPING AREAS',8,380,220,36)
local function scanShippingAreas(silent)
 local myplot=plot()
 local root=P.Character and P.Character:FindFirstChild('HumanoidRootPart')
 local lines={'SHIPPING AREA DISCOVERY'}
 local matches={}
 local function scan(container)
  if not container then return end
  for _,node in ipairs(container:GetDescendants())do
   if node:IsA('BasePart') or node:IsA('Model') then
    local n=node.Name:lower()
    if n:find('shipping',1,true) or n:find('collection',1,true) or n:find('dispatch',1,true) then
     local pos=node:IsA('BasePart') and node.Position or node:GetPivot().Position
     local attrs={}
     for k,v in pairs(node:GetAttributes())do if #attrs<5 then table.insert(attrs,tostring(k)..'='..tostring(v)) end end
     table.insert(matches,{node=node,pos=pos,attrs=attrs})
    end
   end
  end
 end
 scan(myplot)
 local rt=workspace:FindFirstChild('Runtime')
 scan(rt)
 table.sort(matches,function(a,b)
  local da=root and (a.pos-root.Position).Magnitude or 0
  local db=root and (b.pos-root.Position).Magnitude or 0
  return da<db
 end)
 table.insert(lines,'Candidates: '..#matches..' (plot + runtime)')
 for i=1,math.min(#matches,20)do
  local m=matches[i]
  local dist=root and math.floor((m.pos-root.Position).Magnitude) or -1
  table.insert(lines,m.node:GetFullName():sub(-115)..' | '..dist..' studs | '..table.concat(m.attrs,','))
 end
 if #matches==0 then table.insert(lines,'No named shipping objects found. Need a wider object scan.') end
 shippingReport.Text=table.concat(lines,'\\n')
 if not silent then notice='Shipping scan: '..#matches..' candidates. See Settings or console.';print('[WE HUB SHIPPING SCAN]\\n'..table.concat(lines,'\\n')) end
 return #matches
end
on(scanShipBtn.MouseButton1Click,function()scanShippingAreas(false)end)
local function scanRackDetails(silent)
 local myplot=plot()
 if not myplot then rackReport.Text='No owned plot found';notice='Rack scan: plot not found';return end
 local lines={'RACK DIAGNOSTICS | '..myplot.Name}
 local count=0;local prompts=0
 for _,node in ipairs(myplot:GetDescendants())do
  local n=node.Name:lower()
  if (node:IsA('Model') or node:IsA('BasePart')) and (n:find('rack',1,true) or n:find('shelf',1,true) or n:find('storage',1,true)) then
   count+=1
   if count<=22 then
    local attrs={}
    for k,v in pairs(node:GetAttributes())do
     if #attrs<7 then table.insert(attrs,tostring(k)..'='..tostring(v)) end
    end
    table.insert(lines,node.ClassName..' '..node:GetFullName():sub(-105)..' ['..table.concat(attrs,', ')..']')
   end
  end
  if node:IsA('ProximityPrompt') then
   prompts+=1
   if prompts<=18 then table.insert(lines,'PROMPT '..node:GetFullName():sub(-90)..' | '..tostring(node.ActionText)..' | '..tostring(node.ObjectText)..' | enabled='..tostring(node.Enabled))end
  end
 end
 table.insert(lines,2,'Rack-related objects: '..count..' | Prompts: '..prompts)
 rackReport.Text=table.concat(lines,'\\n')
 if not silent then notice='Rack scan complete: '..count..' objects, '..prompts..' prompts. Open Settings.';print('[WE HUB RACK SCAN]\\n'..table.concat(lines,'\\n')) end
end
local scanRacksBtn=btn(pages.Settings,'SCAN REAL RACKS',8,290,220,36)
on(scanRacksBtn.MouseButton1Click,function()scanRackDetails(false)end)
local function autoScanLocations()
 if not master then return end
 pcall(scanRackDetails,true)
 pcall(scanShippingAreas,true)
end
local function storeCarried(box,gen)
 autoScanLocations()
 if not placeOn then notice='Holding carton; enable Auto Place';return false end
 if type(fireproximityprompt)~='function' then notice='Executor lacks fireproximityprompt';return false end
 local targets={}
 local myplot=plot()
 if calibratedRack and myplot and calibratedRack.plotName==myplot.Name then
  table.insert(targets,calibratedRack.position)
 else
  targets=rackTargets()
 end
 if #targets==0 then notice='No rack approach saved. Stand at your installed rack and click Settings > SET RACK POSITION';jobStatus='Waiting for rack calibration';return false end
 local root=rootPart()
 if root then table.sort(targets,function(a,b)return (a-root.Position).Magnitude<(b-root.Position).Magnitude end) end
 -- A put-down prompt belongs to the carton being carried, not the rack.
 -- Only trigger it after reaching the warehouse rack area.
 for i=1,math.min(#targets,12) do
  if not alive or not master or gen~=controllerGeneration then return false end
  jobStatus='Carrying '..box.Name..' to rack'
  if moveToPosition(targets[i],3,gen) then
   local charRoot=rootPart()
   if charRoot and calibratedRack and calibratedRack.lookVector and i==1 then
    local dir=Vector3.new(calibratedRack.lookVector.X,0,calibratedRack.lookVector.Z)
    if dir.Magnitude>.01 then charRoot.CFrame=CFrame.lookAt(charRoot.Position,charRoot.Position+dir.Unit) end
   end
   local p=cartonPrompt(box,'putdown')
   if p then
    local ok=pcall(fireproximityprompt,p)
    if ok then
     for j=1,12 do
      if not alive or not master or gen~=controllerGeneration then return false end
      if tostring(box:GetAttribute('State') or ''):lower()=='stored' then storageBlocked=false;return true end
      task.wait(.25)
     end
    end
   end
  end
 end
 storageBlocked=true
  notice='RACK FULL / placement rejected: waiting for storage space or shipping transfer.'
  jobStatus='RACK FULL: no confirmed placement available'
 return false
end
local function runBatch(gen)
 busy=true
 local success,err=pcall(function()
  while alive and master and gen==controllerGeneration do
   local carrying=carriedBox()
   if carrying then
    jobStatus='Storing carried carton'
    if not storeCarried(carrying,gen) then break end
   else
    local pending=availableBoxes()
    if #pending==0 then
     if batchActive then notice='Delivery batch complete';batchActive=false;batchIDs={} end
     jobStatus='Delivery clear; waiting for stock'
     if autoBuy then notice='Purchase blocked: BuyStock arguments unverified' end
     break
    end
    batchActive=true
    for _,box in ipairs(pending)do batchIDs[tostring(box:GetAttribute('CartonId') or box.Name)]=true end
    if not pickupOn then notice='Delivery waiting; enable Auto Pickup';break end
    local box=pending[1]
    jobStatus='Picking up carton ('..#pending..' waiting)'
    if not triggerAndConfirm(box,'pickup','carried',gen) then break end
     autoScanLocations()
    if not placeOn then notice='Carton collected; enable Auto Place';break end
   end
   task.wait(.3)
  end
 end)
 if not success then notice='Controller error: '..tostring(err):sub(1,130) end
 busy=false
end
local nextAttempt=0
local function handleCartons()
 if not master or busy or os.clock()<nextAttempt or storageBlocked then return end
 nextAttempt=os.clock()+8
 if not pickupOn and not placeOn then return end
 controllerGeneration+=1
 local gen=controllerGeneration
 task.spawn(function()runBatch(gen)end)
end
local function cleanup()if not alive then return end;alive=false;controllerGeneration+=1;stop();for _,c in ipairs(con)do c:Disconnect()end;g:Destroy();_G.WEHubCleanup=nil end
_G.WEHubCleanup=cleanup;on(close.MouseButton1Click,cleanup)
updateMovement();updateAuto();pcall(refresh)
task.spawn(function()while alive do pcall(refresh);pcall(handleCartons);updateAuto();task.wait(2)end end)
print('Wholesale Empire Hub v3.4 loaded')