--------------------------------
--- ManaBar.lua Version 0.5 ----
--------------------------------

local ManaBar = {
	OptionEnable = Menu.AddOption({"mlambers", "ManaBar"}, "1. Enable.", "Enable/Disable this script."),
    OffsetHeight = Menu.AddOption({"mlambers", "ManaBar"}, "2. Height", "", 2, 40, 1),
    OptionEnableManual = Menu.AddOption({"mlambers", "ManaBar"}, "3. Manual adjustment", "Enable manual setup."),
	OffsetWidth = Menu.AddOption({"mlambers", "ManaBar"}, "4. Width", "", 20, 300, 2),
	OffsetYPos = Menu.AddOption({"mlambers", "ManaBar"}, "5. Y position", "", -80, 80, 1),
	OffsetXPos = Menu.AddOption({"mlambers", "ManaBar"}, "6. X position", "", -150, 150, 1)
}

--[[
    Localize global function from _ENV
        math.ceil
--]]
local MathCeil = math.ceil
local MathFloor = math.floor

local MyHero = nil
local hero_object, hero_origin = nil, nil

local bar_width, bar_height = nil, nil
local bar_x_offset, bar_y_offset = nil, nil
local bar_x, bar_y = nil, nil

local x_w2s, y_w2s = nil, nil
local screen_width, screen_height = nil, nil

local currBrew = nil
local extra_padding = 0

local function roundToNthDecimal(num, n)
	local mult = 10 ^ (n or 0)
	return MathFloor(num * mult + 0.5) / mult
end

function ManaBar.OnMenuOptionChange(option, old, new)
	if MyHero == nil then return end
    
    if option == ManaBar.OptionEnable then
        MyHero = nil
        hero_object, hero_origin = nil, nil
            
        bar_width, bar_height = nil, nil
        bar_x_offset, bar_y_offset = nil, nil
        bar_x, bar_y = nil, nil
            
        x_w2s, y_w2s = nil, nil
        screen_width, screen_height = nil, nil
        
        currBrew = nil
        extra_padding = 0
    end
    
    if option == ManaBar.OptionEnableManual then
        bar_height = Menu.GetValue(ManaBar.OffsetHeight)
        if old > 0 then -- From On to Off
            bar_width = roundToNthDecimal((screen_height/480) * 45, 0)
            
            bar_x_offset = roundToNthDecimal(bar_width/2, 0) + 2
            bar_y_offset = roundToNthDecimal(screen_height/480 * 9, 0)
        else
            bar_width = Menu.GetValue(ManaBar.OffsetWidth)
            bar_x_offset = Menu.GetValue(ManaBar.OffsetXPos)
            bar_y_offset = Menu.GetValue(ManaBar.OffsetYPos)
        end
    end
    
    if 
		(option == ManaBar.OffsetWidth
		or option == ManaBar.OffsetHeight
		or option == ManaBar.OffsetYPos
		or option == ManaBar.OffsetXPos)
	then
        bar_height = Menu.GetValue(ManaBar.OffsetHeight)
        
        if Menu.IsEnabled(ManaBar.OptionEnableManual) == false then return end
		
        bar_width = Menu.GetValue(ManaBar.OffsetWidth)
        bar_x_offset = Menu.GetValue(ManaBar.OffsetXPos)
		bar_y_offset = Menu.GetValue(ManaBar.OffsetYPos)
    end
end

function ManaBar.OnScriptLoad()
	MyHero = nil
	hero_object, hero_origin = nil, nil
	
    bar_width, bar_height = nil, nil
    bar_x_offset, bar_y_offset = nil, nil
	bar_x, bar_y = nil, nil
    
    x_w2s, y_w2s = nil, nil
	screen_width, screen_height = nil, nil
    
    currBrew = nil
    extra_padding = 0
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.5 ] Script load.")
end

function ManaBar.OnGameEnd()
	MyHero = nil
	hero_object, hero_origin = nil, nil
	
	bar_width, bar_height = nil, nil
    bar_x_offset, bar_y_offset = nil, nil
	bar_x, bar_y = nil, nil
    
    x_w2s, y_w2s = nil, nil
	screen_width, screen_height = nil, nil
    
    currBrew = nil
    extra_padding = 0
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.5 ] Game end. Reset all variable.")
end

function ManaBar.IsOnScreen(x_position, y_position)
	if (x_position < 1) or (y_position < 1) or (x_position > screen_width) or (y_position > screen_height) then 
		return false 
	end
	
	return true
end

function ManaBar.OnUpdate()
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	
	if MyHero == nil or MyHero ~= Heroes.GetLocal() then
        screen_width, screen_height = Renderer.GetScreenSize()

        bar_width = roundToNthDecimal((screen_height/480) * 45, 0)
		bar_height = Menu.GetValue(ManaBar.OffsetHeight)
        
        bar_x_offset = roundToNthDecimal(bar_width/2, 0) + 2
        bar_y_offset = roundToNthDecimal(screen_height/480 * 9, 0)
        
        if Menu.IsEnabled(ManaBar.OptionEnableManual) then
            bar_width = Menu.GetValue(ManaBar.OffsetWidth)
            bar_x_offset = Menu.GetValue(ManaBar.OffsetXPos)
            bar_y_offset = Menu.GetValue(ManaBar.OffsetYPos)
        end
        
		bar_x, bar_y = nil, nil
        
        x_w2s, y_w2s = nil, nil
        
        hero_object, hero_origin = nil, nil
        
        MyHero = Heroes.GetLocal()
        
        currBrew = nil
        extra_padding = 0
		
		Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.5 ] Game started, init script done.")
		return
	end
end

local function GetCurrentBrew(hOwner)
    for k, v in  pairs(Entities.GetAll("C_DOTA_Unit_Brewmaster_PrimalEarth")) do
        if
            Entity.GetOwner(v) == hOwner
            and Entity.IsDormant(v) == false
            and Entity.IsAlive(v)
        then
            return v
        end
    end
    
    for k, v in  pairs(Entities.GetAll("C_DOTA_Unit_Brewmaster_PrimalStorm")) do
        if
            Entity.GetOwner(v) == hOwner
            and Entity.IsDormant(v) == false
            and Entity.IsAlive(v)
        then
            return v   
        end
    end
    
    for k, v in  pairs(Entities.GetAll("C_DOTA_Unit_Brewmaster_PrimalFire")) do
        if
            Entity.GetOwner(v) == hOwner
            and Entity.IsDormant(v) == false
            and Entity.IsAlive(v)
        then
            return v
        end
    end
    
    return nil
end

function ManaBar.OnDraw()
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	
	if MyHero == nil then return end
    
	for i = 1, Heroes.Count() do
		hero_object = Heroes.Get(i)
		
		if 
			hero_object ~= nil
			and Entity.IsDormant(hero_object) == false
			and Entity.IsAlive(hero_object)
			and Entity.IsSameTeam(MyHero, hero_object) == false
			and Entity.GetField(hero_object, "m_bIsIllusion") == false
			and NPC.IsIllusion(hero_object) == false
			and Entity.IsPlayer(Entity.GetOwner(hero_object)) 
		then
            
			hero_origin = Entity.GetAbsOrigin(hero_object)
            hero_origin:SetZ(hero_origin:GetZ() + NPC.GetHealthBarOffset(hero_object))
            
            x_w2s, y_w2s = Renderer.WorldToScreen(hero_origin)
			extra_padding = 0
            if 
                Entity.GetClassName(hero_object) == "C_DOTA_Unit_Hero_Brewmaster" or Entity.GetClassName(hero_object) == "C_DOTA_Unit_Hero_Rubick" and
                NPC.HasModifier(hero_object, "modifier_brewmaster_primal_split")
            then
                currBrew = GetCurrentBrew(hero_object)
                if currBrew then
                    hero_object = currBrew
                    
                    hero_origin = Entity.GetAbsOrigin(hero_object)
                    hero_origin:SetZ(hero_origin:GetZ() + NPC.GetHealthBarOffset(hero_object))
                    
                    x_w2s, y_w2s = Renderer.WorldToScreen(hero_origin)
                    
                    extra_padding = roundToNthDecimal(bar_y_offset*0.25, 0)
                end
            end
			--[[
				Need to check if target object on our screen or not.
			--]]
			if ManaBar.IsOnScreen(x_w2s, y_w2s) then
				-- bar_x = x_w2s + bar_x_offset
                bar_x = x_w2s - bar_x_offset
				-- bar_y = y_w2s + bar_y_offset
                bar_y = y_w2s - bar_y_offset + extra_padding
				
				--[[
					Draw black background.
				--]]
				Renderer.SetDrawColor(0, 0, 0, 255)
				Renderer.DrawFilledRect(bar_x, bar_y, bar_width, bar_height)
				
				--[[
					Draw the actual mana bar.
				--]]
				Renderer.SetDrawColor(79, 120, 249, 255)
				Renderer.DrawFilledRect((1 + bar_x), (1 + bar_y), MathCeil((bar_width - 2) * (NPC.GetMana(hero_object) /  NPC.GetMaxMana(hero_object))), (bar_height - 2))
			end
		end
	end
end

return ManaBar