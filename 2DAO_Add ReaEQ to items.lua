all_items = reaper.CountSelectedMediaItems(0)

  for i = 0, all_items-1 do
  
    item =  reaper.GetSelectedMediaItem(0,i)
    
    
    MediaItem_Take = reaper.GetTake(item, 0)
  
    reaper.TakeFX_AddByName(MediaItem_Take, "ReaEQ", 1)
  
  end

reaper.Main_OnCommand(40638,0)