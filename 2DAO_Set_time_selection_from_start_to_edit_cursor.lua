--[[
 * ReaScript Name: 2DAO_Set_time_selection_from_start_to_edit_cursor.lua
 * Description: 
 * Author: Daodao
--]]

-- clear time selection
cmdIndex = reaper.NamedCommandLookup("Time selection: Remove time selection and loop points")
reaper.Main_OnCommand( cmdIndex, 0 )

-- get end point
nCursorPosition = reaper.GetCursorPosition()
nStartPosition = 0

-- now do the time selection, from start to edit cursor position
startPoint, endPoint = reaper.GetSet_LoopTimeRange(true, false, nStartPosition, nCursorPosition, true )
