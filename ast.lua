local tokens = require("tokens")
local cjson = require("cjson")
local utils = require("utils")
local ast = {}

function ast.Program(statements)
	return { "Program", statements }
end

local _className = 1
local _token = 2

function ast.getClassName(instance)
	-- print(cjson.encode(instance))
	return instance[_className]
end

function ast.getToken(instance)
	return instance[_token]
end

function ast.getTokenLiteral(instance)
	return instance[_token][tokens.literal]
end

ast.program = {}

local _program_statements = 2
function ast.program.getStatements(program)
	return program[_program_statements]
end

local _identifier_value = 3

function ast.Identifier(token, value)
	return { "Identifier", token, value }
end

ast.identifier = {}

function ast.identifier.getValue(identifier)
	return identifier[_identifier_value]
end

local _literal_value = 3
function ast.IntegerLiteral(token, value)
	return { "IntegerLiteral", token, value }
end

ast.literal = {}

function ast.literal.getValue(literal)
	return literal[_literal_value]
end

function ast.BooleanLiteral(token, value)
	return { "BooleanLiteral", token, value }
end

local _let_statement_name = 3
local _let_statement_value = 4

function ast.LetStatement(token, name, value)
	return { "LetStatement", token, name, value }
end

ast.letStatement = {}

function ast.letStatement.getName(letStatement)
	return letStatement[_let_statement_name]
end

function ast.letStatement.getValue(letStatement)
	return letStatement[_let_statement_value]
end

function ast.ReturnStatement(token, returnValue)
	return { "ReturnStatement", token, returnValue }
end

ast.returnStatement = {}

local _retrun_statement_value = 3
function ast.returnStatement.getReturnValue(returnStatement)
	return returnStatement[_retrun_statement_value]
end

function ast.ExpressionStatement(token, expression)
	return { "ExpressionStatement", token, expression }
end

ast.expressionStatement = {}

local _expression = 3
function ast.expressionStatement.getExpression(expressionStatement)
	return expressionStatement[_expression]
end

function ast.PrefixExpression(token, operator, right)
	return { "PrefixExpression", token, operator, right }
end

ast.prefixExpression = {}
local _prefix_operator = 3
local _prefix_right = 4

function ast.prefixExpression.getOperator(prefixExpression)
	return prefixExpression[_prefix_operator]
end

function ast.prefixExpression.getRight(prefixExpression)
	return prefixExpression[_prefix_right]
end

function ast.InfixExpression(token, left, operator, right)
	return { "InfixExpression", token, left, operator, right }
end

ast.infixExpression = {}

local _infix_left = 3
local _infix_operator = 4
local _infix_right = 5

function ast.infixExpression.getLeft(infixExpression)
	return infixExpression[_infix_left]
end

function ast.infixExpression.getOperator(infixExpression)
	return infixExpression[_infix_operator]
end

function ast.infixExpression.getRight(infixExpression)
	return infixExpression[_infix_right]
end

function ast.CallExpression(token, expression, arguments)
	return { "CallExpression", token, expression, arguments }
end

ast.callExpression = {}

local _call_expression = 3
local _call_arguments = 4

function ast.ArrayLiteral(token, elements)
	return { "ArrayLiteral", token, elements }
end

ast.arrayLiteral = {}

local _array_elements = 3

function ast.IndexExpression(token, left, index)
	return { "IndexExpression", token, left, index }
end

ast.indexExpression = {}
local _index_left = 3
local _index_index = 4

function ast.BlockStatement(token, statements)
	return { "BlockStatement", token, statements }
end

ast.blockStatement = {}

local _block_statements = 3

function ast.blockStatement.getStatements(blockStatement)
	return blockStatement[_block_statements]
end

function ast.IfExpression(token, condition, consequence, alternative)
	return { "IfExpression", token, condition, consequence, alternative }
end

ast.ifExpression = {}

local _if_condition = 3
local _if_consequence = 4
local _if_alternative = 5

function ast.ifExpression.getCondition(ifExpression)
	return ifExpression[_if_condition]
end

function ast.ifExpression.getConsequence(ifExpression)
	return ifExpression[_if_consequence]
end
function ast.ifExpression.getAlternative(ifExpression)
	return ifExpression[_if_alternative]
end

function ast.toString(instance)
	-- print(cjson.encode(instance))
	local className = ast.getClassName(instance)
	if className == "IntegerLiteral" or className == "BooleanLiteral" then
		return ast.getTokenLiteral(instance)
	elseif className == "Identifier" then
		return instance[_identifier_value]
	elseif className == "ExpressionStatement" then
		return ast.toString(instance[_expression])
	elseif className == "PrefixExpression" then
		return string.format("(%s%s)", instance[_prefix_operator], ast.toString(instance[_prefix_right]))
	elseif className == "Program" then
		return table.concat(utils.map(instance[_program_statements], ast.toString), "")
	elseif className == "InfixExpression" then
		return string.format(
			"(%s %s %s)",
			ast.toString(instance[_infix_left]),
			instance[_infix_operator],
			ast.toString(instance[_infix_right])
		)
	elseif className == "CallExpression" then
		return string.format(
			"%s(%s)",
			ast.toString(instance[_call_expression]),
			table.concat(utils.map(instance[_call_arguments], ast.toString), ", ")
		)
	elseif className == "ArrayLiteral" then
		return string.format("[%s]", table.concat(utils.map(instance[_array_elements], ast.toString), ", "))
	elseif className == "IndexExpression" then
		return string.format("(%s[%s])", ast.toString(instance[_index_left]), ast.toString(instance[_index_index]))
	else
		error(string.format("toString not implemented for type %s", className))
	end
end

return ast
