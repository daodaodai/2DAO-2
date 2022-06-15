-- Show all unmuted take  name in the selected tracks

--[[Description: 选中目标轨道（可多个），run 本脚本，理论上它会显示：那些 unmuted 素材的源文件名
					本意是方便我看看音乐轨道上都用了什么配乐。
	Modified by Daodao.
	Date: 2021.09.06
	Modified. date. 2021.09.28 增加 sorting 功能，增加判断，如果两个比邻的片段是一个文件，那它算一个音乐文件拼接成新的，就显示一次。
				如果同一个音乐文件在不同的位置出现，那算被多次使用，最后也参与显示
--]]


---------------------------------------
thisProject = 0
bMute = 1
bUnmute = 0
sectionName = "showUnmutedFilesInTracks"
section_dayOfMonth = "dayOfMonth"
---------------------------------------

---------------------------------------

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

function showMsg2( strContent )
	reaper.ShowMessageBox(strContent, "--", 0)
end

function DecimalsToMinutes(dec)
	local ms = tonumber(dec)
	return math.floor(ms / 60)..":"..(ms % 60)
end



---------------------------------------
-- If the day the tooltip was displayed was earlier than totday
-- return true so that the script will show the tooltip again.
function checkIfToShowTooltip ()
	
	local dayOfMonth = os.date("%d")
	
	local dayOfMonth_Saved = reaper.GetExtState(sectionName, section_dayOfMonth)
	local bDisplayMsg = true
	if (dayOfMonth_Saved == dayOfMonth) then
		bDisplayMsg = false
	end
	--showMsg(tostring(dayOfMonth_Saved).."  "..tostring(dayOfMonth), "-")
	return bDisplayMsg
end

---------------------------------------
-- get the times of the time selection end points
function getTimesOfTimeSelection ()
	local start = 0
	local endtime = 0
	start, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, start, endtime, false)
	return start, endtime
end



local bDisplayMsg = checkIfToShowTooltip()

local toolTip = " 本脚本，显示选中轨道上所有没有静音的 items 的文件名。\n所以你要先选中轨道哦~"	

if bDisplayMsg == true then

	showMsg(toolTip, "tool tip")
	local today = os.date("%d")
	
	-- We've just shown the tooltip. Now save the day it's displayed
	reaper.SetExtState(sectionName, section_dayOfMonth, tostring(today), true)
end

----------------------------------------------
startTime_timeSelected = 0
endTime_timeSelected = 0
bTimeSelected = true
startTime_timeSelected, endTime_timeSelected = getTimesOfTimeSelection()
if (startTime_timeSelected == 0 and endTime_timeSelected == 0) then
	bTimeSelected = false
end
----------------------------------------------

reaper.Main_OnCommand( 40421, 0 )  -- command: Item: Select all items in track

tblAllUnmutedItems = {}
tblAllUnmuted_Times = {}
tblAllUnmuted_TimesRaw = {}
tblAllUnmuted_EndTimes = {}
tblAll_TimeAndNames = {}
entryCount = 0
outputStr1 = ""
strProjName = reaper.GetProjectName(thisProject)
outputStr2 = "        "..strProjName.."\n---------------------------------------\n没静音的文件 in the selected tracks:\n---------------------------------------\n\n"
previousItemName = ""
j = 0


numOfSelectedItems = reaper.CountSelectedMediaItems( thisProject ) -- 0: this project
--showMsg(tostring(numOfSelectedItems), 'number of selected items')

for i = 0, numOfSelectedItems - 1 do
	local item = reaper.GetSelectedMediaItem( thisProject, i)
	local isMute = reaper.GetMediaItemInfo_Value( item, "B_MUTE" )
	local startPos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )	
	--local startPosReadable = DecimalsToMinutes(startPos)
	local timeLen = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
	local endPos = startPos + timeLen
	local bRecordThisItem = false
	
	-- if the item is totally outside the time selection, ignore it
	-- no time selected? go ahead record it
	if ( (bTimeSelected == false) or (bTimeSelected and endPos >= startTime_timeSelected and startPos <= endTime_timeSelected) ) then
		if (isMute == bUnmute) then
			local take = reaper.GetActiveTake(item)
			if take and not reaper.TakeIsMIDI( take ) then
				local takeName = reaper.GetTakeName( take )
				
				--if (takeName ~= previousItemName) then
					--outputStr1 = startPos.."  "..outputStr1..takeName.."\n"
					-- 记录：新片段的时间点、名字、终止时间
					tblAllUnmuted_Times[j] = startPos
					--tblAllUnmuted_TimesRaw[j] = startPos
					previousItemName = takeName
					tblAllUnmutedItems[j] = takeName
					--showMsg(tblAllUnmutedItems[j], "新增take name")
					tblAll_TimeAndNames[startPos] = takeName
					tblAllUnmuted_EndTimes[startPos] = endPos
					j = j + 1
				--end	
			end
		end
	end
end

outputStr_3 = "\n\n--------------详情，按轨道顺序列举所有片段---------------\n\n"
for k = 0, j - 1 do
	outputStr_3 = outputStr_3.."\n"..DecimalsToMinutes(tblAllUnmuted_Times[k]).."   "..tblAllUnmutedItems[k]
end


table.sort( tblAllUnmutedItems )
entryCount = #tblAllUnmutedItems  -- # actually returns the max index, NOT the the length!


previousItemName = ""
bFound = true

for i = 0, entryCount do
	local strTemp = tblAllUnmutedItems[i]
	
	if strTemp == nil and i == 0 then
		bFound = false
	else
		if (strTemp ~= previousItemName) then
			-- outputStr2 存的是 unique file names，重复的不存入
			outputStr2 = outputStr2.." ** "..strTemp.."\n"
			previousItemName = strTemp
		end
	end
end

--if bFound and outputStr2 then
	--outputStr2 = "所有没静音的文件 in the selected tracks:\n".."---------------------------------------\n\n"..outputStr2
	--reaper.ShowConsoleMsg(outputStr2)
--	reaper.ShowConsoleMsg(outputStr2..outputStr_3)
--end

-- 按时间顺序给音乐文件列表
table.sort(tblAllUnmuted_Times)
entryCount = #tblAllUnmuted_Times
outputStr_4 = "\n---------------------------------------\n轨道上没有没静音的文件，time sorted.\n---------------------------------------\n\n"
strName = ""
strTime = ""
strPreviousItem_endTime = "0"
strPreviousItem_name = ""


if bFound then
	for i = 0, entryCount do
		strTime = tblAllUnmuted_Times[i]
		strName = tblAll_TimeAndNames[strTime]
		strEndTime = tblAllUnmuted_EndTimes[strTime]
		if (strName == strPreviousItem_name) then
			-- 可能是同一条音乐剪切拼接
			if (strTime > strPreviousItem_endTime) then
				-- 如果这个item的起始时间，> 前面一个 item的 end time，这可能是音乐被多次使用而不是被拼接成一个。这个情况，显示它
				outputStr_4 = outputStr_4..DecimalsToMinutes(strTime).."  "..strName.."\n"	
			end
		else
			outputStr_4 = outputStr_4..DecimalsToMinutes(strTime).."  "..strName.."\n"	
		end
		
		-- 已经决定了是否要显示这个 item了。现在把它的信息存起来，为下一个比较做准备
		strPreviousItem_endTime = strEndTime
		strPreviousItem_name = strName
	end	
	
	reaper.ShowConsoleMsg(outputStr2..outputStr_4..outputStr_3)
else
	showMsg2("轨道上没有 没静音 的文件. No unmuted files found on tracks selected.")
end

