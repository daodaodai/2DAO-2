--[[
 * ReaScript Name: 2DAO_Move-NOW-markerToCursor.lua
 * Version: 1.0
* Author: Daodao
* Date: 2021.08.16
--]]


---------------------------------------

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

-------------------------------------

------------------ Main body ---------------------

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()


retVal, numOfMarkers, numOfRegions = reaper.CountProjectMarkers( 0 )  -- 0 : current project

if retVal then

	for i = 0, (numOfMarkers + numOfRegions - 1)  do
		retVal, isRegion, position, rgnend, name,  markrgnIndex = reaper.EnumProjectMarkers( i )
		
		if name == "NOW" then		
			--reaper.Main_OnCommand( 40513, 0 )   -- View: Move edit cursor to mouse cursor
			cursorPosition = reaper.GetCursorPosition()
			reaper.SetProjectMarker( markrgnIndex, false, cursorPosition, rgnend, name)
		end
	end

end

reaper.Undo_EndBlock('Move NOW marker', -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()