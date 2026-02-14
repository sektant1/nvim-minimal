local M = {}

local function notify(msg, level)
	level = level or vim.log.levels.INFO
	if vim.notify then
		vim.notify(msg, level)
	else
		print(msg)
	end
end

local function cwd_basename()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

local function render(str, ctx)
	return (str:gsub("{{(%w+)}}", function(k)
		return ctx[k] or ""
	end))
end

local function write_file(relpath, content, force)
	local abspath = vim.fs.joinpath(vim.fn.getcwd(), relpath)
	local dir = vim.fn.fnamemodify(abspath, ":h")
	vim.fn.mkdir(dir, "p")

	if vim.fn.filereadable(abspath) == 1 and not force then
		notify("Skip existing: " .. relpath .. " (use :CMakeTemplate! to overwrite)", vim.log.levels.WARN)
		return
	end

	local f = io.open(abspath, "w")
	if not f then
		notify("Failed to write: " .. abspath, vim.log.levels.ERROR)
		return
	end
	f:write(content)
	f:close()
end

M.templates = {
	["cpp-exe"] = {
		desc = "C++ executable (src/main.cpp)",
		files = function(ctx)
			return {
				["CMakeLists.txt"] = render(
					[[
cmake_minimum_required(VERSION 3.24)
project({{project}} VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable({{project}}
  src/main.cpp
)

if (MSVC)
  target_compile_options({{project}} PRIVATE /W4 /permissive-)
else()
  target_compile_options({{project}} PRIVATE -Wall -Wextra -Wpedantic)
endif()
]],
					ctx
				),

				["src/main.cpp"] = render(
					[[
#include <iostream>

int main() {
  std::cout << "{{project}} running\n";
  return 0;
}
]],
					ctx
				),
			}
		end,
	},

	["cpp-static-lib"] = {
		desc = "C++ static library (+ example exe)",
		files = function(ctx)
			return {
				["CMakeLists.txt"] = render(
					[[
cmake_minimum_required(VERSION 3.24)
project({{project}} VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library({{project}} STATIC
  src/{{project}}.cpp
)
target_include_directories({{project}} PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_executable({{project}}_example
  src/main.cpp
)
target_link_libraries({{project}}_example PRIVATE {{project}})

if (MSVC)
  target_compile_options({{project}} PRIVATE /W4 /permissive-)
  target_compile_options({{project}}_example PRIVATE /W4 /permissive-)
else()
  target_compile_options({{project}} PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options({{project}}_example PRIVATE -Wall -Wextra -Wpedantic)
endif()
]],
					ctx
				),

				["include/" .. ctx.project .. "/" .. ctx.project .. ".hpp"] = render(
					[[
#pragma once

int {{project}}_answer();
]],
					ctx
				),

				["src/" .. ctx.project .. ".cpp"] = render(
					[[
#include "{{project}}/{{project}}.hpp"

int {{project}}_answer() {
  return 42;
}
]],
					ctx
				),

				["src/main.cpp"] = render(
					[[
#include <iostream>
#include "{{project}}/{{project}}.hpp"

int main() {
  std::cout << "{{project}}_answer() = " << {{project}}_answer() << "\n";
  return 0;
}
]],
					ctx
				),
			}
		end,
	},
}

function M.pick_and_write(opts)
	opts = opts or {}
	local keys = vim.tbl_keys(M.templates)
	table.sort(keys)

	vim.ui.select(keys, {
		prompt = "CMake template",
		format_item = function(k)
			return k .. " — " .. (M.templates[k].desc or "")
		end,
	}, function(choice)
		if not choice then
			return
		end

		vim.ui.input({ prompt = "Project name", default = cwd_basename() }, function(name)
			if not name or name == "" then
				return
			end

			local ctx = { project = name }
			local template = M.templates[choice]
			local files = template.files(ctx)

			for relpath, content in pairs(files) do
				write_file(relpath, content, opts.force)
			end

			vim.cmd.edit("CMakeLists.txt")

			if opts.generate then
				pcall(vim.cmd, "CMakeGenerate")
			end
		end)
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("CMakeTemplate", function(cmdopts)
		M.pick_and_write({
			force = cmdopts.bang,
			generate = (cmdopts.args == "generate"),
		})
	end, {
		bang = true,
		nargs = "?",
		complete = function()
			return { "generate" }
		end,
		desc = "Create CMakeLists.txt from a template in the current directory",
	})
end

return M
