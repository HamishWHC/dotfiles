local browser = require("./common.luau")
local saving = false

function onOpen()
  saving = false
  local current = browser.current().id
  local rows = {
    ui.label({ text = "Default browser", fontWeight = "bold" }),
  }
  for _, choice in ipairs(browser.choices) do
    table.insert(rows, ui.button({
      text = choice.label,
      glyph = current == choice.id and "check" or "world",
      variant = current == choice.id and "primary" or "ghost",
      onClick = function()
        if saving then return end
        saving = true
        noctalia.runAsync({ browser.command, "--set", choice.id }, function(result)
          saving = false
          if result.exitCode == 0 then
            noctalia.state.set("choice", choice.id)
            panel.close()
          else
            noctalia.notify("Default browser", "Could not save the browser selection.")
          end
        end)
      end,
    }))
  end
  panel.render(ui.column({ gap = 8, padding = 8, align = "stretch" }, rows))
end
