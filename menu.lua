
--[[
USAGE 
  Open/Close Menu - [F12]
  Disable running script - [F11]
--]]

g_Menu = nil

class 'CMenu'
function CMenu:__init(app)
  self.app = app
  self.game = app.Game
  self.dx = app.DirectX
  self.fontObjectList  = self.dx:CreateFont(15, 7, 600, false, "Arial")  
  self.mouse = Vector2(0,0)
  self.enabled = false
  self.currentMenuIndex = 1;
  self.previousMenuIndex = 1;
end

function CMenu:UpdateCurrentMenuSelection(direction)
  if not self.enabled then 
    return
  end

  if direction == 1 then -- 1 = Up, 2 = Down
    self.currentMenuIndex = ((self.currentMenuIndex - 1) % (#g_Scripts + 1))
    if self.currentMenuIndex == 0 then
      self.currentMenuIndex = #g_Scripts
    end
  else 
    self.currentMenuIndex = ((self.currentMenuIndex + 1) % (#g_Scripts + 1))
    if self.currentMenuIndex == 0 then
      self.currentMenuIndex = 1 
    end
  end
end

function CMenu:DrawMenu()  
  if not self.enabled then
    return
  end
  local x = 600 -- Menu X pos
  local y = 30 -- Menu X pos

  -- Drawing menu background
  local maxMenuBGHeight = (#g_Scripts + 3)* 16 -- Max height is proportional to scripts count
  local maxMenuBGWidth = 200 -- Max width is hardcoded for now
  self.dx:FillRGB(x-10,y-10,maxMenuBGWidth,maxMenuBGHeight,0xC3);

  -- Drawing menu options
  self.fontObjectList:Draw(x,y,0,0, clRed, string.format("F12 - Save and Exit %d", #g_Scripts))
  for i = 1, #g_Scripts do
    local scriptName;
    y = y + 17

    if g_Scripts[i] == nil then -- See g_Scripts inside script-list.lua
      scriptName = "None"
    else 
      scriptName = g_Scripts[i]:GetScriptName()
    end
    
    -- Green text on current menu index, otherwise red text. Not very DRY but will do since no ternary
    if self.currentMenuIndex == i then
      self.fontObjectList:Draw(x,y+10,0,0, clGreen, string.format("[x] %s", scriptName))
    else
      self.fontObjectList:Draw(x,y+10,0,0, clRed, string.format("[  ] %s", scriptName))     
    end
  end
end

function CMenu:OnUpdate()
  self:DrawMenu() 
  self:ScriptManager()
end


function CMenu:DisableAllScripts()
  for i = 2, #g_Scripts do -- starting at 2 because 
    if g_Scripts[i] ~= nil then
      g_Scripts[i]:Disable()
    end
  end
  self.previousMenuIndex = self.currentMenuIndex
end

function CMenu:ScriptManager()
  if not self.enabled then -- apply script only when menu is closed   
    if self.currentMenuIndex == 1 then    
      self:DisableAllScripts()      
      return
    end
    if self.previousMenuIndex ~= self.currentMenuIndex then
      self:DisableAllScripts() 
      g_Scripts[self.currentMenuIndex]:Enable()
    end
    
  end
end

function CMenu:WindowProc(msg)
  if msg.message == WM_KEYUP then
    if msg.wParam == VK_F12 then -- Activate menu
      self.enabled = not self.enabled
    end
    if msg.wParam == VK_F11 then
      self:DisableAllScripts() -- Turn off current running script
    end
    if msg.wParam == VK_DOWN then -- Navigate down the menu
      self:UpdateCurrentMenuSelection(2)  
    end
    if msg.wParam == VK_UP then -- Navigate up the menu
      self:UpdateCurrentMenuSelection(1)  
    end    
  elseif msg.message == WM_MOUSEMOVE then
    self.mouse.x = LOWORD(msg.lParam)
    self.mouse.y = HIWORD(msg.lParam)  
 end	
end

--------------- // -------------

function Menu_OnUpdate()
  g_Menu:OnUpdate()
  
end

function Menu_WindowProc(msg)
  g_Menu:WindowProc(msg)
end

function Initialize()
  g_App:AllocConsole()
  g_Menu = CMenu(g_App)  
  g_App:RegisterEventListener(EVENT_FRAMERENDER_UPDATE, Menu_OnUpdate)
  g_App:RegisterEventListener(EVENT_WINDOWPROC, Menu_WindowProc)
end

Initialize()
