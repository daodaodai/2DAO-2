--[[
 * ReaScript Name: 2DAO_CreateRegionCalled_vol区.lua
 * Description: create my region called vol区.
 * Author: 2Dao
 * Date: 2021.08.04
--]]



newRegionName = "缺音区"

function showSimpleMessage(strMsg, strTitle)

	reaper.ShowMessageBox( strMsg, strTitle, 0)

end

function main()

	cursorPosition = reaper.GetCursorPosition() -- this would be the start of the region
	local thisProject = 0  -- 0 is the current project	
	
	reaper.Main_OnCommand( 40174, 0 )  -- Markers: Insert region from time selection
	markerIdx, regionIdx = reaper.GetLastMarkerAndCurRegion(thisProject, cursorPosition)
	--reaper.GoToRegion(thisProject, regionIdx, false)
		
	local ret, bIsRegion, startPos, endPos, name, markrgnindexnumber = reaper.EnumProjectMarkers(regionIdx)
	reaper.SetProjectMarkerByIndex(0, regionIdx, bIsRegion, startPos, endPos, markrgnindexnumber, newRegionName, 0)

end



reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

main()

reaper.Undo_EndBlock("Create named region", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)