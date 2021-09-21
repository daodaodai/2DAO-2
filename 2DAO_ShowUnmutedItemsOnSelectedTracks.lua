-- Show all unmuted take  name in the selected tracks

--[[Description: 选中目标轨道（可多个），run 本脚本，理论上它会显示：那些 unmuted 素材的源文件名
					本意是方便我看看音乐轨道上都用了什么配乐。
	Modified by Daodao.
	Date: 2021.09.06
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




local bDisplayMsg = checkIfToShowTooltip()

local toolTip = " 本脚本，显示选中轨道上所有没有静音的 items 的文件名。\n所以你要先选中轨道哦~"	

if bDisplayMsg == true then

	showMsg(toolTip, "tool tip")
	local today = os.date("%d")
	
	-- We've just shown the tooltip. Now save the day it's displayed
	reaper.SetExtState(sectionName, section_dayOfMonth, tostring(today), true)
end

	
reaper.Main_OnCommand( 40421, 0 )  -- command: Item: Select all items in track

tblAllUnmutedItems = {}
entryCount = 0
outputStr1 = ""
outputStr2 = ""
previousItemName = ""
j = 0


numOfSelectedItems = reaper.CountSelectedMediaItems( thisProject ) -- 0: this project
--showMsg(tostring(numOfSelectedItems), 'number of selected items')

for i = 0, numOfSelectedItems - 1 do
	local item = reaper.GetSelectedMediaItem( thisProject, i)
	local isMute = reaper.GetMediaItemInfo_Value( item, "B_MUTE" )
	if (isMute == bUnmute) then
		local take = reaper.GetActiveTake(item)
		if take and not reaper.TakeIsMIDI( take ) then
			local takeName = reaper.GetTakeName( take )
			
			if (takeName ~= previousItemName) then
				outputStr1 = outputStr1..takeName.."\n"
				previousItemName = takeName
				tblAllUnmutedItems[j] = " ** "..takeName
				--showMsg(tblAllUnmutedItems[j], "新增take name")
				j = j + 1
			end	
		end
	end
end

--for k = 0, j do
--	showMsg(tblAllUnmutedItems[k], "talbe  take name")
--end

--showMsg(outputStr1, "所有没静音的文件 in the selected tracks")

table.sort( tblAllUnmutedItems )
entryCount = #tblAllUnmutedItems  -- # actually returns the max index, NOT the the length!


previousItemName = ""
bFound = true

for i = 0, entryCount do
	local strTemp = tblAllUnmutedItems[i]
	
	if strTemp == nil and i == 0 then
		showMsg2("轨道上没有 没静音 的文件. No unmuted files found on tracks selected.")
		bFound = false
	else
		if (strTemp ~= previousItemName) then
			outputStr2 = outputStr2..strTemp.."\n"
			previousItemName = strTemp
		end
	end
end

if bFound and outputStr2 then
	outputStr2 = "所有没静音的文件 in the selected tracks:\n".."---------------------------------------\n\n"..outputStr2
	reaper.ShowConsoleMsg(outputStr2)
end
