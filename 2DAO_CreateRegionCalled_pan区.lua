--[[
 * ReaScript Name: 2DAO_CreateRegionCalled_pan区.lua
 * Description: create my region called pan区.
 * Author: 2Dao
 * Date: 2021.08.04
--]]



newRegionName = "pan区"

function showSimpleMessage(strMsg, strTitle)

	reaper.ShowMessageBox( strMsg, strTitle, 0)

end

function main()

	reaper.Main_OnCommand( 40174, 0 )  -- Markers: Insert region from time selection
	
	cursorPosition = reaper.GetCursorPosition() -- this would be the start of the region
	local thisProject = 0  -- 0 is the current project
	markerIdx, regionIdx = reaper.GetLastMarkerAndCurRegion(thisProject, cursorPosition)
	
	local ret, bIsRegion, startPos, endPos, name, markrgnindexnumber = reaper.EnumProjectMarkers(regionIdx)
	reaper.SetProjectMarkerByIndex(0, regionIdx, bIsRegion, startPos, endPos, markrgnindexnumber, newRegionName, 0)

end



reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

main()

reaper.Undo_EndBlock("Create named region", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)