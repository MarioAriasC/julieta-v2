local tokens = require("tokens")
local cjson = require("cjson")
local utils = require("utils")
local ast = {}

function ast.Program(statements)
	return { "Program", statements }
end

local _className = 1

ast.className = _className

local _token = 2

ast.token = _token

local _program_statements = 2

ast.programStatements = _program_statements

local _identifier_value = 3

function ast.Identifier(token, value)
	return { "Identifier", token, value }
end

ast.identifierValue = _identifier_value

function ast.IntegerLiteral(token, value)
	return { "IntegerLiteral", token, value }
end

local _literal_value = 3
ast.literalValue = _literal_value

function ast.BooleanLiteral(token, value)
	return { "BooleanLiteral", token, value }
end

local _let_statement_name = 3
local _let_statement_value = 4
ast.letStatementName = _let_statement_name
ast.letStatementValue = _let_statement_value

function ast.LetStatement(token, name, value)
	return { "LetStatement", token, name, value }
end

function ast.ReturnStatement(token, returnValue)
	return { "ReturnStatement", token, returnValue }
end

local _retrun_statement_value = 3
ast.returnStatementValue = _retrun_statement_value

function ast.ExpressionStatement(token, expression)
	return { "ExpressionStatement", token, expression }
end

local _expression = 3
ast.expressionStatementExpression = _expression

function ast.PrefixExpression(token, operator, right)
	return { "PrefixExpression", token, operator, right }
end

local _prefix_operator = 3
local _prefix_right = 4

ast.prefixExpressionOperator = _prefix_operator
ast.prefixExpressionRight = _prefix_right

function ast.InfixExpression(token, left, operator, right)
	return { "InfixExpression", token, left, operator, right }
end

local _infix_left = 3
local _infix_operator = 4
local _infix_right = 5

ast.infixExpressionLeft = _infix_left
ast.infixExpressionOperator = _infix_operator
ast.infixExpressionRight = _infix_right

function ast.CallExpression(token, expression, arguments)
	return { "CallExpression", token, expression, arguments }
end

local _call_expression = 3
local _call_arguments = 4

ast.callExpressionExpression = _call_expression
ast.callExpressionArguments = _call_arguments

function ast.ArrayLiteral(token, elements)
	return { "ArrayLiteral", token, elements }
end

local _array_elements = 3
ast.arrayLiteralElements = _array_elements

function ast.IndexExpression(token, left, index)
	return { "IndexExpression", token, left, index }
end

local _index_left = 3
local _index_index = 4

ast.indexExpessionLeft = _index_left
ast.indexExpessionIndex = _index_index

function ast.BlockStatement(token, statements)
	return { "BlockStatement", token, statements }
end

local _block_statements = 3

ast.blokStatementStatements = _block_statements

function ast.IfExpression(token, condition, consequence, alternative)
	return { "IfExpression", token, condition, consequence, alternative }
end

local _if_condition = 3
local _if_consequence = 4
local _if_alternative = 5

ast.ifExpressionCondition = _if_condition
ast.ifExpressionConsequence = _if_consequence
ast.ifExpressionAlternative = _if_alternative

function ast.FunctionLiteral(token, parameters, body)
	return { "FunctionLiteral", token, parameters, body }
end

local _function_parameters = 3
local _function_body = 4

ast.functionLiteralParameters = _function_parameters
ast.functionLiteralBody = _function_body

function ast.toString(instance)
	-- print(cjson.encode(instance))
	local className = instance[_className]
	if className == "IntegerLiteral" or className == "BooleanLiteral" then
		return instance[_token][tokens.literal]
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
