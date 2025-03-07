---@tag telescope.builtin

---@config { ['field_heading'] = "Options" }

---@brief [[
--- Telescope Builtins is a collection of community maintained pickers to support common workflows. It can be used as
--- reference when writing PRs, Telescope extensions, your own custom pickers, or just as a discovery tool for all of
--- the amazing pickers already shipped with Telescope!
---
--- Any of these functions can just be called directly by doing:
---
--- :lua require('telescope.builtin').$NAME_OF_PICKER()
---
--- To use any of Telescope's default options or any picker-specific options, call your desired picker by passing a lua
--- table to the picker with all of the options you want to use. Here's an example with the live_grep picker:
---
--- <code>
---   :lua require('telescope.builtin').live_grep({
---     prompt_title = 'find string in open buffers...',
---     grep_open_files = true
---   })
---   -- or with dropdown theme
---   :lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{
---     previewer = false
---   })
--- </code>
---@brief ]]

if 1 ~= vim.fn.has "nvim-0.6.0" then
  vim.api.nvim_err_writeln "This plugins requires neovim 0.6.0"
  vim.api.nvim_err_writeln "Please update your neovim."
  return
end

local builtin = {}

-- Ref: https://github.com/tjdevries/lazy.nvim
local function require_on_exported_call(mod)
  return setmetatable({}, {
    __index = function(_, picker)
      return function(...)
        return require(mod)[picker](...)
      end
    end,
  })
end

--
--
-- File-related Pickers
--
--

--- Search for a string and get results live as you type (respecting .gitignore)
---@param opts table: options to pass to the picker
---@field cwd string: root dir to search from (default: cwd, use utils.buffer_dir() to search relative to open buffer)
---@field grep_open_files boolean: if true, restrict search to open files only, mutually exclusive with `search_dirs`
---@field search_dirs table: directory/directories to search in, mutually exclusive with `grep_open_files`
---@field additional_args function: function(opts) which returns a table of additional arguments to be passed on
---@field max_results number: define a upper result value
---@field disable_coordinates boolean: don't show the line & row numbers (default: false)
builtin.live_grep = require_on_exported_call("telescope.builtin.files").live_grep

--- Searches for the string under your cursor in your current working directory
---@param opts table: options to pass to the picker
---@field cwd string: root dir to search from (default: cwd, use utils.buffer_dir() to search relative to open buffer)
---@field search string: the query to search
---@field search_dirs table: directory/directories to search in
---@field use_regex boolean: if true, special characters won't be escaped, allows for using regex (default: false)
---@field word_match string: can be set to `-w` to enable exact word matches
---@field additional_args function: function(opts) which returns a table of additional arguments to be passed on
---@field disable_coordinates boolean: don't show the line and row numbers (default: false)
---@field sort_only_text boolean: only sort the text, not the file, line or row (default: false)
builtin.grep_string = require_on_exported_call("telescope.builtin.files").grep_string

--- Search for files (respecting .gitignore)
---@param opts table: options to pass to the picker
---@field cwd string: root dir to search from (default: cwd, use utils.buffer_dir() to search relative to open buffer)
---@field find_command table: command line arguments for `find_files` to use for the search, overrides default: config
---@field follow boolean: if true, follows symlinks (i.e. uses `-L` flag for the `find` command)
---@field hidden boolean: determines whether to show hidden files or not (default: false)
---@field no_ignore boolean: show files ignored by .gitignore, .ignore, etc. (default: false)
---@field search_dirs table: directory/directories to search in
builtin.find_files = require_on_exported_call("telescope.builtin.files").find_files

--- This is an alias for the `find_files` picker
builtin.fd = builtin.find_files

--- Lists function names, variables, and other symbols from treesitter queries
--- - Default keymaps:
---   - `<C-l>`: show autocompletion menu to prefilter your query by kind of ts node you want to see (i.e. `:var:`)
---@field show_line boolean: if true, shows the row:column that the result is found at (default: true)
---@field bufnr number: specify the buffer number where treesitter should run. (default: current buffer)
---@field symbol_highlights table: string -> string. Matches symbol with hl_group
builtin.treesitter = require_on_exported_call("telescope.builtin.files").treesitter

--- Live fuzzy search inside of the currently open buffer
---@param opts table: options to pass to the picker
---@field skip_empty_lines boolean: if true we dont display empty lines (default: false)
builtin.current_buffer_fuzzy_find = require_on_exported_call("telescope.builtin.files").current_buffer_fuzzy_find

--- Lists tags in current directory with tag location file preview (users are required to run ctags -R to generate tags
--- or update when introducing new changes)
---@param opts table: options to pass to the picker
---@field cwd string: root dir to search from (default: cwd, use utils.buffer_dir() to search relative to open buffer)
---@field ctags_file string: specify a particular ctags file to use
---@field show_line boolean: if true, shows the content of the line the tag is found on in the picker (default: true)
---@field only_sort_tags boolean: if true we will only sort tags (default: false)
builtin.tags = require_on_exported_call("telescope.builtin.files").tags

--- Lists all of the tags for the currently open buffer, with a preview
---@param opts table: options to pass to the picker
---@field cwd string: root dir to search from (default: cwd, use utils.buffer_dir() to search relative to open buffer)
---@field ctags_file string: specify a particular ctags file to use
---@field show_line boolean: if true, shows the content of the line the tag is found on in the picker (default: true)
---@field only_sort_tags boolean: if true we will only sort tags (default: false)
builtin.current_buffer_tags = require_on_exported_call("telescope.builtin.files").current_buffer_tags

--
--
-- Git-related Pickers
--
--

--- Fuzzy search for files tracked by Git. This command lists the output of the `git ls-files` command, respects
--- .gitignore, and optionally ignores untracked files
--- - Default keymaps:
---   - `<cr>`: opens the currently selected file
---@param opts table: options to pass to the picker
---@field cwd string: specify the path of the repo
---@field use_git_root boolean: if we should use git root as cwd or the cwd (important for submodule) (default: true)
---@field show_untracked boolean: if true, adds `--others` flag to command and shows untracked files (default: true)
---@field recurse_submodules boolean: if true, adds the `--recurse-submodules` flag to command (default: false)
---@field git_command table: command that will be exectued. {"git","ls-files","--exclude-standard","--cached"}
builtin.git_files = require_on_exported_call("telescope.builtin.git").files

--- Lists commits for current directory with diff preview
--- - Default keymaps:
---   - `<cr>`: checks out the currently selected commit
---   - `<C-r>m`: resets current branch to selected commit using mixed mode
---   - `<C-r>s`: resets current branch to selected commit using soft mode
---   - `<C-r>h`: resets current branch to selected commit using hard mode
---@param opts table: options to pass to the picker
---@field cwd string: specify the path of the repo
---@field use_git_root boolean: if we should use git root as cwd or the cwd (important for submodule) (default: true)
---@field git_command table: command that will be exectued. {"git","log","--pretty=oneline","--abbrev-commit","--","."}
builtin.git_commits = require_on_exported_call("telescope.builtin.git").commits

--- Lists commits for current buffer with diff preview
--- - Default keymaps or your overriden `select_` keys:
---   - `<cr>`: checks out the currently selected commit
---   - `<c-v>`: opens a diff in a vertical split
---   - `<c-x>`: opens a diff in a horizontal split
---   - `<c-t>`: opens a diff in a new tab
---@param opts table: options to pass to the picker
---@field cwd string: specify the path of the repo
---@field use_git_root boolean: if we should use git root as cwd or the cwd (important for submodule) (default: true)
---@field current_file string: specify the current file that should be used for bcommits (default: current buffer)
---@field git_command table: command that will be exectued. {"git","log","--pretty=oneline","--abbrev-commit"}
builtin.git_bcommits = require_on_exported_call("telescope.builtin.git").bcommits

--- List branches for current directory, with output from `git log --oneline` shown in the preview window
--- - Default keymaps:
---   - `<cr>`: checks out the currently selected branch
---   - `<C-t>`: tracks currently selected branch
---   - `<C-r>`: rebases currently selected branch
---   - `<C-a>`: creates a new branch, with confirmation prompt before creation
---   - `<C-d>`: deletes the currently selected branch, with confirmation prompt before deletion
---   - `<C-y>`: merges the currently selected branch, with confirmation prompt before deletion
---@param opts table: options to pass to the picker
---@field cwd string: specify the path of the repo
---@field use_git_root boolean: if we should use git root as cwd or the cwd (important for submodule) (default: true)
---@field pattern string: specify the pattern to match all refs
builtin.git_branches = require_on_exported_call("telescope.builtin.git").branches

--- Lists git status for current directory
--- - Default keymaps:
---   - `<Tab>`: stages or unstages the currently selected file
---   - `<cr>`: opens the currently selected file
---@param opts table: options to pass to the picker
---@field cwd string: specify the path of the repo
---@field use_git_root boolean: if we should use git root as cwd or the cwd (important for submodule) (default: true)
---@field git_icons table: string -> string. Matches name with icon (see source code, make_entry.lua git_icon_defaults)
builtin.git_status = require_on_exported_call("telescope.builtin.git").status

--- Lists stash items in current repository
--- - Default keymaps:
---   - `<cr>`: runs `git apply` for currently selected stash
---@param opts table: options to pass to the picker
---@field cwd string: specify the path of the repo
---@field use_git_root boolean: if we should use git root as cwd or the cwd (important for submodule) (default: true)
---@field show_branch boolean: if we should display the branch name for git stash entries (default: true)
builtin.git_stash = require_on_exported_call("telescope.builtin.git").stash

--
--
-- Internal and Vim-related Pickers
--
--

--- Lists all of the community maintained pickers built into Telescope
---@param opts table: options to pass to the picker
---@field include_extensions boolean: if true will show the pickers of the installed extensions (default: false)
builtin.builtin = require_on_exported_call("telescope.builtin.internal").builtin

--- Opens the previous picker in the identical state (incl. multi selections)
--- - Notes:
---   - Requires `cache_picker` in setup or when having invoked pickers, see |telescope.defaults.cache_picker|
---@param opts table: options to pass to the picker
---@field cache_index number: what picker to resume, where 1 denotes most recent (default: 1)
builtin.resume = require_on_exported_call("telescope.builtin.internal").resume

--- Opens a picker over previously cached pickers in there preserved states (incl. multi selections)
--- - Default keymaps:
---   - `<C-x>`: delete the selected cached picker
--- - Notes:
---   - Requires `cache_picker` in setup or when having invoked pickers, see |telescope.defaults.cache_picker|
---@param opts table: options to pass to the picker
builtin.pickers = require_on_exported_call("telescope.builtin.internal").pickers

--- Use the telescope...
---@param opts table: options to pass to the picker
---@field show_pluto boolean: we love pluto (default: false, because its a hidden feature)
builtin.planets = require_on_exported_call("telescope.builtin.internal").planets

--- Lists symbols inside of `data/telescope-sources/*.json` found in your runtime path
--- or found in `stdpath("data")/telescope/symbols/*.json`. The second path can be customized.
--- We provide a couple of default symbols which can be found in
--- https://github.com/nvim-telescope/telescope-symbols.nvim. This repos README also provides more
--- information about the format in which the symbols have to be.
---@param opts table: options to pass to the picker
---@field symbol_path string: specify the second path. Default: `stdpath("data")/telescope/symbols/*.json`
---@field sources table: specify a table of sources you want to load this time
builtin.symbols = require_on_exported_call("telescope.builtin.internal").symbols

--- Lists available plugin/user commands and runs them on `<cr>`
---@param opts table: options to pass to the picker
builtin.commands = require_on_exported_call("telescope.builtin.internal").commands

--- Lists items in the quickfix list, jumps to location on `<cr>`
---@param opts table: options to pass to the picker
---@field ignore_filename boolean: dont show filenames (default: true)
builtin.quickfix = require_on_exported_call("telescope.builtin.internal").quickfix

--- Lists items from the current window's location list, jumps to location on `<cr>`
---@param opts table: options to pass to the picker
---@field ignore_filename boolean: dont show filenames (default: true)
builtin.loclist = require_on_exported_call("telescope.builtin.internal").loclist

--- Lists previously open files, opens on `<cr>`
---@param opts table: options to pass to the picker
---@field only_cwd boolean: show only files in the cwd (default: false)
---@field cwd_only boolean: alias for only_cwd
builtin.oldfiles = require_on_exported_call("telescope.builtin.internal").oldfiles

--- Lists commands that were executed recently, and reruns them on `<cr>`
--- - Default keymaps:
---   - `<C-e>`: open the command line with the text of the currently selected result populated in it
---@param opts table: options to pass to the picker
builtin.command_history = require_on_exported_call("telescope.builtin.internal").command_history

--- Lists searches that were executed recently, and reruns them on `<cr>`
--- - Default keymaps:
---   - `<C-e>`: open a search window with the text of the currently selected search result populated in it
---@param opts table: options to pass to the picker
builtin.search_history = require_on_exported_call("telescope.builtin.internal").search_history

--- Lists vim options, allows you to edit the current value on `<cr>`
---@param opts table: options to pass to the picker
builtin.vim_options = require_on_exported_call("telescope.builtin.internal").vim_options

--- Lists available help tags and opens a new window with the relevant help info on `<cr>`
---@param opts table: options to pass to the picker
---@field lang string: specify language (default: vim.o.helplang)
---@field fallback boolean: fallback to en if language isn't installed (default: true)
builtin.help_tags = require_on_exported_call("telescope.builtin.internal").help_tags

--- Lists manpage entries, opens them in a help window on `<cr>`
---@param opts table: options to pass to the picker
---@field sections table: a list of sections to search, use `{ "ALL" }` to search in all sections (default: { "1" })
---@field man_cmd function: that returns the man command. (Default: `apropos ""` on linux, `apropos " "` on macos)
builtin.man_pages = require_on_exported_call("telescope.builtin.internal").man_pages

--- Lists lua modules and reloads them on `<cr>`
---@param opts table: options to pass to the picker
---@field column_len number: define the max column len for the module name (default: dynamic, longest module name)
builtin.reloader = require_on_exported_call("telescope.builtin.internal").reloader

--- Lists open buffers in current neovim instance, opens selected buffer on `<cr>`
---@param opts table: options to pass to the picker
---@field show_all_buffers boolean: if true, show all buffers, including unloaded buffers (default: true)
---@field ignore_current_buffer boolean: if true, don't show the current buffer in the list (default: false)
---@field only_cwd boolean: if true, only show buffers in the current working directory (default: false)
---@field cwd_only boolean: alias for only_cwd
---@field sort_lastused boolean: Sorts current and last buffer to the top and selects the lastused (default: false)
---@field sort_mru boolean: Sorts all buffers after most recent used. Not just the current and last one (default: false)
---@field bufnr_width number: Defines the width of the buffer numbers in front of the filenames  (default: dynamic)
builtin.buffers = require_on_exported_call("telescope.builtin.internal").buffers

--- Lists available colorschemes and applies them on `<cr>`
---@param opts table: options to pass to the picker
---@field enable_preview boolean: if true, will preview the selected color
builtin.colorscheme = require_on_exported_call("telescope.builtin.internal").colorscheme

--- Lists vim marks and their value, jumps to the mark on `<cr>`
---@param opts table: options to pass to the picker
builtin.marks = require_on_exported_call("telescope.builtin.internal").marks

--- Lists vim registers, pastes the contents of the register on `<cr>`
--- - Default keymaps:
---   - `<C-e>`: edit the contents of the currently selected register
---@param opts table: options to pass to the picker
builtin.registers = require_on_exported_call("telescope.builtin.internal").registers

--- Lists normal mode keymappings, runs the selected keymap on `<cr>`
---@param opts table: options to pass to the picker
---@field modes table: a list of short-named keymap modes to search (default: { "n", "i", "c", "x" })
---@field show_plug boolean: if true, the keymaps for which the lhs contains "<Plug>" are also shown (default: true)
builtin.keymaps = require_on_exported_call("telescope.builtin.internal").keymaps

--- Lists all available filetypes, sets currently open buffer's filetype to selected filetype in Telescope on `<cr>`
---@param opts table: options to pass to the picker
builtin.filetypes = require_on_exported_call("telescope.builtin.internal").filetypes

--- Lists all available highlights
---@param opts table: options to pass to the picker
builtin.highlights = require_on_exported_call("telescope.builtin.internal").highlights

--- Lists vim autocommands and goes to their declaration on `<cr>`
---@param opts table: options to pass to the picker
builtin.autocommands = require_on_exported_call("telescope.builtin.internal").autocommands

--- Lists spelling suggestions for the current word under the cursor, replaces word with selected suggestion on `<cr>`
---@param opts table: options to pass to the picker
builtin.spell_suggest = require_on_exported_call("telescope.builtin.internal").spell_suggest

--- Lists the tag stack for the current window, jumps to tag on `<cr>`
---@param opts table: options to pass to the picker
---@field ignore_filename boolean: dont show filenames (default: true)
builtin.tagstack = require_on_exported_call("telescope.builtin.internal").tagstack

--- Lists items from Vim's jumplist, jumps to location on `<cr>`
---@param opts table: options to pass to the picker
---@field ignore_filename boolean: dont show filenames (default: true)
builtin.jumplist = require_on_exported_call("telescope.builtin.internal").jumplist

--
--
-- LSP-related Pickers
--
--

--- Lists LSP references for word under the cursor, jumps to reference on `<cr>`
---@param opts table: options to pass to the picker
builtin.lsp_references = require_on_exported_call("telescope.builtin.lsp").references

--- Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope
---@param opts table: options to pass to the picker
---@field jump_type string: how to goto definition if there is only one, values: "tab", "split", "vsplit", "never"
---@field ignore_filename boolean: dont show filenames (default: true)
builtin.lsp_definitions = require_on_exported_call("telescope.builtin.lsp").definitions

--- Goto the definition of the type of the word under the cursor, if there's only one,
--- otherwise show all options in Telescope
---@param opts table: options to pass to the picker
---@field jump_type string: how to goto definition if there is only one, values: "tab", "split", "vsplit", "never"
---@field ignore_filename boolean: dont show filenames (default: true)
---@field include_declaration boolean: include symbol declaration in the lsp references (default: true)
builtin.lsp_type_definitions = require("telescope.builtin.lsp").type_definitions

--- Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope
---@param opts table: options to pass to the picker
---@field jump_type string: how to goto implementation if there is only one, values: "tab", "split", "vsplit", "never"
---@field ignore_filename boolean: dont show filenames (default: true)
builtin.lsp_implementations = require_on_exported_call("telescope.builtin.lsp").implementations

--- Lists any LSP actions for the word under the cursor which can be triggered with `<cr>`
---@param opts table: options to pass to the picker
---@field timeout number: timeout for the sync call (default: 10000)
builtin.lsp_code_actions = require_on_exported_call("telescope.builtin.lsp").code_actions

--- Lists any LSP actions for a given range, that can be triggered with `<cr>`
---@param opts table: options to pass to the picker
---@field timeout number: timeout for the sync call (default: 10000)
---@field start_line number: where the code action starts (default: handled by :'<,'>Telescope lsp_range_code_actions)
---@field end_line number: where the code action ends (default: handled by :'<,'>Telescope lsp_range_code_actions)
builtin.lsp_range_code_actions = require_on_exported_call("telescope.builtin.lsp").range_code_actions

--- Lists LSP document symbols in the current buffer
--- - Default keymaps:
---   - `<C-l>`: show autocompletion menu to prefilter your query by type of symbol you want to see (i.e. `:variable:`)
---@param opts table: options to pass to the picker
---@field ignore_filename boolean: dont show filenames (default: true)
---@field show_line boolean: if true, shows the content of the line the tag is found on (default: false)
---@field symbols string|table: filter results by symbol kind(s)
---@field ignore_symbols string|table: list of symbols to ignore
---@field symbol_highlights table: string -> string. Matches symbol with hl_group
builtin.lsp_document_symbols = require_on_exported_call("telescope.builtin.lsp").document_symbols

--- Lists LSP document symbols in the current workspace
--- - Default keymaps:
---   - `<C-l>`: show autocompletion menu to prefilter your query by type of symbol you want to see (i.e. `:variable:`)
---@param opts table: options to pass to the picker
---@field query string: for what to query the workspace (default: "")
---@field ignore_filename boolean: dont show filenames (default: false)
---@field show_line boolean: if true, shows the content of the line the tag is found on (default: false)
---@field symbols string|table: filter results by symbol kind(s)
---@field ignore_symbols string|table: list of symbols to ignore
---@field symbol_highlights table: string -> string. Matches symbol with hl_group
builtin.lsp_workspace_symbols = require_on_exported_call("telescope.builtin.lsp").workspace_symbols

--- Dynamically lists LSP for all workspace symbols
--- - Default keymaps:
---   - `<C-l>`: show autocompletion menu to prefilter your query by type of symbol you want to see (i.e. `:variable:`)
---@param opts table: options to pass to the picker
---@field ignore_filename boolean: dont show filenames (default: false)
---@field show_line boolean: if true, shows the content of the line the symbol is found on (default: false)
---@field symbols string|table: filter results by symbol kind(s)
---@field ignore_symbols string|table: list of symbols to ignore
---@field symbol_highlights table: string -> string. Matches symbol with hl_group
builtin.lsp_dynamic_workspace_symbols = require_on_exported_call("telescope.builtin.lsp").dynamic_workspace_symbols

--
--
-- Diagnostics Pickers
--
--

--- Lists diagnostics
--- - Fields:
---   - `All severity flags can be passed as `string` or `number` as per `:vim.diagnostic.severity:`
--- - Default keymaps:
---   - `<C-l>`: show autocompletion menu to prefilter your query with the diagnostic you want to see (i.e. `:warning:`)
---@param opts table: options to pass to the picker
---@field bufnr string|number: if nil get diagnostics for all open buffers. Use 0 for current buffer
---@field severity string|number: filter diagnostics by severity name (string) or id (number)
---@field severity_limit string|number: keep diagnostics equal or more severe wrt severity name (string) or id (number)
---@field severity_bound string|number: keep diagnostics equal or less severe wrt severity name (string) or id (number)
---@field root_dir string|boolean: if set to string, get diagnostics only for buffers under this dir otherwise cwd
---@field no_unlisted boolean: if true, get diagnostics only for listed buffers
---@field no_sign boolean: hide DiagnosticSigns from Results (default: false)
---@field line_width number: set length of diagnostic entry text in Results
---@field namespace number: limit your diagnostics to a specific namespace
builtin.diagnostics = require_on_exported_call("telescope.builtin.diagnostics").get

local apply_config = function(mod)
  local pickers_conf = require("telescope.config").pickers
  for k, v in pairs(mod) do
    mod[k] = function(opts)
      opts = opts or {}
      opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
      opts.winnr = opts.winnr or vim.api.nvim_get_current_win()
      local pconf = pickers_conf[k] or {}
      local defaults = (function()
        if pconf.theme then
          return require("telescope.themes")["get_" .. pconf.theme](pconf)
        end
        return vim.deepcopy(pconf)
      end)()

      if pconf.mappings then
        defaults.attach_mappings = function(_, map)
          for mode, tbl in pairs(pconf.mappings) do
            for key, action in pairs(tbl) do
              map(mode, key, action)
            end
          end
          return true
        end
      end

      if pconf.attach_mappings and opts.attach_mappings then
        local opts_attach = opts.attach_mappings
        opts.attach_mappings = function(prompt_bufnr, map)
          pconf.attach_mappings(prompt_bufnr, map)
          return opts_attach(prompt_bufnr, map)
        end
      end

      v(vim.tbl_extend("force", defaults, opts))
    end
  end

  return mod
end

-- We can't do this in one statement because tree-sitter-lua docgen gets confused if we do
builtin = apply_config(builtin)
return builtin
