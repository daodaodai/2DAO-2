all_items = reaper.CountSelectedMediaItems(0)

  for i = 0, all_items-1 do
  
    item =  reaper.GetSelectedMediaItem(0,i)
    
    
    MediaItem_Take = reaper.GetTake(item, 0)
  
    --reaper.TakeFX_AddByName(MediaItem_Take, "ReaEQ", 1)
	retVal = reaper.TakeFX_AddByName(MediaItem_Take, "Voice_effects/人声--降噪预处理__ReaFir切低+De-noise+De-click.RfxChain", 1)
	if retVal == nil then
		reaper.ShowMessageBox("FX not found", "Error", 0)
	end
  
  end

reaper.Main_OnCommand(40638,0)