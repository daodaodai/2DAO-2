--[[
 * ReaScript Name: 2DAO_Set_time_selection_from_edit_cursor_to_end_of_project
 * Description: select time from the edit cursor to the end of the project
 * Author: Daodao
--]]

-- clear time selection, and get view range
cmdIndex = reaper.NamedCommandLookup("Time selection: Remove time selection and loop points")
reaper.Main_OnCommand( cmdIndex, 0 )

viewStart, viewEnd = reaper.GetSet_ArrangeView2(0, false, 0, 0)

-- get the start point
nCursorPosition = reaper.GetCursorPosition()

-- Move cursor to project-end, get position
reaper.Main_OnCommand( 40043, 0 ) -- 40043 == Transport: Go to end of project
nEndPosition = reaper.GetCursorPosition()

-- restore edit cursor position
reaper.SetEditCurPos(nCursorPosition, false, false)

-- now do the time selection, from start to edit cursor position
startPoint, endPoint = reaper.GetSet_LoopTimeRange(true, false, nCursorPosition, nEndPosition, true )

-- restore view
reaper.GetSet_ArrangeView2(0, true, 0, 0, viewStart, viewEnd)
