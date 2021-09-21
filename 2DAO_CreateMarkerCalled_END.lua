-- Create a marker called END. Color is brown but hey, this script doesn't need to worry about colour.

--[[
	Modified by Daodao.
	Date: 2021.08.04
--]]

--------------------------
-----Available Colors-----
--------------------------
blue = reaper.ColorToNative(0,0,255)|0x1000000
red = reaper.ColorToNative(255,0,0)|0x1000000
green = reaper.ColorToNative(0,255,0)|0x1000000
cyan = reaper.ColorToNative(0,255,255)|0x1000000
magenta = reaper.ColorToNative(255,0,255)|0x1000000
yellow = reaper.ColorToNative(255,255,0)|0x1000000
orange = reaper.ColorToNative(255,125,0)|0x1000000
purple = reaper.ColorToNative(125,0,225)|0x1000000
lightblue = reaper.ColorToNative(13,165,175)|0x1000000
lightgreen = reaper.ColorToNative(125,255,155)|0x1000000
pink = reaper.ColorToNative(225,95,155)|0x1000000
brown = reaper.ColorToNative(125,95,25)|0x1000000
gray = reaper.ColorToNative(125,125,125)|0x1000000
white = reaper.ColorToNative(255,255,255)|0x1000000
Black = reaper.ColorToNative(0,0,0)|0x1000000
--------------------------

name = "END" --<<<<<<--Marker Name
color = brown --<<<<<<--Marker Color. Set a random color cos I have Auto Color on in reaper for marker “NOW"

--------------------------

function msg(m)
	reaper.ShowConsoleMsg(tostring(m) .. '\n')
end

function Insert_Marker_Custom_Name_Color()
	cursor_pos = reaper.GetCursorPosition()
	play_pos = reaper.GetPlayPosition()
	marker_index, num_markersOut, num_regionsOut = reaper.CountProjectMarkers( 0 )
	reaper.AddProjectMarker2( 0, 0, cursor_pos, 0, "END", marker_index+1,color )
end

function Main()
	reaper.Undo_BeginBlock()
	Insert_Marker_Custom_Name_Color()
	reaper.Undo_EndBlock("Insert_Marker_Custom_Name_Color", 0)
end

Main()
reaper.UpdateArrange()