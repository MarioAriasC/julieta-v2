local tokens = require("tokens")

local ast = {}

function ast.Program(statements)
	return { "Program", statements }
end

local _className = 1
local _token = 2

function ast.getClassName(instance)
	-- print(instance)
	return instance[_className]
end

function ast.getToken(instance)
	return instance[_token]
end

function ast.getTokenLiteral(instance)
	return tokens.getLiteral(instance[_token])
end

ast.program = {}

local _programStatements = 2
function ast.program.getStatements(program)
	return program[_programStatements]
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

function ast.toString(instance)
	local className = ast.getClassName(instance)
	if className == "IntegerLiteral" or className == "BooleanLiteral" then
		return ast.getTokenLiteral(instance)
	elseif className == "Identifier" then
		return instance[_identifier_value]
	end
	error(string.format("toString not implemented for type %s", className))
end

return ast
