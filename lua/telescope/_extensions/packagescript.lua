local json = require "json"

local actions = require('telescope.actions')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local sorters = require('telescope.sorters')

return require('telescope').register_extension {
    exports = {
        scripts = function(opts)
            opts = opts or {}

            local filePath   = vim.fn.getcwd() .. '\\package.json'

            local file       = io.open(filePath, "rb")
            if file == nil then
                error("Package.json could not be found")
            end
            local jsonString = file:read "*a"
            file:close()

            local scriptsFromJson = json.decode(jsonString)['scripts']

            local scriptsNames = {}
            local scripts      = {}
            for name, code in pairs(scriptsFromJson) do
                table.insert(scriptsNames , name)
                table.insert(scripts      , code)
            end

            pickers.new(opts, {
                prompt_title = 'Scripts',
                finder = finders.new_table {
                    results = scriptsNames
                },
                sorter = sorters.get_generic_fuzzy_sorter(),
                attach_mappings = function(prompt_bufnr, map)
                    local execute_script = function()
                        local selection = actions.get_selected_entry(prompt_bufnr)
                        actions.close(prompt_bufnr)
                        local command = 'FloatermNew!' .. scriptsFromJson[selection.value]
                        vim.cmd(command)
                    end

                    map('i', '<CR>', execute_script)
                    map('n', '<CR>', execute_script)

                    return true
                end
            }):find()
        end
    }
}