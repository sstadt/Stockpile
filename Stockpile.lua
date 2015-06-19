
-- ------------------------
-- GLOBAL VARIABLES
-- ------------------------

Stockpile = CreateFrame("Frame", "Stockpile", UIParent)

Stockpile.tooltipLinesAdded = false

-- ------------------------
-- EVENT ACTIONS
-- ------------------------

Stockpile.actions = {

  ["ADDON_LOADED"] = function(addonName)

    if (addonName == 'Stockpile') then
      Stockpile.character = UnitName('player')
      Stockpile.realm = GetRealmName()

      Stockpile:InitializeInventoryData()
    end
  end,

  ["BANKFRAME_CLOSED"] = function()
    Stockpile:ScanBank()
  end,

  ["BAG_UPDATE"] = function()
    Stockpile:ScanBags()
  end

}

-- -------------------------
-- STOCKPILE FUNCTIONS
-- -------------------------

function Stockpile:InitializeInventoryData()
  if (StockpileInventoryData == nil) then
    StockpileInventoryData = {
      [Stockpile.realm] = {
        [Stockpile.character] = {
          bank = {},
          bags = {}
        }
      }
    }
  elseif (StockpileInventoryData[Stockpile.realm] == nil) then
    StockpileInventoryData[Stockpile.realm] = {
      [Stockpile.character] = {
        bank = {},
        bags = {}
      }
    }
  elseif (StockpileInventoryData[Stockpile.realm][Stockpile.character] == nil) then
    StockpileInventoryData[Stockpile.realm][Stockpile.character] = {
      bank = {},
      bags = {}
    }
  end
end

function Stockpile:ScanBags()
  StockpileInventoryData[Stockpile.realm][Stockpile.character]['bags'] = {}
  for bag = 0, 4 do
    Stockpile:ScanBag(bag, false)
  end
end

function Stockpile:ScanBank()
  StockpileInventoryData[Stockpile.realm][Stockpile.character]['bank'] = {}
  Stockpile:ScanBag(-1, true)
  Stockpile:ScanBag(REAGENTBANK_CONTAINER, true)
  for bag = 5, 11 do
    Stockpile:ScanBag(bag, true)
  end
end

function Stockpile:ScanBag(bag, isBankScan)
  for slot = 1, GetContainerNumSlots(bag) do
    local item = GetContainerItemLink(bag, slot)
    if (item ~= nil) then
      local itemId = Stockpile:GetItemIdFromLink(item)
      local itemCount = GetItemCount(item, isBankScan)
      local stockpileBucket = Stockpile:GetStockpileBucket(isBankScan)

      if (isBankScan and StockpileInventoryData[Stockpile.realm][Stockpile.character]['bags'][itemId] ~= nil) then
        itemCount = itemCount - StockpileInventoryData[Stockpile.realm][Stockpile.character]['bags'][itemId]
      end

      StockpileInventoryData[Stockpile.realm][Stockpile.character][stockpileBucket][itemId] = itemCount
    end
  end
end

function Stockpile:GetStockpileBucket(isBank)
  if (isBank) then
    return 'bank'
  else
    return 'bags'
  end
end

function Stockpile:GetItemIdFromLink(link)
  return string.match(link, "item:(%d+)")
end

function Stockpile:GetStockpiledItems(itemId)
  local items = {}

  for character, list in pairs(StockpileInventoryData[Stockpile.realm]) do
    if (character ~= Stockpile.character) then 
      if (list.bags[itemId] ~= nil or list.bank[itemId] ~= nil) then
        local count = 0

        if (list.bags[itemId] ~= nil) then
          count = count + list.bags[itemId]
        end

        if (list.bank[itemId] ~= nil) then
          count = count + list.bank[itemId]
        end

        items[character] = count
      end
    end
  end

  return items
end

-- -------------------------
-- TOOLTIP HOOK
-- -------------------------

local function Stockpile_OnTooltipSetItem(tooltip)
  if not tooltipLinesAdded then
    local itemName, itemLink = tooltip:GetItem()
    local itemId = Stockpile:GetItemIdFromLink(itemLink)
    local items = Stockpile:GetStockpiledItems(itemId)

    for character, count in pairs(items) do
      tooltip:AddLine(character .. ": " .. count)
    end

    Stockpile.tooltipLinesAdded = true
  end
end

local function Stockpile_OnTooltipCleared()
  Stockpile.tooltipLinesAdded = false
end

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


