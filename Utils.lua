local addonName, addon = ...

local TofusUtils = {}

addon.Utils = TofusUtils


---Layout frames horizontally with spacing.
---
---@param frames table
---@param startAnchor number
---@param spacing number
function TofusUtils:LayoutHorizontally(frames, startAnchor, spacing)
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


---Create a button for a toy.
--- 
---@param name string
---@param toyID number
---@param yOffset number
---@return table|Button|SecureActionButtonTemplate
---@return Texture
function TofusUtils:CreateToyButton(name, toyID, yOffset)
    local _, _, iconTexture = C_ToyBox.GetToyInfo(toyID)

    if not PlayerHasToy(toyID) then
        return {}, {}
    end

    local itemButton = CreateFrame(
            "Button",
            addonName .. name,
            DelvesDashboardFrame,
            "SecureActionButtonTemplate"
    )
    itemButton:SetAttribute("type", "toy")
    itemButton:SetAttribute("toy", toyID)
    itemButton:SetSize(addon.Constants.BUTTON_SIZE, addon.Constants.BUTTON_SIZE)
    itemButton:SetPoint("BOTTOMRIGHT", addon.Constants.BUTTON_X_AXIS_OFFSET, yOffset)

    local icon = itemButton:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(iconTexture)

    itemButton:RegisterForClicks("AnyUp")

    local cooldown = CreateFrame("Cooldown", nil, itemButton, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    local start, duration = C_Container.GetItemCooldown(toyID)
    cooldown:SetCooldown(start, duration)

    return itemButton, icon
end



---Create a button for an item. `Item` in this case can refer to an actual item, or a toy.
--- 
---@param name string
---@param itemID number
---@param yOffset number
---@return table|Button|SecureActionButtonTemplate
---@return Texture
function TofusUtils:CreateItemButton(name, itemID, yOffset, desaturationCondition, usable)
    local template = usable and "SecureActionButtonTemplate" or nil
    local itemButton = CreateFrame(
        "Button",
        addonName .. name,
        DelvesDashboardFrame,
        template
    )
    if usable then
        itemButton:SetAttribute("type", "item")
        itemButton:SetAttribute("item", itemID)
    else
        itemButton:SetAttribute("type", "macro")
        itemButton:SetAttribute("macrotext", "/use item:" .. itemID)
    end
    itemButton:SetSize(addon.Constants.BUTTON_SIZE, addon.Constants.BUTTON_SIZE)
    itemButton:SetPoint("BOTTOMRIGHT", addon.Constants.BUTTON_X_AXIS_OFFSET, yOffset)

    local icon = itemButton:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(C_Item.GetItemIconByID(itemID))

    if desaturationCondition() then
        icon:SetDesaturated(true)
        itemButton:Disable()
    else
        icon:SetDesaturated(false)
        itemButton:Enable()
    end

    return itemButton, icon
end

---Create an invisible button frame. This is useful for when a button
---is disabled but you still want a tooltip to appear in place.
---
---@param buttonFrame table
function TofusUtils:CreateInvisibleButton(buttonFrame)
    local invisibleButton = CreateFrame("Button", nil, buttonFrame)
    invisibleButton:SetAllPoints(buttonFrame)
    invisibleButton:SetFrameLevel(buttonFrame:GetFrameLevel() + 1)
    invisibleButton:EnableMouse(true)
    return invisibleButton
end

---Create a checkmark icon for a frame.
---@param parent any
---@return unknown
function TofusUtils:AddCheckmarkTexture(parent)
    local checkmark = parent:CreateTexture(nil, "OVERLAY")
    checkmark:SetSize(14, 14)
    checkmark:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 7, 7)
    checkmark:SetAtlas("common-icon-checkmark")
    return checkmark
end

---Set the tooltip content for a frame.
---
---@param frame table
---@param header string
---@param body string
function TofusUtils:SetTooltipForFrame(frame, header, body)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(header, 1, 0.82, 0)
        GameTooltip:AddLine(body, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", GameTooltip_Hide)
end

---Add a tooltip to a button frame.
---
---@param buttonFrame table
---@param header string
---@param body string
function TofusUtils:AddTooltipToButton(buttonFrame, header, body)
    if type(buttonFrame) ~= "table" or type(header) ~= "string"  or type(body) ~= "string" then
        return
    end
    if not buttonFrame:IsEnabled() then
        if not buttonFrame.invisibleTooltipButton then
            buttonFrame.invisibleTooltipButton = self:CreateInvisibleButton(buttonFrame)
        else
            buttonFrame.invisibleTooltipButton:Show()
        end
        self:SetTooltipForFrame(buttonFrame.invisibleTooltipButton, header, body)
    else
        self:SetTooltipForFrame(buttonFrame, header, body)
        if buttonFrame.invisibleTooltipButton then
            buttonFrame.invisibleTooltipButton:Hide()
        end
    end
end


---Add text to an icon frame.
---@param frame table
---@param text any
---@return FontString
function TofusUtils:AddIconText(frame, rawText)
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetText(tostring(rawText))
    text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    text:SetJustifyH("RIGHT")
    text:SetTextColor(1, 1, 1, 1)
    return text
end


---Add a border to a frame. Defaults to a blue border the size of Constants.BUTTON_SIZE.
---@param frame table
---@param color table{r=number, g=number, b=number}
---@param sizeX number
---@param sizeY number
function TofusUtils:AddBorder(frame, color, sizeX, sizeY)
    if type(frame) ~= "table" then
        return
    end

    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    border:SetSize(sizeX or addon.Constants.BUTTON_SIZE, sizeY or addon.Constants.BUTTON_SIZE)
    border:SetPoint("CENTER", frame, "CENTER", 0, 0)
    if color then
        border:SetVertexColor(color.r, color.g, color.b)
    else
        border:SetVertexColor(0, 0.44, 0.87)
    end
end

---Add a debug border to a frame.
---@param frame table
---@param r number
---@param g number
---@param b number
function TofusUtils:AddDebugBorder(frame, r, g, b)
    if frame.debugBorder then return end

    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetColorTexture(r or 1, g or 0, b or 0)
    border:SetDrawLayer("OVERLAY", 7)
    border:SetAlpha(0.5)

    local inner = frame:CreateTexture(nil, "OVERLAY")
    inner:SetPoint("TOPLEFT", 1, -1)
    inner:SetPoint("BOTTOMRIGHT", -1, 1)
    inner:SetColorTexture(0, 0, 0, 1)

    frame.debugBorder = border
end


---Get the number of keys earned from chests this week.
---@return integer
function TofusUtils:GetKeysEarnedFromChestsThisWeek()
    local keysEarnedFromChestsThisWeek = 0
    for i = 0, 3 do
        if C_QuestLog.IsQuestFlaggedCompleted(84736+i) then
            keysEarnedFromChestsThisWeek = keysEarnedFromChestsThisWeek + 1
        end
    end
    return keysEarnedFromChestsThisWeek
end


--------------------------------------------------
--- Text Color Functions
--------------------------------------------------

function TofusUtils:TextRed(text)
    return "|cFFFF0000" .. text .. "|r"
end

function TofusUtils:TextYellow(text)
    return "|cFFFFFF00" .. text .. "|r"
end

function TofusUtils:TextUncommon(text)
    return "|cFF1EFF00" .. text .. "|r"
end

function TofusUtils:TextRare(text)
    return "|cFF0070DD" .. text .. "|r"
end

function TofusUtils:TextEpic(text)
    return "|cFF9F00FF" .. text .. "|r"
end

function TofusUtils:TextWhite(text)
    return "|cFFFFFFFF" .. text .. "|r"
end