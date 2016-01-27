function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

local itemLevelLimit = 400;
local bannedSubClasses = Set {"Consumable", "Potion", "Other", "Food & Drink", "Flask", "Elixir", "Reagent"};
local bannedClasses = Set {"Trade Goods"};
local bannedItemsById = Set {71084, 71085, 71086};


-- vendors items under certain ilvl threshold
-- and not in the above banned sets
function SellItems()
	local count = 0;
	for b=0,4 do 
		for s=1,GetContainerNumSlots(b)do 
			local item_link=GetContainerItemLink(b,s);
			local item_id = GetContainerItemID(b,s);
			if item_link then 
				name, link, quality, iLvl, reqLvl, class, subClass, maxStack, _, _, price = GetItemInfo(item_link)
				if iLvl < itemLevelLimit 
				and not bannedSubClasses[subClass]
				and not bannedClasses[class]
				and not bannedItemsById[item_id]
				and price > 0 then 
					--print("Selling "..item_link..iLvl.." for "..price.." class "..subClass)
					--print(item_link.." - ID - "..item_id.."  "..class.."    "..subClass);
					UseContainerItem(b,s);
					count = count + price;
				end 
			end
		end
	end
	
	local gold, silver, copper = floor(count/10000) or 0, floor((count%10000)/100) or 0, count%100
	print("Total: "..gold.."g "..silver.."s "..copper.."c ");
end

-- setup slash commands
SLASH_JUNK1 = '/junk'
local function handler(msg, editbox)
	if msg == 'sell' then
		SellItems();
	else
		print("You're stupid");
	end
end

SlashCmdList["JUNK"] = handler; -- Also a valid assignment strategy
