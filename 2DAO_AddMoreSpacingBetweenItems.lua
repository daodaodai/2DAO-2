--[[
 * ReaScript Name: 2DAO_AddMoreSpacingBetweenItems.lua
 * Description: To a series of selected items, move them so that extra spacing is added in between.
				Humanization factor gives a touch of randomness to the spacing
				本脚本初衷是：切开的脚步片段，增加时长，从而达到调整走路速度的目的。
				脚本还没写完哈！
 * Author: 2Dao
 * Date: 2021.09.11
--]]



-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

itemsCount = 0
invalidLength = -1

------------------------------------------------------- END OF USER CONFIG AREA

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

---------------------------------------

function GetSpaceInterval_UserInput()

	local interval = 0.3
	local humanizeVal = 3
	local bOK = false
	
	-- 人性化 value define the level of randomization added to the time interval
	strInput = tostring(interval)..","..tostring(humanizeVal)
	retval, strInput = reaper.GetUserInputs("items 之间想间隔多长:", 2, "间隔时长：秒,人性化程度（0-100）", strInput)
	
	if retval then
		interval, humanizeVal = string.match(strInput, "(.*),(.*)")
		interval = tonumber(interval)
		humanizeVal = tonumber(humanizeVal)
		
		if (interval > 0 or humanizeVal >=0 ) then
			bOK = true
			
		end
	end

	return bOK, interval, humanizeVal
end

---------------------------------------
-- real interval = interval + random_number,
-- the random_number is in the range of [0, (humanizeVal/100)*interval]
function ComputeInterval(interval, humanizeVal)
	
	local tempPercent = math.random(0, humanizeVal)
	local temp = interval * ( tempPercent/100 + 1 )
	--showMsg(tostring(interval).." 人性化后的 interval "..tostring(temp), "--")
	return temp
	
end


---------------------------------------


function main()

	local bOK, interval, humanizeVal = GetSpaceInterval_UserInput()
	local position = 0
	local length = 0
	local endPos = 0
	local newPosForNextItem = 0
	local strTemp = ""
	
	math.randomseed(tostring(math.sin(os.time())):sub(4, 12))
	
	if bOK == true then
		for  i = itemsCount - 1, 1, -1 do
			local item = reaper.GetSelectedMediaItem(0, i)
			thisInterval = ComputeInterval(interval, humanizeVal)
			
			if item then
				if i == 0 then				
					-- our 1st item in the selection
					position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
					length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
					
					strTemp = tostring(thisInterval)
					newPosForNextItem = position + length + thisInterval
				else
					-- our next item. It needs to be moved					
					reaper.SetMediaItemPosition(item, newPosForNextItem, true)
					
					-- I suspect the UI refresh is slower then needed, as I see some items do not get moved
					-- Just in case this is the reason, let's add some steps before moving the next item
					--for j = 0, 100 do
					--	local temp = "hey"
					--end
					
					-- Get the new end position of this item, compute the new position for the next item
					position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
					length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
					
					newPosForNextItem = position + length + thisInterval
					strTemp = strTemp..'~'..tostring(thisInterval)
				end
			end
		end
	else
		showMsg("Something wrong with the user input", "哟~")
	end
	
	showMsg(strTemp, '--')
end

-- INIT

-- See if there is items selected
itemsCount = reaper.CountSelectedMediaItems(0)

if itemsCount > 1 then

	reaper.PreventUIRefresh(1)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	main()

	reaper.Undo_EndBlock("Add more spacing between items", - 1) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.UpdateArrange()

	reaper.PreventUIRefresh(-1)
else
	showMsg("需要选中至少两个 items", "提示")

end
