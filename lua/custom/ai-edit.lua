-- ai-edit.lua — Cursor-style inline edit using the local `claude` CLI.
--
--   1. Visual-select a region of code.
--   2. Press <leader>ai
--   3. Type a natural-language instruction at the prompt.
--   4. Claude rewrites the selection in place. Use `u` to undo if you don't
--      like it.
--
-- Uses `claude --print` (one-shot) so it works with any auth the CLI is
-- already set up for — no ANTHROPIC_API_KEY needed.

local M = {}

-- Get the visually-selected lines (or the current line in normal mode),
-- preserving column boundaries on the first/last line.
local function get_selection_text(mode)
  local s = vim.api.nvim_buf_get_mark(0, "<")
  local e = vim.api.nvim_buf_get_mark(0, ">")
  if s[1] == 0 then return nil end -- no selection

  local lines = vim.api.nvim_buf_get_lines(0, s[1] - 1, e[1], false)
  if #lines == 0 then return nil end

  if mode == "v" then
    -- character-wise: trim first/last by column
    if #lines == 1 then
      lines[1] = string.sub(lines[1], s[2] + 1, e[2] + 1)
    else
      lines[1]      = string.sub(lines[1], s[2] + 1)
      lines[#lines] = string.sub(lines[#lines], 1, e[2] + 1)
    end
  end
  -- "V" (linewise) and "<C-v>" (block) — return whole lines
  return {
    text       = table.concat(lines, "\n"),
    start_line = s[1],
    end_line   = e[1],
  }
end

local function build_prompt(instruction, code, filename, ft)
  return string.format([[
You are editing code in a Linux kernel driver.
File: %s
Language/filetype: %s

INSTRUCTION:
%s

ORIGINAL CODE:
```
%s
```

Output ONLY the rewritten code — no markdown fences, no explanation,
no leading or trailing prose. Preserve indentation style of the
original (tabs vs spaces, width). The output replaces the selection
verbatim.
]], filename, ft, instruction, code)
end

-- Strip leading/trailing markdown fences if Claude added them anyway,
-- and strip any leading "Here's the edited code:" / trailing prose.
local function clean_response(s)
  -- Drop a leading ```lang line if present
  s = s:gsub("^```[%w_+%-]*\n", "")
  -- Drop a trailing ``` line
  s = s:gsub("\n```%s*$", "")
  -- Drop a trailing single newline (some CLIs add one)
  s = s:gsub("\n$", "")
  return s
end

function M.edit()
  local mode = vim.fn.visualmode()  -- "v" / "V" / "<C-v>"
  if mode == "" then
    vim.notify("ai-edit: no visual selection — select code first", vim.log.levels.WARN)
    return
  end

  local sel = get_selection_text(mode)
  if not sel then
    vim.notify("ai-edit: empty selection", vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = "AI edit instruction: " }, function(instruction)
    if not instruction or instruction == "" then
      vim.notify("ai-edit: cancelled", vim.log.levels.INFO)
      return
    end

    local filename = vim.fn.expand("%:t")
    local ft       = vim.bo.filetype
    local prompt   = build_prompt(instruction, sel.text, filename, ft)

    vim.notify("ai-edit: asking Claude…", vim.log.levels.INFO)

    -- Async job so the editor doesn't freeze for 5-10s
    local stdout_chunks = {}
    local stderr_chunks = {}
    local jobid = vim.fn.jobstart({ "claude", "--print", "--model", "sonnet" }, {
      stdin = "pipe",
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data then vim.list_extend(stdout_chunks, data) end
      end,
      on_stderr = function(_, data)
        if data then vim.list_extend(stderr_chunks, data) end
      end,
      on_exit = function(_, code)
        if code ~= 0 then
          vim.schedule(function()
            vim.notify("claude exited with code " .. code .. ": " ..
                       table.concat(stderr_chunks, "\n"), vim.log.levels.ERROR)
          end)
          return
        end

        local out = table.concat(stdout_chunks, "\n")
        out = clean_response(out)
        if out == "" then
          vim.schedule(function()
            vim.notify("ai-edit: empty response", vim.log.levels.WARN)
          end)
          return
        end

        vim.schedule(function()
          -- Replace the selection with the new content
          local lines = vim.split(out, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(0, sel.start_line - 1, sel.end_line, false, lines)
          vim.notify("ai-edit: applied. `u` to undo if not happy.", vim.log.levels.INFO)
        end)
      end,
    })

    if jobid <= 0 then
      vim.notify("ai-edit: failed to spawn `claude` — is it on PATH?", vim.log.levels.ERROR)
      return
    end

    -- Send the prompt via stdin and close the channel so claude knows we're done
    vim.fn.chansend(jobid, prompt)
    vim.fn.chanclose(jobid, "stdin")
  end)
end

return M
