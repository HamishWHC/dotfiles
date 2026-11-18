local M = {}
M.command = "@browserCommand@"
M.choices = {
  { id = "firefox", label = "Firefox", icon = "@firefoxIcon@" },
  { id = "firefox-private", label = "Firefox Private", icon = "@firefoxIcon@", private = true },
  { id = "chromium", label = "Chromium", icon = "@chromiumIcon@" },
  { id = "chromium-private", label = "Chromium Incognito", icon = "@chromiumIcon@", private = true },
}

function M.current()
  local root = noctalia.getenv("XDG_STATE_HOME")
  if root == nil or root == "" then
    root = noctalia.getenv("HOME") .. "/.local/state"
  end
  local raw = noctalia.readFile(root .. "/default-browser/choice")
  local id = raw and string.match(raw, "^%s*(%S+)") or "firefox"
  for _, choice in ipairs(M.choices) do
    if choice.id == id then return choice end
  end
  return M.choices[1]
end

return M
