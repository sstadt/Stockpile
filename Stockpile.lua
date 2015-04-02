
-- ------------------------
-- GLOBAL VARIABLES
-- ------------------------

Stockpile = CreateFrame("Frame", "Stockpile", UIParent)

-- ------------------------
-- EVENT ACTIONS
-- ------------------------

Stockpile.actions = {

  ["PLAYER_ENTERING_WORLD"] = function()
    Stockpile_ScanBags(0, 4)
  end,

  -- ["BAG_UPDATE"] = function(containerId)
  --  p('--------------------------')
  --  p('Bag #' .. containerId .. ' has ' .. GetContainerNumSlots(containerId) .. ' slots')
  --  p('--------------------------')
  -- end,

  ["ITEM_PUSH"] = function(bag, iconPath)
    p('--------------------------')
    p('ITEM_PUSH fired:')
    p(bag)
    p(iconPath)
    p('--------------------------')
  end,

  ["BANKFRAME_OPENED"] = function()
    Stockpile_ScanBags(5, 11)
  end,

  ["BANKFRAME_CLOSED"] = function()
    p('--------------------------')
    p('BANKFRAME_CLOSED fired')
    p('--------------------------')
  end,

  ["ADDON_LOADED"] = function(addonName)
    Stockpile.character = UnitName('player')

    if (addonName == 'Stockpile') then
      if (StockpileInventoryData == nil) then
        StockpileInventoryData = {
          [Stockpile.character] = {
            bank = {},
            bags = {},
            voidStorage = {}
          }
        }
      elseif (StockpileInventoryData[Stockpile.character] == nil) then
        StockpileInventoryData[Stockpile.character] = {
          bank = {},
          bags = {},
          voidStorage = {}
        }
      end
    end
  end,

}

function Stockpile_ScanBags(start, stop)
  for bag = start, stop do
    for slot = 1, GetContainerNumSlots(bag) do
      local item = GetContainerItemLink(bag, slot)
      if (item ~= nil) then
        local itemId = string.match(item, "(%d+)")
        print(GetItemCount(item) .. 'x ' .. itemId)
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


-- -------------------------
-- MISC FUNCTIONS
-- -------------------------

-- p FUNCTION
-- Print.  Handy for debugging.
function p(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg, 1, .4, .4)
end

