-- Select items with specific take FX
-- "Select items with take FX" by EvilDragon modified by Edgemeal
-- Then modified with the help from the big-wigs in a Reaper QQ group.

--[[
	Modified by Daodao.
	Date: 2021.07.14
--]]

------- token to identify the string is for the fx name to be looked up next
myToken = "2dao:"

------- get clipboard text --------
assert(reaper.CF_GetClipboard, "SWS v2.9.5 or newer is required")

clipboardText = reaper.CF_GetClipboard()
clipboardText = string.lower(clipboardText)
-- does it contain the info ie. the fx name for this lookup? or
-- is it not for our purpose ie. the I must have copied something for something else.
GotIt = string.find(clipboardText, myToken)

------- set up the fx name that is to be matched -----
if GotIt then
	-- remove the token and get the real user input, e.g. ReaComp
	find_fx = string.gsub(clipboardText, myToken, "")
else
	-- start from default
	find_fx = "Dragonfly"
end

-- Edgemeal mod #1,



retval, find_fx = reaper.GetUserInputs("Select items that contain:", 1, "FX Name:", find_fx)
if not retval or find_fx == "" then return end
find_fx = find_fx:lower()
-- end Edgemeal mod #1

function GoToItem(item)
	-- move mouse cursor to it.
	local pos=reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
	reaper.SetEditCurPos(pos, false, false)
	-- Let's try selecting the track!!!!
	local item_track = reaper.GetMediaItemInfo_Value(item, 'P_TRACK')
	reaper.SetOnlyTrackSelected(item_track)
	-- Get human readable track number
	-- nTrackNumber = reaper.GetMediaTrackInfo_Value(item_track, 'IP_TRACKNUMBER ')
	nTrackNumber = reaper.CSurf_TrackToID(item_track, false)

	cmdIndex = reaper.NamedCommandLookup("Track: Vertical scroll selected tracks into view")
	--reaper.Main_OnCommand( cmdIndex, 0 )
	reaper.Main_OnCommand( 40913, 0 ) -- Track: Vertical scroll selected tracks into view
	reaper.Main_OnCommand( 40020, 0 ) -- Time selection: Remove (unselect) time selection and loop points

	-- Now arrange view
	--local arr_start, arr_end = reaper.GetSet_ArrangeView2(0, false, 0, 0)
	--local arr_len = arr_end-arr_start
	--local new_arr_start = pos - arr_len /2
	-- local new_arr_end = pos + arr_len /2
	-- Set new view horizontal size i.e. length = 160
	newViewStart = pos - 20
	newViewEnd = pos + 20
	reaper.GetSet_ArrangeView2(0, true, 0, 0, newViewStart, newViewEnd)
	--reaper.GetSet_ArrangeView2(0, true, newViewStart, newViewEnd)
end

function NavigatorAPIAvailable()
	return reaper.ImGui_CreateContext ~= nil
end

function CleanupNavigator()
	if imgui_ctx then
		if reaper.ImGui_DestroyContext then
			reaper.ImGui_DestroyContext(imgui_ctx)
		end
		imgui_ctx = nil
	end
	imgui_font = nil
end

function SelectMatchedItem(match_index)
	current_match = match_index
	if current_match < 1 then current_match = #matched_items end
	if current_match > #matched_items then current_match = 1 end
	if not reaper.ValidatePtr2(0, matched_items[current_match], "MediaItem*") then return end
	GoToItem(matched_items[current_match])
	reaper.UpdateArrange()
end

function NavigatorLoop()
	if not imgui_ctx then return end

	local flags = reaper.ImGui_WindowFlags_AlwaysAutoResize()
	local visible, open = reaper.ImGui_Begin(imgui_ctx, "Matched items", true, flags)

	if visible then
		reaper.ImGui_Text(imgui_ctx, current_match .. " / " .. #matched_items)
		if reaper.ImGui_Button(imgui_ctx, "Previous Item", 130, 28) then
			SelectMatchedItem(current_match - 1)
		end
		reaper.ImGui_SameLine(imgui_ctx)
		if reaper.ImGui_Button(imgui_ctx, "Next Item", 130, 28) then
			SelectMatchedItem(current_match + 1)
		end
		if reaper.ImGui_Button(imgui_ctx, "Cancel", 270, 28) then
			open = false
		end
		reaper.ImGui_End(imgui_ctx)
	end

	if open then
		reaper.defer(NavigatorLoop)
	else
		CleanupNavigator()
	end
end

function StartNavigator()
	if not NavigatorAPIAvailable() then
		reaper.ShowMessageBox("当前 REAPER 环境缺少 ReaImGui 扩展。", "Missing API", 0)
		return
	end

	current_match = 1
	imgui_ctx = reaper.ImGui_CreateContext("2DAOFxNavigator")
	if not imgui_ctx then return end
	imgui_font = reaper.ImGui_CreateFont("sans-serif", 16)
	reaper.ImGui_Attach(imgui_ctx, imgui_font)

	-- 设置窗口初始位置为屏幕中心（只在首次显示时生效）
	local viewport = reaper.ImGui_GetMainViewport(imgui_ctx)
	local cx, cy = reaper.ImGui_Viewport_GetCenter(viewport)
	reaper.ImGui_SetNextWindowPos(imgui_ctx, cx, cy, reaper.ImGui_Cond_Once(), 0.5, 0.5)

	reaper.atexit(CleanupNavigator)
	NavigatorLoop()
end

reaper.Undo_BeginBlock()
reaper.Main_OnCommand(40289, 0)
itemcount = reaper.CountMediaItems(0)
matched_items = {}
start_navigator = false

if itemcount > 0 then -- if itemcount ~= nil then --< Edgemeal tweak
  for i = 1, itemcount do
    item = reaper.GetMediaItem(0, i - 1)
    if item ~= nil then
      item_matched = false
      takecount = reaper.CountTakes(item)
      for j = 1, takecount do
        if item_matched then break end
        take = reaper.GetTake(item, j - 1)
        -- Edgemeal mod #2,
        -- if reaper.BR_GetTakeFXCount(take) ~= 0 then
        -- reaper.SetMediaItemSelected(item, true)
        fx_cnt = reaper.TakeFX_GetCount(take) 
        for k = 0, fx_cnt-1 do
          retval, fx_name = reaper.TakeFX_GetFXName(take, k, "")
          if fx_name:lower():match(find_fx) then
            reaper.SetMediaItemSelected(item, true)
            matched_items[#matched_items + 1] = item
            item_matched = true
            break
          end
        end -- end Edgemeal mod #2
      end -- for
    end
  end -- for
  -- Edgemeal mod #3,
  -- OPTIONAL: Move edit cursor to first selected item
  item = matched_items[1]
  if item then
		GoToItem(item)

		-- We've done the job. Now save the fx name for the next look up
		clipboardText = myToken..find_fx
		reaper.CF_SetClipboard(clipboardText)
		--reaper.ShowMessageBox("Track "..tostring(nTrackNumber), "Track number is:", 0)
		if #matched_items > 1 then start_navigator = true end
	  else
		reaper.ShowMessageBox("没找到。fx must be on the tracks or not being used.", "Search got 0 hit", 0)
		-- No need to look it up again. Clear the clipboard so next time let the script uses the default fx name
	reaper.CF_SetClipboard("")
  end
  -- end Edgemeal mod #3  
end

reaper.UpdateArrange()
reaper.Undo_EndBlock('Select items with specific take FX', 1)

if start_navigator then StartNavigator() end
