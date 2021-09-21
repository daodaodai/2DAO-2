--[[
 * ReaScript Name: 2DAO_CopySelectedEnvelopeToTrack.lua
 * Description: 有时候重启reaper，轨道上的包络线会玄学出现在另外的轨道！想法子快速挪回来用。
				先 copy 回来。之后手动删除错误的 env。
				
				一般我用最多的是 track pan. 这里针对各种 env。
				
				运行前，需要先手动选个 time selection; 然后点选 目标轨道；然后点选 源 envelope。运行。
 * Version: 1.0
* Author: Daodao
* Date: 2021.09.19
--]]


---------------------------------------------

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

function showMsg2( strContent )
	reaper.ShowMessageBox(strContent, "-", 0)
end

-------------------------------------


function main()

	countSelected = reaper.CountSelectedTracks(0)
	if countSelected == 0 then
		showMsg("No track selected for copy from", "哎呦")
	elseif countSelected > 1 then
		showMsg("Selected more than 1 track to copy from。 得罢工.", "哎呦")
	else
		envSelected = reaper.GetSelectedEnvelope(0)
		retval, selectedEnvName = reaper.GetEnvelopeName(envSelected)
		
		if (not envSelected) then
			showMsg("没选中 source envelope。 得罢工.", "哎呦")
		else
			-- 先把光标挪到开头
			reaper.SetEditCurPos(0, false, false)
			
			selectedTrack = reaper.GetSelectedTrack( 0, 0 )
			envTargetTrack = reaper.GetTrackEnvelopeByName(selectedTrack, selectedEnvName)
			if not envTargetTrack then 
				showMsg2("没选目标 track 吧")
			end
			
			-- trackNumber = reaper.GetMediaTrackInfo_Value(selectedTrack, 'IP_TRACKNUMBER')
			--reaper.Main_OnCommand( 40407, 0 ) -- Track: Toggle track pan envelope visible			
			--panEnv = reaper.GetTrackEnvelopeByName(selectedTrack, selectedEnvName)
			--if (not panEnv) then
				-- We probably have turned pan env off
				--reaper.Main_OnCommand( 40407, 0 ) -- Track: Toggle track pan envelope visible
			--end
			
			-- 上面的操作会 unselect everything. Now relect the env and the target track			
			reaper.SetTrackSelected(selectedTrack, true)
			reaper.SetCursorContext(2, envSelected) -- 2=focus arrange and select env.
			
			cmd = reaper.NamedCommandLookup( "_BR_COPY_ENV_TS_SEL_TR_ENVS_VIS" )
			reaper.Main_OnCommand(cmd, 0)
		end
	end

end



reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

main()

reaper.Undo_EndBlock("Copy envelope points to tracks", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)
