--[[
 * ReaScript Name: 2DAO_Rename_take_to_trackname_n_region.lua
 * Description: Glue selected items; rename the new item to $track【$region】；rename the sourse file.
 * Author: 2Dao
--]]



-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console
sectionName = "GlueItemsRenameToTRNames_"
section_dayOfMonth = "dayOfMonth"

------------------------------------------------------- END OF USER CONFIG AREA

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

---------------------------------------
-- If the day the tooltip was displayed was earlier than totday
-- return true so that the script will show the tooltip again.
function checkIfToShowTooltip ()
	
	local dayOfMonth = os.date("%d")
	
	local dayOfMonth_Saved = reaper.GetExtState(sectionName, section_dayOfMonth)
	local bDisplayMsg = true
	if (dayOfMonth_Saved == dayOfMonth) then
		bDisplayMsg = false
	end
	
	return bDisplayMsg
end


function main()

	local bDisplayMsg = checkIfToShowTooltip()
	
	local toolTip = "框选区域内的 items. 运行。\n items 的宽度尽量和region 对齐。\n\n 有时候 目标名字的文件已经存在，并且目标文件在其他 active projects 里面被占用，那是无法 really overwrite the target file 的。\n 需要去 the other active projects, copy all source into directory (in the Project Bay).\n 然后再回来运行本脚本，就能有效 overwrite the target file 了。"	
	if bDisplayMsg then
	
		showMsg(toolTip, "tool tip")
		local today = os.date("%d")
		
		-- We've just shown the tooltip. Now save the day it's displayed
		reaper.SetExtState(sectionName, section_dayOfMonth, tostring(today), true)
		
	end

	-- INITIALIZE loop through selected items
	for i = 0, count_sel_items - 1 do

		-- GET ITEMS
		local item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		local take = reaper.GetActiveTake(item)

		if take then
			-- Get take's region name 1st.
			local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

			local sNameOut = ""

			local marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion(0, item_pos)

			--local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0, region_idx)
			local iRetval, isrgn, pos, rgnend, sNameOut, markrgnindexnumber = reaper.EnumProjectMarkers2(0,  region_idx)
			
			--showMsg(sNameOut, "--")
			
			-- Get take's track name.
			local track = reaper.GetMediaItem_Track(item)
			local retval, track_name = reaper.GetTrackName(track)
			local sNewTakeName = track_name .. "【" .. sNameOut .. "】"
			
			-- SETNAMES

			if iRetval > 0 then
				-- reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", sNameOut, true)
				reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", sNewTakeName, true)
			end

		end

	end -- ENDLOOP through selected items

end

-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

	reaper.PreventUIRefresh(1)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	main()

	reaper.Undo_EndBlock("Rename selected takes from regions", - 1) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.UpdateArrange()

	reaper.PreventUIRefresh(-1)

end
