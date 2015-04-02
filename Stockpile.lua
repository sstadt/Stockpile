
-- ------------------------
-- GLOBAL VARIABLES
-- ------------------------

Stockpile = CreateFrame("Frame", "Stockpile", UIParent)

local tooltipLinesAdded = false

-- ------------------------
-- EVENT ACTIONS
-- ------------------------

Stockpile.actions = {

  ["ADDON_LOADED"] = function(addonName)

    if (addonName == 'Stockpile') then
      Stockpile.character = UnitName('player')
      Stockpile.realm = GetRealmName()

      Stockpile_InitializeInventoryData()
      Stockpile_ScanBags(0, NUM_BAG_SLOTS)
    end
  end,

  ["BANKFRAME_CLOSED"] = function()
    StockpileInventoryData[Stockpile.realm][Stockpile.character] = {}
    Stockpile_ScanBags(-1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
  end,

}

-- -------------------------
-- STOCKPILE FUNCTIONS
-- -------------------------

function Stockpile_InitializeInventoryData()
  if (StockpileInventoryData == nil) then
    StockpileInventoryData = {}
  end
end

function Stockpile_ScanBags(start, stop)
  for bag = start, stop do
    Stockpile_ScanBag(bag)
  end
  if (start < 1) then
    Stockpile_ScanBag(REAGENTBANK_CONTAINER)
  end
end

function Stockpile_ScanBag(bag)
  for slot = 1, GetContainerNumSlots(bag) do
    local item = GetContainerItemLink(bag, slot)
    if (item ~= nil) then
      local itemId = Stockpile_GetItemIdFromLink(item)
      StockpileInventoryData[Stockpile.realm][Stockpile.character][itemId] = GetItemCount(item, true)
    end
  end
end

function Stockpile_GetItemIdFromLink(link)
  return string.match(link, "item:(%d+)")
end

function Stockpile_GetStockpiledItems(itemId)
  local items = {}

  for character, list in pairs(StockpileInventoryData[Stockpile.realm]) do
    if (character ~= Stockpile.character and list[itemId] ~= nil) then
      items[character] = list[itemId]
    end
  end

  return items
end

local function Stockpile_OnTooltipSetItem(tooltip)
  if not tooltipLinesAdded then
    local itemName, itemLink = tooltip:GetItem()
    local itemId = Stockpile_GetItemIdFromLink(itemLink)
    local items = Stockpile_GetStockpiledItems(itemId)

    for character, count in pairs(items) do
      tooltip:AddLine(character .. ": " .. count)
    end

    tooltipLinesAdded = true
  end
end

local function Stockpile_OnTooltipCleared()
  tooltipLinesAdded = false
end

-- -------------------------
-- TOOLTIP HOOK
-- -------------------------

GameTooltip:HookScript("OnTooltipSetItem", Stockpile_OnTooltipSetItem)
GameTooltip:HookScript("OnTooltipCleared", Stockpile_OnTooltipCleared)

-- -------------------------
-- ONLOAD FUNCTION
-- -------------------------

function Stockpile_OnLoad()

  for event, action in pairs(Stockpile.actions) do
    Stockpile:RegisterEvent(event)
  end

  Stockpile:SetScript("OnEvent", Stockpile.OnEvent)

end

-- -------------------------
-- ONEVENT FUNCTION
-- -------------------------
  
function Stockpile:OnEvent(event, arg1, arg2)

  Stockpile.actions[event](arg1, arg2)

end


