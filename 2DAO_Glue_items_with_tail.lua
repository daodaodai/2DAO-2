--[[
 * ReaScript Name: 2DAO_Glue_items_with_tail.lua
 * Description: pop up a window to ask me for a tail to be included in the
 * selection, then glue items from the start to end+tail. It utilises the
 * glue with time selection command.
 * Author: Daodao
 * Date： 2021.07.12
--]]


console = true -- true/false: display debug messages in the console

-----------------------------------------------

-- remove time selection
--cmdIndex = reaper.NamedCommandLookup("Time selection: Remove time selection and loop points")
reaper.Main_OnCommand( 40020, 0 )

-----------------------------------------------

reaper.Undo_BeginBlock()

minusOne = -1
itemsStartPosition = minusOne
itemsEndPosition = minusOne

-- Automatically move all selected items to the track of the 1st item
-- This switch is for testing only.
bAutoMoveItems = true

-----------------------------------------------
-- Get an item's start poisition and end position. Time is in seconds.
function GetItemStartEndPoisitions( item )
	local startPos = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
	local itemLen = reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')
	local endPos = startPos + itemLen
	return startPos, endPos
end


-----------------------------------------------

-- get all the items selected
itemsCount = reaper.CountSelectedMediaItems(0)

if itemsCount == 0 then
	reaper.ShowMessageBox("你一个item都没选。不glue。", "一个窗口", 0)
	return
elseif itemsCount == 1 then  -- 1 item selected
	item = reaper.GetSelectedMediaItem(0,0)
	itemsStartPosition, itemsEndPosition = GetItemStartEndPoisitions(item)
else  -- multiple items selected
	local tmpStartPosition = minusOne
	local tmpEndPosition = minusOne

	local thisProject = 0
	for i = 1, itemsCount do
		item = reaper.GetSelectedMediaItem(thisProject, i-1)
		tmpStartPosition, tmpEndPosition = GetItemStartEndPoisitions(item)
		
		if i == 1 then
			-- this is the 1st item in the selection, set the time selection end points to
			-- this item's end points
			itemsStartPosition = tmpStartPosition
			itemsEndPosition = tmpEndPosition
			trackOfFirstItem = reaper.GetMediaItemInfo_Value(item, 'P_TRACK')
		else
			-- adjust the time selection's end points to the new limit
			if tmpStartPosition < itemsStartPosition then 
				itemsStartPosition = tmpStartPosition
			end
			if tmpEndPosition > itemsEndPosition then
				itemsEndPosition = tmpEndPosition
			end
			-- move items to the track of the 1st item
			if bAutoMoveItems == true then
				local bOK = reaper.MoveMediaItemToTrack(item, trackOfFirstItem)
			end
			--reaper.ShowMessageBox(tostring(i)..(i and ' true' or ' false'), "hello", 0)
		end
	end
	

end

userInput = "0"
tailLen = 0
bOK, userInput = reaper.GetUserInputs("Get tail length for glue", 1, "尾巴长度 tail (sec)", userInput)
if bOK then
	tailLen = tonumber(userInput:match("([^,]+)"))
	itemsEndPosition = itemsEndPosition + tonumber(tailLen)
	-- Select the time
	selectionStart, selectionEnd = reaper.GetSet_LoopTimeRange(true, false, itemsStartPosition, itemsEndPosition, true )
	-- Item: Glue items (auto-increase channel count with take FX)
	reaper.Main_OnCommand(42434 , 0)
	reaper.Main_OnCommand( 40020, 0 ) -- Time selection: Remove (unselect) time selection and loop points
end

reaper.Undo_EndBlock('Glue items with tail', 1)
