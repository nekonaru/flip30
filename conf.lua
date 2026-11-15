-- Flip30: LÖVE 11.x configuration
-- See README.md for development and release notes.

function love.conf(t)
  t.identity = "flip30" -- save directory (highscore lives here)
  t.version = "11.5"
  t.console = false
  t.accelerometerjoystick = false

  t.window.title = "Flip30"
  t.window.icon = "assets/brand/icon-512.png"
  t.window.width = 800
  t.window.height = 600
  t.window.resizable = true
  t.window.minwidth = 480
  t.window.minheight = 360
  t.window.vsync = 1
  t.window.highdpi = false
  t.window.msaa = 2
end
