local addonName = ...
local Constants = {
    DELVERS_BOUNTY_MAP = 233071,
    WAVE_SCRAMBLER_2000 = 233186,
    DELVE_O_BOT_7001 = 230850,
    COFFER_KEY = 3028,
    UNDERCOIN = 2803,

    DELVERS_BOUNTY_QUEST_ID = 86371,

    BUTTON_X_AXIS_OFFSET = -20,
    BUTTON_SIZE = 40,
}

--- Layout frames horizontally with spacing.
---
--- @param frames
--- @param startAnchor
--- @param spacing
local function layoutHorizontally(frames, startAnchor, spacing)
    local anchor = startAnchor
    for i, frame in ipairs(frames) do
        frame:ClearAllPoints()
        if i == 1 then
            frame:SetPoint("LEFT", anchor, "LEFT", 0, 0)
        else
            frame:SetPoint("LEFT", frames[i-1], "RIGHT", spacing, 0)
        end
    end
end

--- Create an invisible button frame. This is useful for when a button
--- is disabled but you still want a tooltip to appear in place.
---
--- @param buttonFrame table
local function createInvisibleButton(buttonFrame)
    local invisibleButton = CreateFrame("Button", nil, buttonFrame)
    invisibleButton:SetAllPoints(buttonFrame)
    invisibleButton:SetFrameLevel(buttonFrame:GetFrameLevel() + 1)
    invisibleButton:EnableMouse(true)
    return invisibleButton
end


--- Set the tooltip content for a button frame.
---
--- @param buttonFrame table
--- @param header string
--- @param body string
local function setTooltipForButton(buttonFrame, header, body)
    buttonFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(header, 1, 0.82, 0)
        GameTooltip:AddLine(body, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    buttonFrame:SetScript("OnLeave", GameTooltip_Hide)
end

--- Add a tooltip to a button frame.
---
--- @param buttonFrame table
--- @param header string
--- @param body string
local function addTooltipToButton(buttonFrame, header, body)
    if type(buttonFrame) ~= "table" or type(header) ~= "string"  or type(body) ~= "string" then
        return
    end
    if not buttonFrame:IsEnabled() then
        if not buttonFrame.invisibleTooltipButton then
            buttonFrame.invisibleTooltipButton = createInvisibleButton(buttonFrame)
        else
            buttonFrame.invisibleTooltipButton:Show()
        end
        setTooltipForButton(buttonFrame.invisibleTooltipButton, header, body)
    else
        setTooltipForButton(buttonFrame, header, body)
        if buttonFrame.invisibleTooltipButton then
            buttonFrame.invisibleTooltipButton:Hide()
        end
    end
end

---
--- Add Button for the Delvers Bounty Map
---
local function delversBountyButton()
    local itemCount = GetItemCount(Constants.DELVERS_BOUNTY_MAP)
    local itemButton = CreateFrame(
            "Button",
            addonName .. "DelversBountyButton",
            DelvesDashboardFrame,
            "SecureActionButtonTemplate"
    )
    itemButton:SetAttribute("type", "item")
    itemButton:SetAttribute("item", Constants.DELVERS_BOUNTY_MAP)
    itemButton:SetSize(Constants.BUTTON_SIZE, Constants.BUTTON_SIZE)
    itemButton:SetPoint("BOTTOMRIGHT", Constants.BUTTON_X_AXIS_OFFSET, 30)

    local icon = itemButton:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(GetItemIcon(Constants.DELVERS_BOUNTY_MAP))

    if itemCount == 0 then
        icon:SetDesaturated(true)
        itemButton:Disable()
    else
        icon:SetDesaturated(false)
    end

    local checkmark = itemButton:CreateTexture(nil, "OVERLAY")
    checkmark:SetSize(14, 14)
    checkmark:SetPoint("TOPRIGHT", itemButton, "BOTTOMRIGHT", 7, 7)
    checkmark:SetAtlas("common-icon-checkmark")

    local done = C_QuestLog.IsQuestFlaggedCompleted(Constants.DELVERS_BOUNTY_QUEST_ID)
    if done then
        checkmark:Show()
    else
        checkmark:Hide()
    end

    local message = "You have " .. (done and "" or "not ") .. "used your delvers bounty map this week."
    addTooltipToButton(itemButton, "Delvers Bounty", message)
end

---
--- Add Button for the Wave Scrambler 2000
---
local function scramblerButton()
    local itemCount = GetItemCount(Constants.WAVE_SCRAMBLER_2000)
    local itemButton = CreateFrame(
            "Button",
            addonName .. "ScramblerButton",
            DelvesDashboardFrame,
            "SecureActionButtonTemplate"
    )
    itemButton:SetAttribute("type", "item")
    itemButton:SetAttribute("item", Constants.WAVE_SCRAMBLER_2000)
    itemButton:SetSize(Constants.BUTTON_SIZE, Constants.BUTTON_SIZE)
    itemButton:SetPoint("BOTTOMRIGHT", Constants.BUTTON_X_AXIS_OFFSET, 75)

    local icon = itemButton:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(GetItemIcon(Constants.WAVE_SCRAMBLER_2000))

    if itemCount == 0 then
        icon:SetDesaturated(true)
        itemButton:Disable()
    else
        icon:SetDesaturated(false)
    end

    addTooltipToButton(itemButton, "Wave Scrambler 2000", "Use this to summon the Underpin in a bountiful delve to guarantee a delver's bounty.")
end


---
--- Add Button for the Delve-O-Bot toy
---
local function delveBotButton()
    local _, _, iconTexture = C_ToyBox.GetToyInfo(Constants.DELVE_O_BOT_7001)

    if not PlayerHasToy(Constants.DELVE_O_BOT_7001) then
        return
    end

    local itemButton = CreateFrame(
            "Button",
            addonName .. "DelveBotButton",
            DelvesDashboardFrame,
            "SecureActionButtonTemplate"
    )
    itemButton:SetAttribute("type", "toy")
    itemButton:SetAttribute("toy", Constants.DELVE_O_BOT_7001)
    itemButton:SetSize(Constants.BUTTON_SIZE, Constants.BUTTON_SIZE)
    itemButton:SetPoint("BOTTOMRIGHT", Constants.BUTTON_X_AXIS_OFFSET, 120)

    local icon = itemButton:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(iconTexture)

    itemButton:RegisterForClicks("AnyUp")

    local cooldown = CreateFrame("Cooldown", nil, itemButton, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    local start, duration = C_Container.GetItemCooldown(Constants.DELVE_O_BOT_7001)
    cooldown:SetCooldown(start, duration)

    addTooltipToButton(itemButton, "Delve-O-Bot 7001", "Fly to the next bountiful delve.")
end


---
--- Display the number of coffer keys available.
---
local function cofferKeysDisplay()
    local cofferKeysInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.COFFER_KEY)

    if not cofferKeysInfo then return end

    local count = cofferKeysInfo.quantity

    local item = CreateFrame(
            "Frame",
            addonName .. "CofferKeys",
            DelvesDashboardFrame
    )
    item:SetSize(50, 30)
    local keysIcon = CreateFrame(
            "Frame",
            addonName .. "CofferKeyIcon",
            item
    )
    keysIcon:SetSize(12, 12)
    keysIcon:SetPoint("RIGHT", item)

    local keysTex = keysIcon:CreateTexture(nil, "OVERLAY")
    keysTex:SetAllPoints()
    keysTex:SetTexture(cofferKeysInfo.iconFileID)

    local text = item:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    text:SetText(tostring(count))
    text:SetPoint("RIGHT", keysIcon, "LEFT", -5, 0)
    text:SetJustifyH("RIGHT")
    text:SetTextColor(1, 1, 1, 1)

    item:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

    item:SetScript("OnEvent", function (currencyType, quantity, _, _, _)
        if currencyType ~= Constants.COFFER_KEY then
            return
        end
        text:SetText(tostring(quantity))
    end)

    return item
end


---
--- Display undercoins
---
local function undercoinDisplay()
    local undercoinInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.UNDERCOIN)

    if not undercoinInfo then return end

    local count = undercoinInfo.quantity

    local item = CreateFrame(
            "Frame",
            addonName .. "Undercoin",
            DelvesDashboardFrame
    )
    item:SetSize(50, 30)

    local keysIcon = CreateFrame(
            "Frame",
            addonName .. "UndercoinIcon",
            item
    )
    keysIcon:SetSize(12, 12)
    keysIcon:SetPoint("RIGHT", item)

    local keysTex = keysIcon:CreateTexture(nil, "OVERLAY")
    keysTex:SetAllPoints()
    keysTex:SetTexture(undercoinInfo.iconFileID)

    local text = item:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    text:SetText(tostring(count))
    text:SetPoint("RIGHT", keysIcon, "LEFT", -5, 0)
    text:SetJustifyH("RIGHT")
    text:SetTextColor(1, 1, 1, 1)

    item:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

    item:SetScript("OnEvent", function (currencyType, quantity, _, _, _)
        if currencyType ~= Constants.UNDERCOIN then
            return
        end
        text:SetText(tostring(quantity))
    end)

    return item
end


local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, _, addon)
    if addon == "Blizzard_DelvesDashboardUI" then
        if DelvesDashboardFrame then
            delveBotButton()
            scramblerButton()
            delversBountyButton()
            cofferKeysDisplay()

            local row = CreateFrame("Frame", nil, DelvesDashboardFrame)
            row:SetSize(110, 30)
            row:SetPoint("BOTTOMRIGHT", -75, 2)

            local frames = {cofferKeysDisplay(), undercoinDisplay()}
            layoutHorizontally(frames, row, 5)
        end
    end
end)
