--[[
 * ReaScript Name: 2DAO_Rename_take_to_trackname_n_region.lua
 * Description: Glue selected items; rename the new item to $track【$region】；rename the sourse file.
 * Author: 2Dao
--]]



-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

all_items = reaper.CountSelectedMediaItems(0)

  for i = 0, all_items-1 do
  
    item =  reaper.GetSelectedMediaItem(0,i)
    
    
    my_take = reaper.GetTake(item, 0)
  
    retval = reaper.TakeFX_AddByName(my_take, "Dragonfly Room Reverb (Michael Willis)", 1)
	
	reaper.TakeFX_GetEnvelope(my_take, 0, 1, true) -- early level
	reaper.TakeFX_GetEnvelope(my_take, 0, 3, true) -- late level
	reaper.TakeFX_GetEnvelope(my_take, 0, 7, true) -- decay
  
  end

reaper.Main_OnCommand(40638,0)