-- create a new window 

-- bring in code templates
local code_templates = require 'code_templates'

local api = vim.api
local buf, win
local position = 0

-- Set the window size to be 8 lines and 32 columns
local width = 26
local height = 6

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



	-- Get the current position of the cursor
	local row, col = unpack(api.nvim_win_get_cursor(0))

	-- Set the position of the window three columns to the right of the cursor 
	col = col + 3
	row = row + 1

	-- set the border width and height to be two more than the window
	local border_width = width + 2
	local border_height = height + 2

	-- set the starting point of the border to be one less than the window
	local border_start_row = row - 1
	local border_start_col = col - 1

	-- set some options
	local opts = {
		style = 'minimal',
		relative = 'editor',
		width = width,
		height = height,
		row = row,
		col = col
	}

	-- set border opts
	local border_opts = {
		style = 'minimal',
		relative = 'editor',
		width = border_width,
		height = border_height,
		row = border_start_row,
		col = border_start_col
	}

	-- create border with these characters ┌ ─ ┐ │ └ ┘
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

	-- Calculate the center of "React Templates"
	local center = math.floor((width - #('React Templates')) / 2)

	-- add a title to the window top center 
	api.nvim_buf_set_lines(buf, 0, center, false, {'React Templates'})
end

-- make a function to highlight the current line
local function highlight_current_line()
	api.nvim_buf_add_highlight(0, buf, 'Identifier', position, 0, -1)
end

-- make a function to move the cursor up and down
local function move_cursor(direction)
	-- remove the highlight from the current line
	api.nvim_buf_clear_namespace(0, buf, 0, -1)


	position = position + direction
	-- if position is less than 0, set it to the template_mapping length
	if position < 0 then
		position = #template_mapping
	-- if position is greater than the template_mapping length then set it to 0
	elseif position > 4 then
		position = 0
	end
	highlight_current_line()
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
		['q'] = close_window(),
		['j'] = move_cursor(1),
		['k'] = move_cursor(-1),
		['<C-p>'] = function()
			-- select the template based on the position
			local template = template_mapping[position]
			-- call the template function
			template()
			-- close the window
			close_window()
		end
	}

	-- fill buf with the template names from the keys of the template_mapping object
	local template_names = {}
	for k, _ in pairs(template_mapping) do
		table.insert(template_names, k)
	end
	api.nvim_buf_set_lines(buf, 1, -1, false, template_names)

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
	update_window = highlight_current_line,
	refactor = code_templates.refactor_to_function_component,
	-- Add the other functions here
	insert_edfc_template = code_templates.insert_edfc_template,
	insert_function_then_catch_template = code_templates.insert_function_then_catch_template,
	insert_state_var_template = code_templates.insert_state_var_template,
	insert_use_effect_template = code_templates.insert_use_effect_template
}