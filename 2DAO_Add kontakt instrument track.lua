--[[
 * ReaScript Name: 2DAO_Add kontakt instrument track.lua
 * Description: Glue selected items; rename the new item to $track【$region】；rename the sourse file.
 * Author: 2Dao
--]]




-- insert a new track: Track: Insert new track at end of track list
--reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 40702, 0, 0, 0)
reaper.Main_OnCommand( 40702, 0 )

-- get the last selected track
trackCount = reaper.CountSelectedTracks(0)
last_sel_track = reaper.GetSelectedTrack( 0, trackCount - 1 )

-- add kontakt fx
reaper.TrackFX_AddByName(last_sel_track, "Kontakt (Native Instruments GmbH) (64 out)", false, -1)

cmdIndex = reaper.NamedCommandLookup("_S&M_MIDI_INPUT_ALL_CH")
reaper.Main_OnCommand( cmdIndex, 0 )
--reaper.JS_WindowMessage_Send(me, "WM_COMMAND", cmdIndex, 0, 0, 0)

