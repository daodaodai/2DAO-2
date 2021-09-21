--[[
 * ReaScript Name: 2DAO_AddMoreSpacingBetweenItems_FixedInterval.lua
 * Description: To a series of selected items, move them so that extra spacing is added in between.
				本脚本初衷是：切开的脚步片段，增加时长，从而达到调整走路速度的目的。
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

	local interval = 0
	--local bOK = false
	local strInput = "0.3"
	retval, strInput = reaper.GetUserInputs("items 之间想间隔多长:", 1, "间隔时长：秒", strInput)
	
	if retval then
		interval = tonumber(strInput)
		
		--if (interval > 0) then
			--bOK = true			
		--end
	end

	return interval
end




---------------------------------------


function main()

	--local bOK, interval = GetSpaceInterval_UserInput()
	local bOK = true  -- 现在不管 interval 输入的是不是负数了。都可接受
	local interval = GetSpaceInterval_UserInput()
	local position = 0
	local newPos = 0
	--showMsg("interval="..tostring(interval), '--')
	
	if bOK == true then
		for  i = itemsCount - 1, 1, -1 do
			local item = reaper.GetSelectedMediaItem(0, i)
			
			if item then
				position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				newPos = position + (i * interval)
				reaper.SetMediaItemPosition(item, newPos, true)
			end
		end
	else
		showMsg("Something wrong with the user input", "哟~")
	end
end

-- INIT

-- See if there is items selected
itemsCount = reaper.CountSelectedMediaItems(0)

if itemsCount > 1 then

	--reaper.PreventUIRefresh(1)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	main()

	reaper.Undo_EndBlock("Add more spacing between items", - 1) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.UpdateArrange()

	--reaper.PreventUIRefresh(-1)
else
	showMsg("需要选中至少两个 items", "提示")

end
