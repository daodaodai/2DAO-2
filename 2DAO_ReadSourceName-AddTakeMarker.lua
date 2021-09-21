--[[
* ReaScript Name: 2DAO_ReadSourceName-AddTakeMarker
					modified based on : 2DAO_ReadMetadataCOMMENT-DESC_AddTakeMarker.lua
* Version: 1.0
* Author: Daodao
* Date: 2021.09.13
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


---------------------------------------

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

-------------------------------------


------------------ Main body ---------------------

strInput = "" 
retval = false
bStop = false
strComment = ""
strDesc = ""


reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()


numOfSelectedItems = reaper.CountSelectedMediaItems(0)

if numOfSelectedItems > 0 then
	for i = 0, numOfSelectedItems - 1 do
		local strName = ""
		local strMarkerText = ""
		
		local item = reaper.GetSelectedMediaItem(0, i)
		local take = reaper.GetActiveTake(item)
		--if take  then  showMsg("got the take", "-") end
		--local pcmMySource = reaper.GetMediaItemTake_Source( take )
		--local parentSrc = reaper.GetMediaSourceParent(pcmMySource)
		
		--retval, strName = reaper.GetMediaSourceFileName( parentSrc, "" )
		local strTemp = GetTakeName(take)
		
		--showMsg(tostring(strName), "-")
		
		bOK, strName = reaper.GetUserInputs("Marker name", 1, "Marker name ：", strName)
		
		if bOK then
			local curPosition = reaper.GetCursorPosition()
			local itemStartPosition = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
			local markerPosition = 0.1  -- defaul to add marker at 0.1 second			
			if (curPosition > itemStartPosition) then
				-- or add marker at the edit cursor position
				markerPosition = curPosition - itemStartPosition
			end
			reaper.SetTakeMarker( take, -1, strName, markerPosition, yellow )
		end
	end
else
	showMsg("你连一个item都没选", "哟~~")
end


reaper.Undo_EndBlock('Add take marker based on metadata', -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
