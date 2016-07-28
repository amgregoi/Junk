function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

local itemLevelLimit = 649;
local bannedSubClasses = Set {"Consumable", "Potion", "Other", "Food & Drink", "Flask", "Elixir", "Reagent"};
local bannedClasses = Set {"Trade Goods"};
local bannedItemsById = Set {71084, 71085, 71086};
local EventFrame;
local isSelling = true;

-- vendors items under certain ilvl threshold
-- and not in the above banned sets
function SellItems(delete, nomsg, getValue)
	for b=0,4 do 
		for s=1,GetContainerNumSlots(b)do 
			local item_link=GetContainerItemLink(b,s);
			local item_id = GetContainerItemID(b,s);

			if item_link and item_id and GetItemInfo(item_link) then 
				name, link, quality, iLvl, reqLvl, class, subClass, maxStack, _, _, count = GetItemInfo(item_link)
				local p = count * select(2, GetContainerItemInfo(b, s))
				if iLvl < itemLevelLimit 
				and not bannedSubClasses[subClass]
				and not bannedClasses[class]
				and not bannedItemsById[item_id]
				and not select(3,GetContainerItemInfo(b,s))
				and p > 0 then 
					--print("Selling "..item_link);
					UseContainerItem(b,s);
					PickupMerchantItem();						
				end 
			end
		end
	end	
end

-- Gets total value of sold items
function GetValue()
	local count = 0;
	for b=0,4 do 
		for s=1,GetContainerNumSlots(b)do 
			local item_link=GetContainerItemLink(b,s);
			local item_id = GetContainerItemID(b,s);
			if item_link and item_id and GetItemInfo(item_link) then 
				local p = select(11, GetItemInfo(item_link))*select(2, GetContainerItemInfo(b, s))
				name, link, quality, iLvl, reqLvl, class, subClass, maxStack, _, _, _ = GetItemInfo(item_link)
				if iLvl < itemLevelLimit 
				and not bannedSubClasses[subClass]
				and not bannedClasses[class]
				and not bannedItemsById[item_id]
				and not select(3,GetContainerItemInfo(b,s))
				and p > 0 then 						
					count = count + p;
				end 
			end
		end
	end
	
	local gold, silver, copper = floor(count/10000) or 0, floor((count%10000)/100) or 0, count%100
	print("Total: "..gold.."g "..silver.."s "..copper.."c ");
end

-- Event Function
function runJunk(self,event)
	if event=="MERCHANT_SHOW" then
		self:RegisterEvent("BAG_UPDATE_DELAYED");
	elseif event=="MERCHANT_CLOSED" then
		self:UnregisterEvent("BAG_UPDATE_DELAYED");
		GetValue();
		return
	end 
	
--	if(isSelling) then 
		SellItems();
		--EventFrame:UnregisterEvent("MERCHANT_SHOW");
		--EventFrame:UnregisterEvent("MERCHANT_CLOSED");
--		isSelling = false;
	--end
end		

-- setup slash command handler
-- need to find event for merchant_Visible 
SLASH_JUNK1 = '/junk'
local function handler(msg, editbox)
	if msg == 'sell' then
		isSelling = true;
		runJunk()
		--[[EventFrame=CreateFrame("Frame");
		EventFrame:RegisterEvent("MERCHANT_SHOW");
		EventFrame:RegisterEvent("MERCHANT_CLOSED");
		EventFrame:SetScript("OnEvent",runJunk);
		]]--
	else
		print("try /junk sell");
	end
end
SlashCmdList["JUNK"] = handler;





