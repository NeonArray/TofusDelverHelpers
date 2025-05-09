local addonName = ...
local Constants = {
    DELVERS_BOUNTY_MAP = 233071,
    WAVE_SCRAMBLER_2000 = 233186,
    DELVE_O_BOT_7001 = 230850,

    DELVERS_BOUNTY_QUEST_ID = 86371,

    BUTTON_X_AXIS_OFFSET = -20,
    BUTTON_SIZE = 40,
}

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
--- @param message string
local function setTooltipForButton(buttonFrame, message)
    buttonFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(message)
        GameTooltip:Show()
    end)
    buttonFrame:SetScript("OnLeave", GameTooltip_Hide)
end

--- Add a tooltip to a button frame.
---
--- @param buttonFrame table
--- @param message string
local function AddTooltipToButton(buttonFrame, message)
    if type(buttonFrame) ~= "table" or type(message) ~= "string" then
        return
    end
    if not buttonFrame:IsEnabled() then
        if not buttonFrame.invisibleTooltipButton then
            buttonFrame.invisibleTooltipButton = createInvisibleButton(buttonFrame)
        else
            buttonFrame.invisibleTooltipButton:Show()
        end
        setTooltipForButton(buttonFrame.invisibleTooltipButton, message)
    else
        setTooltipForButton(buttonFrame, message)
        if buttonFrame.invisibleTooltipButton then
            buttonFrame.invisibleTooltipButton:Hide()
        end
    end
end

---
--- Add Button for the Delvers Bounty Map
---
local function DelversBountyButton()
    local itemCount = GetItemCount(Constants.DELVERS_BOUNTY_MAP)
    local itemButton = CreateFrame("Button", addonName .. "DelversBountyButton", DelvesDashboardFrame, "SecureActionButtonTemplate")
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
    AddTooltipToButton(itemButton, message)
end

---
--- Add Button for the Wave Scrambler 2000
---
local function ScramblerButton()
    local itemCount = GetItemCount(Constants.WAVE_SCRAMBLER_2000)
    local itemButton = CreateFrame("Button", addonName .. "ScramblerButton", DelvesDashboardFrame, "SecureActionButtonTemplate")
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

    AddTooltipToButton(itemButton, "Wave Scrambler 2000")
end


---
--- Add Button for the Delve-O-Bot toy
---
local function DelveBotButton()
    local _, _, iconTexture = C_ToyBox.GetToyInfo(Constants.DELVE_O_BOT_7001)

    if not PlayerHasToy(Constants.DELVE_O_BOT_7001) then
        return
    end

    local itemButton = CreateFrame("Button", addonName .. "DelveBotButton", DelvesDashboardFrame, "SecureActionButtonTemplate")
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

    AddTooltipToButton(itemButton, "Delve-O-Bot 7001. Fly to the next bountiful delve.")
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, _, addon)
    if addon == "Blizzard_DelvesDashboardUI" then
        if DelvesDashboardFrame then
            DelveBotButton()
            ScramblerButton()
            DelversBountyButton()
        end
    end
end)


