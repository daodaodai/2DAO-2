--[[
 * ReaScript Name: -2DAO_SoloPlayTheSelectedItems.lua
 * Description：做成按钮，分配 快捷键 h。选中想试听的 items，点 h，会 solo这些items并播放。
				再次点 h，会停止播放，并 unsolo all。
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
playState_Stopped = 0
playState_Playing = 1
playState_Pause = 2
playState_Recording = 4

--reaper.PreventUIRefresh(1)
--reaper.Undo_BeginBlock()
playState = reaper.GetPlayState()


if playState == playState_Playing then 
	reaper.Main_OnCommand(40044, 0)  -- stop playing
	reaper.Main_OnCommand(41185, 0) -- unsolo all (items)
	reaper.Main_OnCommand(40635, 0)  -- remove time selection
else
	numOfSelectedItems = reaper.CountSelectedMediaItems(0)
	startTime = 36000 -- 10 hours
	endTime = 0

	if numOfSelectedItems > 0 then
		for i = 0, numOfSelectedItems - 1 do
			local item = reaper.GetSelectedMediaItem(0, i)
			
			reaper.Main_OnCommand(41559, 0) 
			
			local track = reaper.GetMediaItem_Track(item)
			reaper.SetTrackSelected(track, true)  -- true to select this track
			
			local tmpPosition = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
			local itemLen = reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')
			local tmpEnd = tmpPosition + itemLen
			if tmpPosition < startTime then
				startTime = tmpPosition
			end
			if tmpEnd > endTime then
				endTime = tmpEnd
			end
		end
		
		nQuery = -1
		clear = 0
		set = 1 
		toggle = 2
		--   -1 == query,0=clear,1=set,>1=toggle
		repeatState_previous = reaper.GetSetRepeat(-1)
		reaper.GetSetRepeat(0)
		
		-- move the edit cursor to the 1st item. Set time selection to all these items
		reaper.SetEditCurPos(startTime, false, false)
		reaper.Main_OnCommand(40290, 0) -- Time selection: Set time selection to items
		reaper.Main_OnCommand(40044, 0) -- Transport: play stop
		
		reaper.GetSetRepeat(repeatState_previous)
		

	else
		showMsg("你连一个item都没选", "哟~~")
	end


end