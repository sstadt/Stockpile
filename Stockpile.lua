
-- ------------------------
-- GLOBAL VARIABLES
-- ------------------------

Stockpile = CreateFrame("Frame", "Stockpile", UIParent)

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
    Stockpile_ScanBags(-1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
  end,

}

-- -------------------------
-- STOCKPILE FUNCTIONS
-- -------------------------

function Stockpile_InitializeInventoryData()
  if (StockpileInventoryData == nil) then
    StockpileInventoryData = {
      [Stockpile.realm] = {
        [Stockpile.character] = {}
      }
    }
  elseif (StockpileInventoryData[Stockpile.realm] == nil) then
    StockpileInventoryData[Stockpile.realm] = {
      [Stockpile.character] = {}
    }
  elseif (StockpileInventoryData[Stockpile.realm][Stockpile.character] == nil) then
    StockpileInventoryData[Stockpile.realm][Stockpile.character] = {}
  end
end

function Stockpile_ScanBags(start, stop)
  StockpileInventoryData[Stockpile.realm][Stockpile.character] = {}

  for bag = start, stop do
    for slot = 1, GetContainerNumSlots(bag) do
      local item = GetContainerItemLink(bag, slot)
      if (item ~= nil) then
        local itemId = string.match(item, "item:(%d+)")
        StockpileInventoryData[Stockpile.realm][Stockpile.character][itemId] = GetItemCount(item, true)
      end
    end
  end
end

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


