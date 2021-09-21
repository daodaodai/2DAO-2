--[[
 * ReaScript Name: SetTakePan
 * Version: 1.0
* Author: Daodao
* Date: 2021.08.05
--]]


---------------------------------------

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

strInput = "" 
retval = false


numOfSelectedItems = reaper.CountSelectedMediaItems(0)

if numOfSelectedItems > 0 then
	retval, strInput  = reaper.GetUserInputs('Set Take Pan (percentage)', 1, 'New pan % ( left  > 0, right < 0 ) e.g.  -20:', '')
else
	showMsg("你连一个item都没选", "哟~~")
	return
end


panValPercent = (tonumber(strInput))


if  (retval and  (strInput ~= "")) then
	for i = 0, numOfSelectedItems - 1 do
		-- Show take pan envelope
		cmdIndex = reaper.NamedCommandLookup("_S&M_TAKEENVSHOW2")
		reaper.Main_OnCommand(cmdIndex, 0) -- SWS/S&M: Show take pan envelope

		local item = reaper.GetSelectedMediaItem(0, i)
		local take = reaper.GetActiveTake(item)
		local panVal = panValPercent/100
		--reaper.SetMediaItemTakeInfo_Value(take, 'D_PAN', panVal)
		--reaper.UpdateItemInProject(item)
		
		thisEnvelope = reaper.GetTakeEnvelopeByName(take, "Pan")
		
		if (thisEnvelope) then
			 myBR_env = reaper.BR_EnvAlloc(thisEnvelope, false )  -- false: env points' positions do not use project timeline/ruler but the item's own timeline.
			 
			 pointIndex =  reaper.BR_EnvFindNext(myBR_env , -0.1 ) -- give it position < 0s ie searching starts from -0.1s. cant use 0 cos it will miss the 1st point if it sits right on 0s.
			 while (pointIndex > -1) do  -- we found one
				-- delete the point
				bRes = reaper.BR_EnvDeletePoint( myBR_env, pointIndex )
				
				-- Find the next point. Now we can start from position 0 second. Actually, because we have been deleting points from the start
				-- the next func call will always return an index of 0 because the next point would have become the first point on the envelope.
				 pointIndex = reaper.BR_EnvFindNext(myBR_env, 0 )
			 end
			 
			 -- Then, create a point at the front, i.e. zero position with my given pan value
			 thisID = -1 --   -1 is to create a point
			 thisPos = 0 -- at 0 sec. Note this is relative to the item's own timeline, not the timeline of the project
			 thisShape = 0 -- the point is of linear shape
			 isSelected = false
			 thisBezier = 0  -- not sure what number to use, give it a random number
			 bRes = reaper.BR_EnvSetPoint(myBR_env, thisID,  thisPos, panVal, thisShape, isSelected, thisBezier)
			 if (bRes == false) then
				showMsg("没成功", "failed")
			 end
			 
			-- IMPORTANT!! do not delete the following line.
			  bRes = reaper.BR_EnvFree(myBR_env, true ) -- true: commit the changes
		end
		
		-- For Gods sake there's next to zero explanation in the API doc!!!
		-- Must use "" as the 2nd parameter in the GetSetItemState func!!
		--retval, strTemp = reaper. GetSetItemState(item,  "")
		--reaper.ShowMessageBox(strTemp, "---", 0)
		end
		
	else
		showMsg("你没给 pan value. 再来一次吧~", "嘿~")
end


reaper.Undo_EndBlock('Set Take Pan', -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()