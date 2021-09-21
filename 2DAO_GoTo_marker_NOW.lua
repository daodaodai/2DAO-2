--[[
 * ReaScript Name: 2DAO_SoloPlayTheSelectedItems.lua
 * Description：做成按钮，w。点 w，edit cursor jumps to 我的 NOW marker。
 * Version: 1.0
* Author: Daodao
* Date: 2021.09.16
--]]


---------------------------------------

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

-------------------------------------


------------------ Main body ---------------------

retval, numOfMarkers, numOfRegions = reaper.CountProjectMarkers(0)
bIsRegion = false
position = 0
regionEndPos = 0
strName = ""
index = 0
strNOW = "NOW"

for i = 0, numOfMarkers - 1 do

	retval, bIsRegion, position, regionEndPos, strName, index = reaper.EnumProjectMarkers(i)
	if (not bIsRegion) then
	
		if (strName == strNOW) then
		-- Lua: reaper.GoToMarker(ReaProject proj, integer marker_index, boolean use_timeline_order)
		reaper.GoToMarker(0, index, false)
		end
		
	end
	
end

