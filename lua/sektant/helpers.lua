-- UTILS
local U = {}

function U.has(bin)
	return vim.fn.executable(bin) == 1
end

function U.esc(s)
	return vim.fn.shellescape(s)
end

function U.notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO)
end

function U.term(cmd, opts)
	opts = opts or {}
	if opts.write ~= false then
		vim.cmd("write")
	end
	local open = opts.open or "botright split"
	local prefix = (opts.cwd and opts.cwd ~= "") and ("cd " .. U.esc(opts.cwd) .. " && ") or ""
	vim.cmd(open .. " | terminal " .. prefix .. cmd)
	vim.cmd("startinsert")
end

local function inputlist_pick(items, title)
	local lines = { title or "Pick" }
	for i, it in ipairs(items) do
		lines[#lines + 1] = ("%d) %s"):format(i, it)
	end
	local idx = vim.fn.inputlist(lines)
	if idx < 1 or idx > #items then
		return nil
	end
	return items[idx]
end

local function is_file(path)
	local stat = vim.loop.fs_stat(path)
	return stat and stat.type == "file"
end

-- CMAKE
local CMake = { build_dir = "build", build_type = "Debug" }

function CMake.root()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return nil
	end
	local res = vim.fs.find("CMakeLists.txt", { upward = true, path = vim.fs.dirname(name) })
	return res[1] and vim.fs.dirname(res[1]) or nil
end

function CMake.exec(cmd)
	local root = CMake.root()
	if not root then
		U.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
		return
	end
	U.term(cmd, { cwd = root })
end

function CMake.configure()
	CMake.exec(
		("cmake -S . -B %s -DCMAKE_BUILD_TYPE=%s"):format(CMake.build_dir, CMake.build_type)
			.. (" && (ln -sf %s/compile_commands.json compile_commands.json || true)"):format(CMake.build_dir)
	)
end

function CMake.build(target)
	local cmd = ("cmake --build %s --parallel"):format(CMake.build_dir)
	if target and target ~= "" then
		cmd = cmd .. " --target " .. target
	end
	CMake.exec(cmd)
end

function CMake.rebuild()
	CMake.exec(
		("rm -rf %s"):format(CMake.build_dir)
			.. (" && cmake -S . -B %s -DCMAKE_BUILD_TYPE=%s"):format(CMake.build_dir, CMake.build_type)
			.. (" && (ln -sf %s/compile_commands.json compile_commands.json || true)"):format(CMake.build_dir)
			.. (" && cmake --build %s --parallel"):format(CMake.build_dir)
	)
end

function CMake.list_executables(root)
	local build = root .. "/" .. CMake.build_dir
	local paths = vim.fn.globpath(build, "**/*", false, true)
	local out = {}

	for _, p in ipairs(paths) do
		if is_file(p) and vim.fn.executable(p) == 1 then
			if not p:match("%.so$") and not p:match("%.a$") and not p:match("%.o$") then
				out[#out + 1] = p
			end
		end
	end

	table.sort(out)
	return out
end

function CMake.pick_executable()
	local root = CMake.root() or vim.fn.getcwd()
	local exes = CMake.list_executables(root)

	if #exes == 0 then
		return vim.fn.input("Executable: ", root .. "/" .. CMake.build_dir .. "/", "file")
	end

	if #exes == 1 then
		vim.g.last_cmake_exe = exes[1]
		return exes[1]
	end

	local choice = inputlist_pick(exes, "Pick executable")
	if choice then
		vim.g.last_cmake_exe = choice
	end
	return choice
end

function CMake.ensure_executable()
	local exe = vim.g.last_cmake_exe
	if exe and exe ~= "" and vim.fn.filereadable(exe) == 1 then
		return exe
	end
	return CMake.pick_executable()
end

function CMake.run_last()
	local root = CMake.root()
	if not root then
		U.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
		return
	end

	local exe = CMake.ensure_executable()
	if not exe or exe == "" then
		return
	end

	U.term(U.esc(exe), { cwd = root })
end

function CMake.build_and_run()
	local root = CMake.root()
	if not root then
		U.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
		return
	end

	local exe = CMake.ensure_executable()
	if not exe or exe == "" then
		return
	end

	local cmd = ("cmake --build %s --parallel && %s"):format(CMake.build_dir, U.esc(exe))
	U.term(cmd, { cwd = root })
end

-- CMakeLists TEMPLATES
local CMakeTemplates = {}

CMakeTemplates.basic = function(project)
	return {
		"cmake_minimum_required(VERSION 3.16)",
		"",
		("project(%s LANGUAGES C CXX)"):format(project),
		"",
		"set(CMAKE_C_STANDARD 17)",
		"set(CMAKE_CXX_STANDARD 20)",
		"set(CMAKE_CXX_STANDARD_REQUIRED ON)",
		"",
		"set(CMAKE_EXPORT_COMPILE_COMMANDS ON)",
		"",
		"if(NOT CMAKE_BUILD_TYPE)",
		'  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)',
		"endif()",
		"",
		"file(GLOB_RECURSE SRC",
		"  src/*.c",
		"  src/*.cpp",
		")",
		"",
		"add_executable(${PROJECT_NAME} ${SRC})",
		"",
		"target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)",
	}
end

CMakeTemplates.glfw_opengl = function(project)
	return {
		"cmake_minimum_required(VERSION 3.16)",
		"",
		("project(%s LANGUAGES C CXX)"):format(project),
		"",
		"set(CMAKE_C_STANDARD 17)",
		"set(CMAKE_CXX_STANDARD 20)",
		"set(CMAKE_CXX_STANDARD_REQUIRED ON)",
		"",
		"set(CMAKE_EXPORT_COMPILE_COMMANDS ON)",
		"",
		"if(NOT CMAKE_BUILD_TYPE)",
		'  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)',
		"endif()",
		"",
		"file(GLOB_RECURSE SRC",
		"  src/*.c",
		"  src/*.cpp",
		")",
		"",
		"add_executable(${PROJECT_NAME} ${SRC})",
		"",
		"find_package(OpenGL REQUIRED)",
		"find_package(glfw3 REQUIRED)",
		"",
		"target_link_libraries(${PROJECT_NAME} PRIVATE OpenGL::GL glfw)",
		"target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)",
		"",
		"# Se você usa GLAD/GLEW, adicione aqui include dirs e sources da lib/loader.",
	}
end

local function generate_cmakelists()
	local cwd = vim.fn.getcwd()
	local path = cwd .. "/CMakeLists.txt"
	local project = vim.fn.fnamemodify(cwd, ":t")

	if vim.fn.filereadable(path) == 1 then
		U.notify("CMakeLists.txt já existe", vim.log.levels.WARN)
		return
	end

	local choices = {
		{ label = "Basic (C/C++)", key = "basic" },
		{ label = "GLFW + OpenGL (system packages)", key = "glfw_opengl" },
	}

	vim.ui.select(choices, {
		prompt = "CMake template",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end

		local lines = assert(CMakeTemplates[choice.key])(project)
		vim.fn.writefile(lines, path)
		U.notify("CMakeLists.txt criado")
		vim.cmd("edit CMakeLists.txt")
	end)
end

local Runner = { specs = {} }

function Runner.register(filetypes, fn)
	for _, ft in ipairs(filetypes) do
		Runner.specs[ft] = fn
	end
end

local function first_available(candidates, mkcmd, err)
	return function(file)
		for _, bin in ipairs(candidates) do
			if U.has(bin) then
				return { cmd = mkcmd(bin, file), cwd = vim.fs.dirname(file) }
			end
		end
		U.notify(err, vim.log.levels.ERROR)
		return nil
	end
end

local function find_venv_python(start_dir)
	local venv = vim.fs.find({ ".venv", "venv" }, { upward = true, path = start_dir, type = "directory" })[1]
	if not venv then
		return nil
	end
	local is_win = vim.loop.os_uname().sysname:match("Windows") ~= nil
	local rel = is_win and "Scripts/python.exe" or "bin/python"
	local py = venv .. "/" .. rel
	return (vim.fn.executable(py) == 1) and py or nil
end

Runner.register({ "c", "cpp" }, function(_file)
	if not CMake.root() then
		U.notify("No CMake project for C/C++ run", vim.log.levels.WARN)
		return nil
	end
	local exe = CMake.ensure_executable()
	if not exe then
		return nil
	end
	return { cmd = U.esc(exe), cwd = CMake.root() }
end)

Runner.register(
	{ "javascript", "javascriptreact" },
	first_available({ "node", "bun" }, function(bin, file)
		return bin .. " " .. U.esc(file)
	end, "No JS runner found (node/bun)")
)

Runner.register({ "typescript", "typescriptreact" }, function(file)
	local dir = vim.fs.dirname(file)
	local order = {
		{
			"bun",
			function()
				return "bun " .. U.esc(file)
			end,
		},
		{
			"tsx",
			function()
				return "tsx " .. U.esc(file)
			end,
		},
		{
			"ts-node",
			function()
				return "ts-node " .. U.esc(file)
			end,
		},
		{
			"deno",
			function()
				return "deno run " .. U.esc(file)
			end,
		},
	}
	for _, item in ipairs(order) do
		if U.has(item[1]) then
			return { cmd = item[2](), cwd = dir }
		end
	end
	U.notify("No TS runner found (bun/tsx/ts-node/deno)", vim.log.levels.ERROR)
	return nil
end)

Runner.register({ "python" }, function(file)
	local dir = vim.fs.dirname(file)
	local vpy = find_venv_python(dir)
	if vpy then
		return { cmd = U.esc(vpy) .. " -u " .. U.esc(file), cwd = dir }
	end
	if U.has("python3") then
		return { cmd = "python3 -u " .. U.esc(file), cwd = dir }
	end
	if U.has("python") then
		return { cmd = "python -u " .. U.esc(file), cwd = dir }
	end
	U.notify("No Python found (python3/python)", vim.log.levels.ERROR)
	return nil
end)

function Runner.run_current(opts_override)
	local file = vim.fn.expand("%:p")
	if file == "" then
		U.notify("No file", vim.log.levels.WARN)
		return
	end

	local ft = vim.bo.filetype
	local spec = Runner.specs[ft]
	if not spec then
		U.notify("Run: unsupported filetype: " .. ft, vim.log.levels.WARN)
		return
	end

	local action = spec(file, ft)
	if not action then
		return
	end

	opts_override = opts_override or {}

	if type(action) == "string" then
		U.term(action, opts_override)
	else
		local merged = vim.tbl_extend("force", action, opts_override)
		U.term(action.cmd, merged)
	end
end

function Runner.run_server()
	Runner.run_current({ open = "tabnew" })
end

vim.api.nvim_create_user_command("RunFile", function()
	Runner.run_current()
end, {})

vim.api.nvim_create_user_command("RunServer", Runner.run_server, {})
