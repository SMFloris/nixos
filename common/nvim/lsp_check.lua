#!/usr/bin/env lua

-- Helper script to find LSP server executables in Neovim profile
local function find_executable(name)
    local handle = io.popen('which ' .. name .. ' 2>/dev/null')
    if handle then
        local result = handle:read("*a")
        handle:close()
        if result and result ~= "" then
            return result:gsub("%s+", "")
        end
    end
    return nil
end

-- Get profile paths
local home = os.getenv("HOME") or "."
local profile = home .. "/.nix-profile-neovim"
local state = home .. "/.local/state/neovim-profile"
local npm_bin = state .. "/npm/bin"

-- Common LSP server paths to check
local lsp_servers = {
    pyright = { 
        'pyright-langserver', 
        npm_bin .. '/pyright-langserver',
        profile .. '/bin/pyright-langserver',
        'pyright'
    },
    vtsls = { 
        'vtsls-server',
        npm_bin .. '/vtsls',
        profile .. '/bin/vtsls',
    },
    nil_ls = { 
        'nil',
        profile .. '/bin/nil',
    },
    lua_ls = { 
        'lua-language-server',
        profile .. '/bin/lua-language-server',
    },
}

print("LSP Server Path Detection:")
print("==========================")

local found_servers = {}
for server, executables in pairs(lsp_servers) do
    print("\n" .. server .. ":")
    for _, exe in ipairs(executables) do
        local path = find_executable(exe)
        if path then
            print("  ✓ " .. exe .. " -> " .. path)
            found_servers[server] = path
        else
            print("  ✗ " .. exe .. " not found in PATH")
        end
    end
end

print("\nCustom Path Configuration:")
print("==========================")
print("If you need to customize paths, add these to your lsp.lua config:")
print("")

-- Generate custom path suggestions
for server, path in pairs(found_servers) do
    print("vim.lsp.config('" .. server .. "', {")
    print("    cmd = { '" .. path .. "' },")
    print("    -- ... other config")
    print("})")
    print("")
end

print("\nInstallation Commands:")
print("======================")
print("If servers are missing, install them with:")
print("npm install -g typescript-language-server")
print("pip install pyright")
print("nix profile install nixpkgs#nil")
print("nix profile install nixpkgs#lua-language-server")
