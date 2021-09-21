--[[
 * ReaScript Name: 2DAO_SetRandomTakePan_toItems.lua
 * Version: 1.0
* Author: Daodao
* Date: 2021.08.08
--]]



---------------------------------------------

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

-------------------------------------

function  getRandomPanValue( scalePercent)
	local panVal = 0  -- set pan to be at the centre first
	local tempRandomVal = 0
	
	if ( scalePercent > 0) then  -- User wants to pan it	
		-- 用 random(l,m) 因为它的范围是 l <= x <= m。其他没有保证包括边界点。
		math.random (-100, 100) 
		tempRandomVal = math.random (-100, 100) 
		--tempRandomVal = tempRandomVal * math.random (-10, 10) 
		panVal = (scalePercent/100) * (tempRandomVal / 100)
		--showMsg(tostring(panVal), "randome val")
	end
	
	return panVal
end


function sleep(n)
	local t0 = os.clock()
	while os.clock() - t0 <= n do end
end

------------------ Main body ---------------------

strInput = "" 
retval = false
bContinue = true
panScalePercent = 10

numOfSelectedItems = reaper.CountSelectedMediaItems(0)

if numOfSelectedItems > 0 then
	retval, strInput  = reaper.GetUserInputs('Set Take Pan Range', 1, 'Pan范围， 0 ~ 100 之间:', '')
	
	if  (retval and  (strInput ~= "")) then	
		panScalePercent =  (tonumber(strInput))
		
		if  (panScalePercent < 0  or panScalePercent >100) then
			showMsg("数值不在 0~100之间", "Error in input")
			bContinue = false
		end
		
	else
		bContinue = false
	end
	
else
	showMsg("你连一个item都没选", "哟~~")
	bContinue = false
end


-- return point ------------
if (not bContinue) then
	return
end
--- return point end -----


reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

math.randomseed(tostring(math.sin(os.time())):sub(4, 12))
--math.randomseed(tonumber(tmpVal))
math.random()
--require("socket")
--math.randomseed(tostring(socket.gettime()):reverse():sub(1, 6))

--sleep(1)

if  (retval and  (strInput ~= "")) then
	for i = 0, numOfSelectedItems - 1 do
		-- Show take pan envelope
		cmdIndex = reaper.NamedCommandLookup("_S&M_TAKEENVSHOW2")
		reaper.Main_OnCommand(cmdIndex, 0) -- SWS/S&M: Show take pan envelope

		local item = reaper.GetSelectedMediaItem(0, i)
		local take = reaper.GetActiveTake(item)
		local panVal = getRandomPanValue(panScalePercent)
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