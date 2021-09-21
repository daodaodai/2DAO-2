me=reaper.JS_Window_Find("Media Explorer", true)
if not me then return end
-- scan for new db first, then remove all  missing files
reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 42085, 0, 0, 0)
reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 42087, 0, 0, 0)