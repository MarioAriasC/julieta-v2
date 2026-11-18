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
	local size = #program[ast.programStatements]
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
	assert.are.same("let", statement[ast.token][tokens.literal])
	assert.are.same(expectedIdentifier, statement[ast.letStatementName][ast.literalValue])
	assert.are.same(expectedIdentifier, statement[ast.letStatementName][ast.token][tokens.literal])
end

function utiltests.assertLiteralExpression(value, expectedValue, assert)
	-- print(ast.toString(value))
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
	assert.are.same(expectedValue, expression[ast.literalValue])
	assert.are.same(tostring(expectedValue), expression[ast.token][tokens.literal])
end

utiltests.assertIntegerLiteral = assertLiteral
utiltests.assertBoolean = assertLiteral
utiltests.assertIdentifier = assertLiteral

function utiltests.assertInfixExpression(expression, leftValue, operator, rightValue, assert)
	utiltests.assertLiteralExpression(expression[ast.infixExpressionLeft], leftValue, assert)
	assert.are.same(operator, expression[ast.infixExpressionOperator])
	utiltests.assertLiteralExpression(expression[ast.infixExpressionRight], rightValue, assert)
end

function utiltests.getExpression(program)
	return program[ast.programStatements][1][ast.expressionStatementExpression]
end

return utiltests
