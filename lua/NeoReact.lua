local window = require 'window'

local M = {}

M.NeoReact = window.NeoReactWindow
M.move_curser = window.move_curser
M.close_window = window.close_window
M.highlight_current_line = window.highlight_current_line
M.refactor = window.refactor_to_function_component
M.call_template = window.call_template
M.insert_edfc_template = window.insert_edfc_template
M.insert_function_then_catch_template = window.insert_function_then_catch_template
M.insert_state_var_template = window.insert_state_var_template
M.insert_use_effect_template = window.insert_use_effect_template
M.template_mapping = window.template_mapping
M.template_names = window.template_names

return M