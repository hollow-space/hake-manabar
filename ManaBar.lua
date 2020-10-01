------------------------------
-- ManaBar.lua Version 0.7 ---
------------------------------
local ManaBar = {
    ScriptEnable = Menu.AddOption(
        {"mlambers", "ManaBar"},
        "1. Enable",
        "Enable/disable this script."
    ),
    OffsetBarHeight = Menu.AddOption(
        {"mlambers", "ManaBar"},
        "2. Height size",
        "Height size of manabar.",
        4, 40, 1
    ),
    ScriptEnableManualSetup = Menu.AddOption(
        {"mlambers", "ManaBar"},
        "3. Enable manual adjustment",
        "Turn off automatic position adjustment."
    ),
    OffsetBarWidth = Menu.AddOption(
        {"mlambers", "ManaBar"},
        "4. Width size",
        "Width size of manabar, only enable when manual adjustment on!",
        20, 300, 2
    ),
    OffsetPosX = Menu.AddOption(
        {"mlambers", "ManaBar"},
        "5. X position",
        "X position of manabar, only enable when manual adjustment on!",
        -200, 200, 1
    ),
    OffsetPosY = Menu.AddOption(
        {"mlambers", "ManaBar"},
        "6. Y position",
        "Y position of manabar, only enable when manual adjustment on!",
        -100, 100, 1
    )
}

local fFloor = math.floor
local fCeil = math.ceil
local nScreenWidth <const>, nScreenHeight <const> = Renderer.GetScreenSize()

local bAllowRun = nil
local bAllowDraw = nil

local nNextUpdate = 0

local x_w2s, y_w2s = nil, nil
local nBarWidth, nBarHeight = nil, nil
local nBarOffsetX, nBarOffsetY = nil, nil

local hMyHero = nil
local hLocalHero = nil

local hHero = nil
local aEntityList = {}
local vHeroOrigin = nil
local sHeroClass = nil
local bSearchBrew = 0

-- Round a number to n decimal
local function RoundNumber(num, n)
    local mult = 10 ^ (n or 0)

    return fFloor(num * mult + 0.5) / mult
end

function ManaBar.OnScriptLoad()
    hMyHero = nil
    hLocalHero = nil

    for _ in pairs(aEntityList) do
        aEntityList[_] = nil
    end
    hHero = nil
    vHeroOrigin = nil
    sHeroClass = nil
    bSearchBrew = 0

    x_w2s, y_w2s = nil, nil
    nBarWidth, nBarHeight = nil, nil
    nBarOffsetX, nBarOffsetY = nil, nil

    nNextUpdate = 0

    bAllowRun = Menu.IsEnabled(ManaBar.ScriptEnable) and 1 or 0
    bAllowDraw = 0

    Log.Write("[ManaBar.lua][OnScriptLoad] Script loaded.")
end

function ManaBar.OnGameEnd()
    hMyHero = nil
    hLocalHero = nil

    for _ in pairs(aEntityList) do
        aEntityList[_] = nil
    end
    hHero = nil
    vHeroOrigin = nil
    sHeroClass = nil
    bSearchBrew = 0

    x_w2s, y_w2s = nil, nil
    nBarWidth, nBarHeight = nil, nil
    nBarOffsetX, nBarOffsetY = nil, nil

    nNextUpdate = 0

    bAllowRun = Menu.IsEnabled(ManaBar.ScriptEnable) and 1 or 0
    bAllowDraw = 0

    Log.Write("[ManaBar.lua][OnGameEnd] Reset variables.")
end

function ManaBar.OnMenuOptionChange(option, old, new)
    if option == ManaBar.ScriptEnable then
        bAllowRun = new

        if Heroes.GetLocal() == nil then return end
        hMyHero = nil
        hLocalHero = nil

        for _ in pairs(aEntityList) do
            aEntityList[_] = nil
        end
        hHero = nil
        vHeroOrigin = nil
        sHeroClass = nil
        bSearchBrew = 0

        x_w2s, y_w2s = nil, nil
        nBarWidth, nBarHeight = nil, nil
        nBarOffsetX, nBarOffsetY = nil, nil

        nNextUpdate = 0

        bAllowDraw = 0
    end

    if Heroes.GetLocal() == nil then return end
    if not Menu.IsEnabled(ManaBar.ScriptEnable) then return end

    if option == ManaBar.ScriptEnableManualSetup then
        nBarHeight = Menu.GetValue(ManaBar.OffsetBarHeight)

        if old > 0 then -- This is from On to Off
            nBarWidth = RoundNumber((nScreenHeight/480) * 45, 0)

            nBarOffsetX = RoundNumber(nBarWidth/2, 0) + 2
            nBarOffsetY = RoundNumber(nScreenHeight/480 * 9, 0)
        else
            nBarWidth = Menu.GetValue(ManaBar.OffsetBarWidth)

            nBarOffsetX = Menu.GetValue(ManaBar.OffsetPosX)
            nBarOffsetY = Menu.GetValue(ManaBar.OffsetPosY)
        end
    end

    if
        (
            option == ManaBar.OffsetBarWidth
            or option == ManaBar.OffsetBarHeight
            or option == ManaBar.OffsetPosX
            or option == ManaBar.OffsetPosY
        )
    then
        nBarHeight = Menu.GetValue(ManaBar.OffsetBarHeight)

        if not Menu.IsEnabled(ManaBar.ScriptEnableManualSetup) then return end

        nBarWidth = Menu.GetValue(ManaBar.OffsetBarWidth)
        nBarOffsetX = Menu.GetValue(ManaBar.OffsetPosX)
        nBarOffsetY = Menu.GetValue(ManaBar.OffsetPosY)
    end

end

function ManaBar.IsOnScreen(x_position, y_position)
    if
        (x_position < 1)
        or (y_position < 1)
        or (x_position > nScreenWidth)
        or (y_position > nScreenHeight)
    then
        return false
    end

    return true
end

function ManaBar.OnUpdate()
    if bAllowRun == 0 then return end

    if hMyHero == nil then
        hLocalHero = Heroes.GetLocal()

        if hMyHero ~= hLocalHero then
            hMyHero = hLocalHero

            hHero = nil
            vHeroOrigin = nil
            sHeroClass = nil
            bSearchBrew = 0

            x_w2s, y_w2s = nil, nil
            nBarWidth = RoundNumber((nScreenHeight/480) * 45, 0)
            nBarHeight = Menu.GetValue(ManaBar.OffsetBarHeight)

            nBarOffsetX = RoundNumber(nBarWidth/2, 0) + 2
            nBarOffsetY =  RoundNumber(nScreenHeight/480 * 9, 0)

            if Menu.IsEnabled(ManaBar.ScriptEnableManualSetup) then
                nBarWidth = Menu.GetValue(ManaBar.OffsetBarWidth)

                nBarOffsetX = Menu.GetValue(ManaBar.OffsetPosX)
                nBarOffsetY = Menu.GetValue(ManaBar.OffsetPosY)
            end

            nNextUpdate = 0

            bAllowDraw = 1
            Log.Write("[ManaBar.lua][OnUpdate] Game started, init!")
            return
        end
    end

    if nNextUpdate > GameRules.GetGameTime() then return end

    for _ in pairs(aEntityList) do
        aEntityList[_] = nil
    end

    bSearchBrew = 0

    for i = 1, Heroes.Count() do
        hHero = Heroes.Get(i)

        if
            hHero ~= nil
            and not Entity.IsDormant(hHero)
            and Entity.IsAlive(hHero)
            and not Entity.IsSameTeam(hMyHero, hHero)
            and not Entity.GetField(hHero, "m_bIsIllusion")
            and not NPC.IsIllusion(hHero)
            and Entity.IsPlayer(Entity.GetOwner(hHero))
        then
            sHeroClass = Entity.GetClassName(hHero)
            if
                (
                    sHeroClass == "C_DOTA_Unit_Hero_Brewmaster"
                    or sHeroClass == "C_DOTA_Unit_Hero_Rubick"
                )
                and NPC.HasModifier(hHero, "modifier_brewmaster_primal_split")
            then
                bSearchBrew = 1
                goto continue
            end

            aEntityList[#aEntityList + 1] = {hHero, 0}

            ::continue::
        end
    end

    if bSearchBrew == 1 then
        for _, v in pairs(Entities.GetAll("C_DOTA_Unit_Brewmaster_PrimalEarth")) do
            if
                not Entity.IsSameTeam(hMyHero, v)
                and not Entity.IsDormant(v)
                and Entity.IsAlive(v)
            then
                aEntityList[#aEntityList + 1] = {v, RoundNumber(nBarOffsetY * 0.25, 0)}
            end
        end

        for _, v in pairs(Entities.GetAll("C_DOTA_Unit_Brewmaster_PrimalStorm")) do
            if
                not Entity.IsSameTeam(hMyHero, v)
                and not Entity.IsDormant(v)
                and Entity.IsAlive(v)
            then
                aEntityList[#aEntityList + 1] = {v, RoundNumber(nBarOffsetY * 0.25, 0)}
            end
        end

        for _, v in pairs(Entities.GetAll("C_DOTA_Unit_Brewmaster_PrimalFire")) do
            if
                not Entity.IsSameTeam(hMyHero, v)
                and not Entity.IsDormant(v)
                and Entity.IsAlive(v)
            then
                aEntityList[#aEntityList + 1] = {v, RoundNumber(nBarOffsetY * 0.25, 0)}
            end
        end
    end

    nNextUpdate = GameRules.GetGameTime() + 0.12
end

function ManaBar.OnDraw()
    if bAllowDraw == 0 then return end

    for _, v in pairs(aEntityList) do
        vHeroOrigin = Entity.GetAbsOrigin(v[1])
        vHeroOrigin:SetZ(vHeroOrigin:GetZ() + NPC.GetHealthBarOffset(v[1]))
        x_w2s, y_w2s = Renderer.WorldToScreen(vHeroOrigin)

        if ManaBar.IsOnScreen(x_w2s, y_w2s) then
            -- Draw black background
            Renderer.SetDrawColor(0, 0, 0, 255)
            Renderer.DrawFilledRect(
                x_w2s - nBarOffsetX,
                y_w2s - nBarOffsetY + v[2],
                nBarWidth,
                nBarHeight
            )

            -- Draw the actual mana bar
            Renderer.SetDrawColor(79, 120, 249, 255)
            Renderer.DrawFilledRect(
                x_w2s - nBarOffsetX + 1,
                y_w2s - nBarOffsetY + v[2] + 1,
                fCeil((nBarWidth - 2) * (NPC.GetMana(v[1]) /  NPC.GetMaxMana(v[1]))),
                nBarHeight - 2
            )
        end
    end
end

return ManaBar
