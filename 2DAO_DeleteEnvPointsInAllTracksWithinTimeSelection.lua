--[[
 * ReaScript Name: 2DAO_DeleteEnvPointsInAllTracksWithinTimeSelection.lua
 * Description: 把选区内，所有 envelope 上的节点都删除。
 * Author: 2Dao
 * Date: 2021.09.12
--]]



-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console



------------------------------------------------------- END OF USER CONFIG AREA

function showMsg( strContent, strTitle )
	reaper.ShowMessageBox(strContent, strTitle, 0)
end

---------------------------------------


---------------------------------------


function main()

	local trackCount = reaper.CountTracks(0)
	local enveCount = 0
	local timeStart = 0
	local timeEnd = 0

	for i = 0, trackCount - 1 do
		track = reaper.GetTrack(0, i)
		
		assert(track, "failed to get track "..tostring(i))
		
		enveCount = reaper.CountTrackEnvelopes(track)
		
		for j = 0, enveCount - 1 do
			local envelope = reaper.GetTrackEnvelope(track, j)
			
			reaper.DeleteEnvelopePointRange(envelope, timeStart, timeEnd)
			timeStart, timeEnd = reaper.GetSet_LoopTimeRange(false, false, timeStart, timeEnd, false)
			local bRes = reaper.DeleteEnvelopePointRange(envelope, timeStart, timeEnd)
		end
	end
end

-- INIT


reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

main()

reaper.Undo_EndBlock("Delete all env points in time selection", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)
