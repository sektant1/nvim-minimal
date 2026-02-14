---@diagnostic disable: undefined-global

local ls = require("luasnip")
local s = ls.snippet

local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local function filename_base()
	return vim.fn.expand("%:t:r")
end

local function upper_guard()
	local name = vim.fn.expand("%:t")
	name = name:gsub("%.", "_"):gsub("%W", "_"):upper()
	return name .. "_"
end

local function namespace_from_path()
	-- very lightweight heuristic: parent folder name
	local dir = vim.fn.expand("%:p:h:t")
	dir = dir:gsub("%W", "_")
	return dir
end

local snippets = {
	-- Basic includes
	s("inc", fmt([[#include <{}>]], { i(1, "vector") })),
	s("incc", fmt([[#include "{}"]], { i(1, filename_base() .. ".h") })),

	-- iostream + main
	s(
		"main",
		fmt(
			[[
#include <iostream>

int main(int argc, char** argv) {{
  {}
  return 0;
}}
]],
			{ i(1, 'std::cout << "Hello" << std::endl;') }
		)
	),

	-- Competitive-style fast IO
	s(
		"fastio",
		fmt(
			[[
std::ios::sync_with_stdio(false);
std::cin.tie(nullptr);
{}
]],
			{ i(1) }
		)
	),

	-- namespace
	s(
		"ns",
		fmt(
			[[
namespace {} {{
{}
}} // namespace {}
]],
			{ i(1, namespace_from_path()), i(2), rep(1) }
		)
	),

	-- using declarations
	s("us", fmt([[using {} = {};]], { i(1, "ll"), i(2, "long long") })),
	s("using", fmt([[using {};]], { i(1, "std::string") })),

	-- Header guard / pragma once
	s(
		"pragma",
		fmt(
			[[
#pragma once
{}
]],
			{ i(1) }
		)
	),

	s(
		"guard",
		fmt(
			[[
#ifndef {}
#define {}

{}

#endif // {}
]],
			{
				f(upper_guard, {}),
				f(upper_guard, {}),
				i(1),
				f(upper_guard, {}),
			}
		)
	),

	-- Class / struct
	s(
		"class",
		fmt(
			[[
class {} {{
public:
  {}();
  ~{}();

  {}(const {}&) = delete;
  {}& operator=(const {}&) = delete;

private:
  {}
}};
]],
			{
				i(1, "Foo"),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				i(2, "// members"),
			}
		)
	),

	s(
		"struct",
		fmt(
			[[
struct {} {{
  {};
}};
]],
			{ i(1, "Foo"), i(2, "int x = 0") }
		)
	),

	-- Rule of 5 skeleton
	s(
		"rule5",
		fmt(
			[[
class {} {{
public:
  {}() = default;
  ~{}() = default;

  {}(const {}&) = default;
  {}& operator=(const {}&) = default;

  {}({}&&) noexcept = default;
  {}& operator=({}&&) noexcept = default;

private:
  {}
}};
]],
			{
				i(1, "Foo"),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				rep(1),
				i(2, "// members"),
			}
		)
	),

	-- Function
	s(
		"fn",
		fmt(
			[[
{} {}({}) {{
  {}
}}
]],
			{ i(1, "void"), i(2, "func"), i(3), i(4) }
		)
	),

	-- Template function
	s(
		"tfn",
		fmt(
			[[
template <typename {}>
{} {}({}) {{
  {}
}}
]],
			{ i(1, "T"), i(2, "T"), i(3, "func"), i(4), i(5) }
		)
	),

	-- Lambda
	s("lam", fmt([[auto {} = [{}]({}) {{ {} }};]], { i(1, "fn"), i(2, "&"), i(3), i(4) })),

	-- if / else / switch
	s(
		"if",
		fmt(
			[[
if ({}) {{
  {}
}}
]],
			{ i(1, "cond"), i(2) }
		)
	),

	s(
		"ife",
		fmt(
			[[
if ({}) {{
  {}
}} else {{
  {}
}}
]],
			{ i(1, "cond"), i(2), i(3) }
		)
	),

	s(
		"sw",
		fmt(
			[[
switch ({}) {{
  case {}: {{
    {}
    break;
  }}
  default: {{
    {}
    break;
  }}
}}
]],
			{ i(1, "x"), i(2, "0"), i(3), i(4) }
		)
	),

	-- Loops
	s(
		"fori",
		fmt(
			[[
for (int {} = 0; {} < {}; ++{}) {{
  {}
}}
]],
			{ i(1, "i"), rep(1), i(2, "n"), rep(1), i(3) }
		)
	),

	s(
		"forr",
		fmt(
			[[
for (auto& {} : {}) {{
  {}
}}
]],
			{ i(1, "x"), i(2, "container"), i(3) }
		)
	),

	-- STL containers quick
	s("vec", fmt([[std::vector<{}> {}{};]], { i(1, "int"), i(2, "v"), c(3, { t(""), fmt("({})", { i(1, "n") }) }) })),
	s("umap", fmt([[std::unordered_map<{}, {}> {};]], { i(1, "int"), i(2, "int"), i(3, "m") })),
	s("map", fmt([[std::map<{}, {}> {};]], { i(1, "int"), i(2, "int"), i(3, "m") })),
	s("opt", fmt([[std::optional<{}> {};]], { i(1, "T"), i(2, "val") })),
	s("var", fmt([[std::variant<{}> {};]], { i(1, "A, B"), i(2, "v") })),

	-- Smart pointers
	s("up", fmt([[auto {} = std::make_unique<{}>({});]], { i(1, "p"), i(2, "T"), i(3) })),
	s("sp", fmt([[auto {} = std::make_shared<{}>({});]], { i(1, "p"), i(2, "T"), i(3) })),

	-- std::visit helper
	s(
		"visit",
		fmt(
			[[
std::visit([&](auto&& {}) {{
  using T = std::decay_t<decltype({})>;
  {}
}}, {});
]],
			{ i(1, "x"), rep(1), i(2, "// handle T"), i(3, "v") }
		)
	),

	-- Logging / debug
	s("cout", fmt([[std::cout << {} << std::endl;]], { i(1, '""') })),
	s("cerr", fmt([[std::cerr << {} << std::endl;]], { i(1, '""') })),

	s(
		"dbg",
		fmt([[std::cerr << "[{}:{}] {}=" << ({}) << '\n';]], {
			f(function()
				return vim.fn.expand("%:t")
			end, {}),
			f(function()
				return tostring(vim.fn.line("."))
			end, {}),
			i(1, "x"),
			rep(1),
		})
	),

	-- chrono timer block
	s(
		"timer",
		fmt(
			[[
const auto {}_t0 = std::chrono::steady_clock::now();
{}
const auto {}_t1 = std::chrono::steady_clock::now();
std::cerr << "{} took "
          << std::chrono::duration_cast<std::chrono::microseconds>({}_t1 - {}_t0).count()
          << "us\n";
]],
			{
				i(1, "scope"),
				i(2, "// work"),
				rep(1), -- {}_t1 (declaration)
				rep(1), -- label "{} took"
				rep(1), -- {}_t1 (duration)
				rep(1), -- {}_t0 (duration)
			}
		)
	),
	-- GoogleTest skeleton
	s(
		"gtest",
		fmt(
			[[
#include <gtest/gtest.h>

TEST({}, {}) {{
  {}
}}
]],
			{ i(1, "Suite"), i(2, "Name"), i(3) }
		)
	),
}

local autosnippets = {
	-- Optional: tiny autosnippet (kept minimal to avoid surprise expansions)
	-- s({ trig = "->", wordTrig = false }, t("->")),
}

return snippets, autosnippets
