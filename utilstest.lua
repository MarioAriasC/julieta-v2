local utils = require("utils")
local _lexer = require("lexer")
local _parser = require("parser")
local ast = require("ast")
local tokens = require("tokens")
require("busted.runner")

local utiltests = {}

local function checkParserErrors(parser)
	local errors = _parser.getErrors(parser)
	if #errors ~= 0 then
		error(string.format("parser has %s errors:%s\n", #errors, table.concat(errors, "\n")))
	end
end

function utiltests.createProgram(input)
	local lexer = _lexer.Lexer(input)
	local parser = _parser.Parser(lexer)
	local program = _parser.parseProgram(parser)
	checkParserErrors(parser)
	return program
end

function utiltests.countStatements(expectedSize, program, assert)
	local size = #ast.program.getStatements(program)
	assert.are.same(expectedSize, size)
end

function utiltests.forEachTests(tests, parameterSize, body)
	if parameterSize == 2 then
		utils.forEach(tests, function(entry)
			body(entry[1], entry[2])
		end)
	elseif parameterSize == 3 then
		utils.forEach(tests, function(entry)
			body(entry[1], entry[2], entry[3])
		end)
	elseif parameterSize == 4 then
		utils.forEach(tests, function(entry)
			body(entry[1], entry[2], entry[3], entry[4])
		end)
	end
end

function utiltests.assertLetStatement(statement, expectedIdentifier, assert)
	assert.are.same("let", ast.getTokenLiteral(statement))
	assert.are.same(expectedIdentifier, ast.literal.getValue(ast.letStatement.getName(statement)))
	assert.are.same(expectedIdentifier, ast.getTokenLiteral(ast.letStatement.getName(statement)))
end

function utiltests.assertLiteralExpression(value, expectedValue, assert)
	print(ast.toString(value))
	local expectedType = type(expectedValue)
	if expectedType == "boolean" then
		utiltests.assertBoolean(value, expectedValue, assert)
	elseif expectedType == "number" then
		utiltests.assertIntegerLiteral(value, expectedValue, assert)
	elseif expectedType == "string" then
		utiltests.assertIdentifier(value, expectedValue, assert)
	else
		error(string.format("type of value not handled, got=%s", expectedType))
	end
end

local function assertLiteral(expression, expectedValue, assert)
	assert.are.same(expectedValue, ast.literal.getValue(expression))
	assert.are.same(tostring(expectedValue), ast.getTokenLiteral(expression))
end

utiltests.assertIntegerLiteral = assertLiteral
utiltests.assertBoolean = assertLiteral
utiltests.assertIdentifier = assertLiteral

return utiltests
