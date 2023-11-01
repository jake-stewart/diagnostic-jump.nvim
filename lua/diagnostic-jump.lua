local function minMax(table, callback)
    callback = callback or function (e) return e end
    local min = nil
    local max = nil
    for _, item in ipairs(table) do
        min = math.min(min or math.huge, callback(item))
        max = math.max(max or -math.huge, callback(item))
    end
    return min, max
end

local function getPopups()
    return vim.fn.filter(vim.api.nvim_tabpage_list_wins(0),
        function(_, e) return vim.api.nvim_win_get_config(e).zindex end)
end

local function popupOpen()
    return #getPopups() > 0
end

local defaultJumpDiagnosticOpts = {}

local function jump(direction, initialOpts, subsequentOpts)
    initialOpts = initialOpts or {}
    subsequentOpts = subsequentOpts or initialOpts

    if popupOpen() then
        local opts = {}
        for k, v in pairs(defaultJumpDiagnosticOpts) do opts[k] = v end
        for k, v in pairs(subsequentOpts) do opts[k] = v end
        vim.diagnostic[direction == 1 and "goto_next" or "goto_prev"](opts)
    else
        local cursor_position = nil
        local line = vim.fn.line(".")
        local lineDiagnostics = vim.diagnostic.get(0, {
            lnum = line - 1
        })
        if #lineDiagnostics == 0 then
            cursor_position = {
                line + math.max(direction == 1 and 0 or 1),
                -1,
            }
        else
            local minCol, maxCol = minMax(lineDiagnostics,
                function (d) return d.col end)
            local col = vim.fn.col(".")
            if col <= minCol then
                direction = 1
            elseif col - 1 >= maxCol then
                direction = -1
            end
            cursor_position = { line, col - direction - 1 }
        end
        local opts = { cursor_position = cursor_position }
        for k, v in pairs(defaultJumpDiagnosticOpts) do opts[k] = v end
        for k, v in pairs(initialOpts) do opts[k] = v end
        vim.diagnostic[direction == 1 and "goto_next" or "goto_prev"](opts)
    end
end

local function setup(opts)
    defaultJumpDiagnosticOpts = opts or {}
end

return {
    setup = setup,
    next = function(initialOpts, subsequentOpts)
        jump(1, initialOpts, subsequentOpts)
    end,
    prev = function(initialOpts, subsequentOpts)
        jump(-1, initialOpts, subsequentOpts)
    end
}
