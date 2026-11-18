local browser = require("./common.luau")
local lastChoice = nil

function update()
  local choice = browser.current()
  if choice.id == lastChoice then return end
  lastChoice = choice.id
  barWidget.setImage(choice.icon, false, 20, 20)
  barWidget.setText(choice.private and "Private" or "")
  barWidget.setTooltip("Default browser: " .. choice.label .. "\nClick to change")
end

function onClick()
  noctalia.togglePanel("dotfiles/browser-selector:picker")
end

noctalia.setUpdateInterval(1000)
noctalia.state.watch("choice", function() update() end)
update()
