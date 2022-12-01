-- create a new window 

-- bring in code templates
local code_templates = require 'code_templates'

local api = vim.api
local buf, win
local position = 0

-- create an object to hold the name of the commands and the function to execute
local template_mapping = {
	['React Functional Component'] = code_templates.insert_edfc_template,
	['Function().then().catch() '] = code_templates.insert_function_then_catch_template,
	['React useState Snippet    '] = code_templates.insert_state_var_template,
	['React useEffect Snippet   '] = code_templates.insert_use_effect_template
}

local function open_window()
	buf = api.nvim_create_buf(false, true) -- create new buffer
	api.nvim_buf_set_option(buf, 'bufhidden', 'wipe') -- set buffer options
	local border_buf = api.nvim_create_buf(false, true) -- create new buffer for window

	-- Set the window size to be 8 lines and 32 columns
	local width = 32
	local height = 8

	-- Get the current position of the cursor
	local row, col = unpack(api.nvim_win_get_cursor(0))

	-- set some options
	local opts = {
		style = 'minimal',
		relative = 'editor',
		width = width,
		height = height,
		row = row + 2,
		col = col + 2
	}

	-- set border opts
	local border_opts = {
		style = 'minimal',
		relative = 'editor',
		width = width + 2,
		height = height + 2,
		row = row + 1,
		col = col + 1
	}

	local border_lines =  { '╭' .. string.rep('─', width) .. '╮' }
	local middle_line = '│' .. string.rep(' ', width) .. '│'
	for i = 1, height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, '╰' .. string.rep('─', width) .. '╯')
	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	local border_win = api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts) -- open window

	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf) -- close window when buffer is wiped out

	-- add title
	api.nvim_buf_set_lines(buf, 0, 1, false, {'NeoReact'})
	api.nvim_buf_add_highlight(buf, -1, 'Title', 0, 0, -1)
end

local function update_window(direction)
	api.nvim_buf_set_option(buf, 'modifiable', true)
	position = position + direction
	if position < 0 then position = 0 end

	-- fill the window with the template mapping keys
	local lines = {}
	for key, _ in pairs(template_mapping) do
		table.insert(lines, key)
	end

	-- highlight the current line
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	api.nvim_buf_add_highlight(buf, -1, 'CursorLine', position, 0, -1)
	api.nvim_buf_set_option(buf, 'modifiable', false)
	
end

local function close_window()
	api.nvim_win_close(win, true)
end

local function set_mapping()

	-- the mappings should be able to cycle through the templates
	-- j should go down
	-- k should go up
	-- q should quit
	-- control+p should insert the highlighted template
	local mappings = {
		['q'] = close_window,
		['j'] = function() update_window(1) end,
		['k'] = function() update_window(-1) end,
		['<C-p>'] = function()
			-- insert the highlighted template
			-- get the current line
			local line = api.nvim_buf_get_lines(buf, position, position + 1, false)
			-- get the template
			local template = template_mapping[line[1]]
			-- activate the function stored in template
			template()
			-- close the window
			close_window()
		end
	}

	for key, func in pairs(mappings) do
		api.nvim_buf_set_keymap(buf, 'n', key, '<cmd>lua require"NeoReact".' .. func .. '()<CR>', {noremap = true, silent = true})
	end

	local other_chars = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
	  }
	  for k,v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
	  end
end

local function move_curser()
	local new_position = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
	api.nvim_win_set_cursor(win, {new_position, 0})
end

local function NeoReactWindow()
	position = 0
	open_window()
	set_mapping()
	update_window(0)
	api.nvim_win_set_cursor(win, {4, 0})
end

return {
	NeoReactWindow = NeoReactWindow,
	move_curser = move_curser,
	close_window = close_window,
	update_window = update_window,
	refactor = code_templates.refactor_to_function_component
}