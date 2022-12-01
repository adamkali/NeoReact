-- make a Neovim template function that inerts template React Function component
-- and sets cursor position inside the return statemet
-- it should import React, useEffect, useState from react
-- it should also have a props: any as an argument
--

local api = vim.api

local function insert_edfc_template()
	local template = [[
import React, { useEffect, useState } from 'react';

export default function (props.any) {
	const [<++>, set<++>] = useState(<++>);

	useEffect(() => {
		<++>
	}, [<++>]);

	return (
		<div>
			<++>
		</div>
	);
}
]]

	api.nvim_put({template}, 'l', true, true)

	-- set cursor position where the function name should be 
	api.nvim_win_set_cursor(0, {3, 24})
end

local function insert_state_var_template()
	local template = [[
	const [, set<++>] = useState(<++>);
]]

	api.nvim_put({template}, 'l', true, true)

	-- set cursor position where the function name should be 
	api.nvim_win_set_cursor(0, {1, 12})
end

local function insert_use_effect_template()
	local template = [[
	useEffect(() => {
		
	}, [<++>]);
]]

	api.nvim_put({template}, 'l', true, true)

	-- set cursor position where the function name should be 
	api.nvim_win_set_cursor(0, {2, 9})
end

local function refactor_to_function_component()
	-- get the current selection
	local start_line, start_col, end_line, end_col = unpack(api.fn.getpos("'<"))

	-- save the current text in the register
	local saved = api.cmd('normal! "ay')

	-- get a filename from the user
	local filename = api.fn.input('Enter a filename: ')

	-- create a new file in the same directory as the current file
	local current_file = api.fn.expand('%:p')
	local new_file = current_file:gsub(api.fn.expand('%:t'), filename .. '.tsx')

	-- also call the function name the same as the filename without the extension
	local function_name = filename:gsub('(.)(%u)', '%1%2'):gsub('(%u+)', function(x) return x:lower() end)

	-- add an import statement to the current file with function name as the import name and as the path
	local import_statement = 'import ' .. function_name .. ' from \'./' .. filename .. '\''

	-- put it on the first line of the current file
	api.nvim_put({import_statement}, 'l', true, true)

	-- create a new file
	api.fn.writefile({}, new_file)

	-- open the new file
	api.cmd('edit ' .. new_file)

	-- insert the saved text into the new file


	local template = [[
import React, { useEffect, useState } from 'react';

export default function ]] .. function_name .. [[(props.any) {
	]] .. saved .. [[

	return (
		<div>
			<++>
		</div>
	);
}
]]

	api.nvim_put({template}, 'l', true, true)

	-- set cursor position where the function name should be 
	api.nvim_win_set_cursor(0, {3, 24})

	-- close the current file
	api.cmd('close')

	-- open the new file
	api.cmd('edit ' .. new_file)
end

local function insert_function_then_catch_template()
	local template = [[
().then((res) => {
	<++>
})
.catch((err) => {
	<++>
})
]]

	api.nvim_put({template}, 'l', true, true)

	-- set cursor position right before the ()
	api.nvim_win_set_cursor(0, {1, 1})
end

return {
	insert_edfc_template = insert_edfc_template,
	insert_state_var_template = insert_state_var_template,
	insert_use_effect_template = insert_use_effect_template,
	refactor_to_function_component = refactor_to_function_component,
	insert_function_then_catch_template = insert_function_then_catch_template
}