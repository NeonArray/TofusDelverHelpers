local addonName, addon = ...
local Constants = {
    DELVERS_BOUNTY_MAP = 233071,
    WAVE_SCRAMBLER_2000 = 233186,
    DELVE_O_BOT_7001 = 230850,
    COFFER_KEY = 3028,
    UNDERCOIN = 2803,
    COFFER_KEY_SHARDS = 236096,
    COFFER_KEY_SHARD_S2_ITEM = 236096,

    DELVERS_BOUNTY_QUEST_ID = 86371,

    BUTTON_X_AXIS_OFFSET = -20,
    BUTTON_SIZE = 40,
}
addon.Constants = Constants
local Utils = addon.Utils

---
--- Add Button for the Delvers Bounty Map
---
local function DelversBountyButton()
    local itemButton, _ = Utils:CreateItemButton(
        "DelversBountyButton",
        Constants.DELVERS_BOUNTY_MAP,
        30,
        function ()
            return C_Item.GetItemCount(Constants.DELVERS_BOUNTY_MAP) == 0
        end
    )
    local checkmark = Utils:AddCheckmarkTexture(itemButton)
    local done = C_QuestLog.IsQuestFlaggedCompleted(Constants.DELVERS_BOUNTY_QUEST_ID)

    if done then
        checkmark:Show()
    else
        checkmark:Hide()
    end
    
    Utils:AddIconText(itemButton, tostring(C_Item.GetItemCount(Constants.DELVERS_BOUNTY_MAP)))

    local message = "You " .. (done and Utils:TextUncommon("have") or Utils:TextRed("have not")) .. " received your delvers bounty map this week."
    message = message .. "\n\n" .. Utils:TextYellow("Total: ") .. C_Item.GetItemCount(Constants.DELVERS_BOUNTY_MAP)
    Utils:AddTooltipToButton(itemButton, Utils:TextEpic("Delvers Bounty"), message)
end

---
--- Add Button for the Wave Scrambler 2000
---
local function ScramblerButton()
    local itemButton, _ = Utils:CreateItemButton(
        "WaveScramblerButton",
        Constants.WAVE_SCRAMBLER_2000,
        80,
        function ()
            return C_Item.GetItemCount(Constants.WAVE_SCRAMBLER_2000) == 0
        end
    )
    local message = "Use this to summon the Underpin in a bountiful delve to guarantee a delver's bounty."
    message = message .. "\n\n" .. Utils:TextYellow("Total: ") .. C_Item.GetItemCount(Constants.WAVE_SCRAMBLER_2000)
    Utils:AddTooltipToButton(itemButton, Utils:TextRare("Wave Scrambler 2000"), message)
end


---
--- Add Button for the Delve-O-Bot toy
---
local function DelveBotButton()
    local itemButton, _ = Utils:CreateToyButton(
        "DelveBotButton",
        Constants.DELVE_O_BOT_7001,
        130
    )
    Utils:AddTooltipToButton(itemButton, Utils:TextRare("Delve-O-Bot 7001"), "Fly to the next bountiful delve.")
end


---
--- Display the number of coffer keys available.
---
local function CofferKeysDisplay()
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

    local text = Utils:AddIconText(item, count)
    text:SetAllPoints()
    text:SetPoint("RIGHT", keysIcon, "LEFT", -5, 0)

    item:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

    item:SetScript("OnEvent", function (currencyType, quantity, _, _, _)
        if currencyType ~= Constants.COFFER_KEY then
            return
        end
        text:SetText(tostring(quantity))
    end)

    local keysEarnedFromChestsThisWeek = Utils:GetKeysEarnedFromChestsThisWeek()

    Utils:SetTooltipForFrame(
        item,
        Utils:TextEpic("Restored Coffer Keys"),
        "You've earned " .. Utils:TextUncommon(keysEarnedFromChestsThisWeek) .. " out of " .. Utils:TextUncommon("4") .. " keys from chests this week."
    )

    return item
end


---
--- Display undercoins
---
local function UndercoinDisplay()
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

    local text = Utils:AddIconText(item, count)
    text:SetAllPoints()
    text:SetPoint("RIGHT", keysIcon, "LEFT", -5, 0)

    item:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

    item:SetScript("OnEvent", function (currencyType, quantity, _, _, _)
        if currencyType ~= Constants.UNDERCOIN then
            return
        end
        text:SetText(tostring(quantity))
    end)

    return item
end

---
--- Display coffer key shards
---
local function CofferKeyShardsDisplay()
    local cofferKeyShards = C_Item.GetItemCount(Constants.COFFER_KEY_SHARDS)
    local itemButton, _ = Utils:CreateItemButton(
        "CofferKeyShard",
        Constants.COFFER_KEY_SHARD_S2_ITEM,
        180,
        function ()
            return cofferKeyShards < 100
        end,
        false
    )

    if cofferKeyShards >= 100 then
        Utils:AddBorder(itemButton)
    end

    local text = Utils:AddIconText(itemButton, cofferKeyShards)

    local numKeys = math.floor(cofferKeyShards / 100)
    local keysText = ""
    if numKeys > 0 then
        keysText = Utils:TextRed(numKeys)
    else
        keysText = Utils:TextUncommon(numKeys)
    end

    local message = "You have enough shards to create " .. keysText .. " Coffer Keys."
    message = message .. "\n\n" .. Utils:TextYellow("Total: ") .. cofferKeyShards

    Utils:AddTooltipToButton(itemButton, Utils:TextRare("Coffer Key Shards"), message)

    itemButton:RegisterEvent("BAG_UPDATE")

    itemButton:SetScript("OnEvent", function (_)
        local cofferKeyShards = C_Item.GetItemCount(Constants.COFFER_KEY_SHARDS)
        text:SetText(tostring(cofferKeyShards))
    end)

    return itemButton
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, _, loadedAddon)
    if loadedAddon == "Blizzard_DelvesDashboardUI" then
        if DelvesDashboardFrame then
            DelveBotButton()
            ScramblerButton()
            DelversBountyButton()
            CofferKeyShardsDisplay()

            local row = CreateFrame("Frame", nil, DelvesDashboardFrame)
            row:SetSize(120, 30)
            row:SetPoint("BOTTOMRIGHT", -65, 2)

            local frames = {
                CofferKeysDisplay(),
                UndercoinDisplay()
            }
            Utils:LayoutHorizontally(frames, row, 5)
        end
    end
end)
