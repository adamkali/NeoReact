-- create a new window 

-- bring in code templates
local code_templates = require 'code_templates'

local api = vim.api
local buf, win
local position = 0

-- Set the window size to be 8 lines and 32 columns
local width = 27
local height = 10

-- create an object to hold the name of the commands and the function to execute
local template_mapping = {
	['React Functional Component'] = code_templates.insert_edfc_template,
	['React useState Snippet    '] = code_templates.insert_state_var_template,
	['React useEffect Snippet   '] = code_templates.insert_use_effect_template,
	['Function().then().catch() '] = code_templates.insert_function_then_catch_template
}

local function open_window()
	buf = api.nvim_create_buf(false, true) -- create new buffer
	api.nvim_buf_set_option(buf, 'bufhidden', 'wipe') -- set buffer options
	print('Buffer in open_window: ' .. buf)
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


	api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts) -- open window

	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf) -- close window when buffer is wiped out

	-- Calculate the center of "React Templates"
	local center = math.floor((width - #('React Templates')) / 2)

	-- add React Templates to the window top center 
	api.nvim_buf_set_lines(buf, 0, -1, false, {string.rep(' ', center) .. 'React Templates'})

	
end

-- make a function to highlight the current line
local function highlight_current_line()
	-- highlight the line labeled by position
	api.nvim_buf_add_highlight(buf, -1, 'Visual', position, 0, -1)
end

-- make a function to move the cursor up and down
local function move_curser(direction)
	-- remove the highlight from the current line
	api.nvim_buf_clear_namespace(0, buf, 0, -1)


	position = position + direction
	-- if position is less than 0, set it to the template_mapping length
	if position < 1 then
		position = #template_mapping
	-- if position is greater than the template_mapping length then set it to 0
	elseif position > #template_mapping + 1 then
		position = 1
	end
	highlight_current_line()
end

local function close_window()
	api.nvim_win_close(win, true)
end

local function call_template(position, win)
	api.nvim_set_current_win(0)
	-- get the template name from the template_mapping object
	local template_name = template_mapping[position]
	-- call the template function
	template_name()
	api.nvim_set_current_win(win)
	close_window()
end

local function set_mapping()

	local mappings = {
		['q'] = 'close_window()',
		['j'] = 'move_curser(1)',
		['k'] = 'move_curser(-1)',
		['<CR>'] = 'call_template(position, win)'
	}

	-- fill buf with the template names from the keys of the template_mapping object
	local template_names = {}
	for k, _ in pairs(template_mapping) do
		table.insert(template_names, k)
	end

	api.nvim_buf_set_lines(buf, 1, -1, false, template_names)

	for key, func in pairs(mappings) do
		api.nvim_buf_set_keymap(buf, 'n', key, ':lua require "NeoReact".' .. func .. '<CR>', {noremap = true, silent = true})
	end
end

local function init_curser()
	local new_position = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
	api.nvim_win_set_cursor(win, {new_position, 0})
end

local function NeoReactWindow()
	position = 0
	open_window()
	set_mapping()
	move_curser(0)
	-- set the cursor to the first line of the new window
	init_curser()

end

return {
	NeoReactWindow = NeoReactWindow,
	move_curser = move_curser,
	-- init_curser = init_curser,
	close_window = close_window,
	update_window = highlight_current_line,
	refactor = code_templates.refactor_to_function_component,
	call_template = call_template
	-- Add the other functions here
	insert_edfc_template = code_templates.insert_edfc_template,
	insert_function_then_catch_template = code_templates.insert_function_then_catch_template,
	insert_state_var_template = code_templates.insert_state_var_template,
	insert_use_effect_template = code_templates.insert_use_effect_template
}