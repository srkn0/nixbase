-- Root access from within the running (user) nvim session. nvim stays sk;
-- NO plugins/autocommands run as root.
--
-- The trap: running an *interactive* `sudo` from nvim's system() lets sudo grab
-- the terminal for its password prompt while nvim is in raw mode — after you
-- type the password the UI is corrupted and nvim looks like it "closed".
--
-- Fix: authenticate ONCE inside nvim (inputsecret -> `sudo -S -v`), then every
-- sudo call is non-interactive (`sudo -n`) and never touches the terminal.
-- Needs `!tty_tickets` in sudoers so the timestamp is shared across nvim's
-- separate sudo subprocesses (set in modules/system/base.nix).
--   * vim-suda   reads/writes protected files on demand (suda_smart_edit)
--   * SudoBrowse lists 0700 dirs (sudo find) and opens the pick

-- Ensure a valid sudo timestamp; prompt once (hidden) if needed. Returns true
-- when sudo is usable non-interactively afterwards.
local function ensure_sudo()
  vim.fn.system({ "sudo", "-n", "true" })
  if vim.v.shell_error == 0 then
    return true
  end
  local pw = vim.fn.inputsecret("[sudo] password for root access: ")
  if pw == "" then
    return false
  end
  vim.fn.system({ "sudo", "-S", "-v" }, pw .. "\n")
  if vim.v.shell_error ~= 0 then
    vim.notify("sudo: authentication failed", vim.log.levels.ERROR, { title = "sudo" })
    return false
  end
  vim.notify("sudo: unlocked for ~30 min", vim.log.levels.INFO, { title = "sudo" })
  return true
end

local function sudo_browse(dir)
  if not ensure_sudo() then
    return
  end
  dir = (dir and dir ~= "") and dir or vim.fn.input("sudo browse: ", "/root/", "dir")
  if dir == "" then
    return
  end
  local files = vim.fn.systemlist({ "sudo", "-n", "find", dir, "-maxdepth", "4", "-type", "f" })
  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat(files, "\n"), vim.log.levels.ERROR, { title = "SudoBrowse" })
    return
  end
  if #files == 0 then
    vim.notify("keine Dateien in " .. dir, vim.log.levels.WARN, { title = "SudoBrowse" })
    return
  end

  local ok, pickers = pcall(require, "telescope.pickers")
  if ok then
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local state = require("telescope.actions.state")
    pickers
      .new({}, {
        prompt_title = "sudo: " .. dir,
        finder = finders.new_table({ results = files }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(bufnr)
          actions.select_default:replace(function()
            actions.close(bufnr)
            local entry = state.get_selected_entry()
            if entry then
              vim.cmd("edit " .. vim.fn.fnameescape(entry[1]))
            end
          end)
          return true
        end,
      })
      :find()
  else
    vim.ui.select(files, { prompt = "open (sudo): " }, function(choice)
      if choice then
        vim.cmd("edit " .. vim.fn.fnameescape(choice))
      end
    end)
  end
end

return {
  {
    "lambdalisue/vim-suda",
    lazy = false,
    init = function()
      -- read/write inaccessible files automatically via sudo…
      vim.g.suda_smart_edit = 1
      -- …but NON-interactively (relies on the timestamp from :SudoAuth /
      -- SudoBrowse), so suda never grabs the terminal to ask for a password.
      vim.g["suda#executable"] = "sudo -n"
    end,
    config = function()
      vim.api.nvim_create_user_command("SudoAuth", function()
        ensure_sudo()
      end, { desc = "Authenticate sudo for this nvim session" })
      vim.api.nvim_create_user_command("SudoBrowse", function(o)
        sudo_browse(o.args)
      end, { nargs = "?", complete = "dir", desc = "Browse a (0700) dir via sudo" })
    end,
    keys = {
      { "<leader>SA", "<cmd>SudoAuth<cr>", desc = "Sudo authenticate (unlock root)" },
      { "<leader>Sr", "<cmd>SudaRead<cr>", desc = "Sudo read (reload as root)" },
      { "<leader>Sw", "<cmd>SudaWrite<cr>", desc = "Sudo write (save as root)" },
      {
        "<leader>Sb",
        function()
          sudo_browse()
        end,
        desc = "Sudo browse dir (0700)",
      },
    },
  },

  -- which-key-Gruppe benennen
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>S", group = "sudo/root" },
      },
    },
  },
}
