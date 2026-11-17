local _lexer = require("lexer")
local tokens = require("tokens")
local _parser = {}
local ast = require("ast")
local utils = require("utils")

local LOWEST = 1
local EQUALS = 2
local LESS_GREATER = 3
local SUM = 4
local PRODUCT = 5
local PREFIX = 6
local CALL = 7
local INDEX = 8

local _lex = 1
local _errors = 2
local _curToken = 3
local _peekToken = 4

local function nextToken(p)
	p[_curToken] = p[_peekToken]
	p[_peekToken] = _lexer.nextToken(p[_lex])
end

local function peekTokenIs(p, tokenType)
	return tokens.getTokenType(p[_peekToken]) == tokenType
end

local function expectPeek(p, tokenType)
	if peekTokenIs(p, tokenType) then
		nextToken(p)
		return true
	end

	peekError(p, tokenType)
	return false
end

local function curTokenIs(p, tokenType)
	return tokens.getTokenType(p[_curToken]) == tokenType
end

-- forward declaration
local parseExpression
local parseExpressionList
local parseBlockStatement

local function prefixParser(tokenType)
	if tokenType == tokens.INT then
		return function(p)
			local token = p[_curToken]
			local value = tonumber(tokens.getLiteral(token))
			if value ~= nil then
				return ast.IntegerLiteral(token, value)
			end
			table.insert(p[_errors], string.format("can not parse %s as integer", tokens.getLiteral(token)))
			return nil
		end
	elseif tokenType == tokens.TRUE or tokenType == tokens.FALSE then
		return function(p)
			return ast.BooleanLiteral(p[_curToken], curTokenIs(p, tokens.TRUE))
		end
	elseif tokenType == tokens.IDENT then
		return function(p)
			return ast.Identifier(p[_curToken], tokens.getLiteral(p[_curToken]))
		end
	elseif tokenType == tokens.BANG or tokenType == tokens.MINUS then
		return function(p)
			local token = p[_curToken]
			local operator = tokens.getLiteral(token)
			nextToken(p)
			local right = parseExpression(p, PREFIX)
			return ast.PrefixExpression(token, operator, right)
		end
	elseif tokenType == tokens.LPAREN then
		return function(p)
			nextToken(p)
			local expression = parseExpression(p, LOWEST)
			if expectPeek(p, tokens.RPAREN) then
				return expression
			end
			return nil
		end
	elseif tokenType == tokens.LBRACKET then
		return function(p)
			local token = p[_curToken]
			return ast.ArrayLiteral(token, parseExpressionList(p, tokens.RBRACKET))
		end
	elseif tokenType == tokens.IF then
		return function(p)
			local token = p[_curToken]
			if not expectPeek(p, tokens.LPAREN) then
				return nil
			end
			nextToken(p)
			local condition = parseExpression(p, LOWEST)
			if not expectPeek(p, tokens.RPAREN) then
				return nil
			end

			if not expectPeek(p, tokens.LBRACE) then
				return nil
			end

			local consequence = parseBlockStatement(p)
			local alternative
			if peekTokenIs(p, tokens.ELSE) then
				nextToken(p)
				if not expectPeek(p, tokens.LBRACE) then
					return nil
				end
				alternative = parseBlockStatement(p)
			end
			return ast.IfExpression(token, condition, consequence, alternative)
		end
	else
		return nil
	end
end

-- forward declaration
local curPrecedence

local function infixParser(tokenType)
	if
		tokenType == tokens.PLUS
		or tokenType == tokens.MINUS
		or tokenType == tokens.SLASH
		or tokenType == tokens.ASTERISK
		or tokenType == tokens.EQ
		or tokenType == tokens.NOT_EQ
		or tokenType == tokens.LT
		or tokenType == tokens.GT
	then
		return function(p, left)
			local token = p[_curToken]
			local operator = tokens.getLiteral(token)
			local precedence = curPrecedence(p)
			nextToken(p)
			local right = parseExpression(p, precedence)
			return ast.InfixExpression(token, left, operator, right)
		end
	elseif tokenType == tokens.LPAREN then
		return function(p, expression)
			local token = p[_curToken]
			local arguments = parseExpressionList(p, tokens.RPAREN)
			return ast.CallExpression(token, expression, arguments)
		end
	elseif tokenType == tokens.LBRACKET then
		return function(p, left)
			local token = p[_curToken]
			nextToken(p)
			local index = parseExpression(p, LOWEST)
			if expectPeek(p, tokens.RBRACKET) then
				return ast.IndexExpression(token, left, index)
			end
			return nil
		end
	else
		return nil
	end
end

parseExpressionList = function(p, endTokenType)
	local arguments = {}
	if peekTokenIs(p, endTokenType) then
		nextToken(p)
		return arguments
	end

	nextToken(p)
	table.insert(arguments, parseExpression(p, LOWEST))

	while peekTokenIs(p, tokens.COMMA) do
		nextToken(p)
		nextToken(p)
		table.insert(arguments, parseExpression(p, LOWEST))
	end

	if expectPeek(p, endTokenType) then
		return arguments
	end
	return nil
end

local function findPrecedence(tokenType)
	if tokenType == tokens.EQ or tokenType == tokens.NOT_EQ then
		return EQUALS
	end
	if tokenType == tokens.LT or tokenType == tokens.GT then
		return LESS_GREATER
	end
	if tokenType == tokens.PLUS or tokenType == tokens.MINUS then
		return SUM
	end
	if tokenType == tokens.ASTERISK or tokenType == tokens.SLASH then
		return PRODUCT
	end
	if tokenType == tokens.LPAREN then
		return CALL
	end
	if tokenType == tokens.LBRACKET then
		return INDEX
	end
	return LOWEST
end

curPrecedence = function(p)
	return findPrecedence(tokens.getTokenType(p[_curToken]))
end

local function peekPrecedence(p)
	return findPrecedence(tokens.getTokenType(p[_peekToken]))
end

local function prefixParserError(p, tokenType)
	table.insert(p[_errors], string.format("no prefix parser for %s token type", tokenType))
end

parseExpression = function(p, precedence)
	local prefix = prefixParser(tokens.getTokenType(p[_curToken]))
	if prefix == nil then
		prefixParserError(p, tokens.getTokenType(p[_curToken]))
		return nil
	end
	local left = prefix(p)
	while (not peekTokenIs(p, tokens.SEMICOLON)) and precedence < peekPrecedence(p) do
		local infix = infixParser(tokens.getTokenType(p[_peekToken]))
		if infix == nil then
			return left
		end
		nextToken(p)
		left = infix(p, left)
	end
	return left
end

local function parseLetStatement(p)
	local token = p[_curToken]
	if not expectPeek(p, tokens.IDENT) then
		return nil
	end

	local name = ast.Identifier(p[_curToken], tokens.getLiteral(p[_curToken]))

	if not expectPeek(p, tokens.ASSIGN) then
		return nil
	end

	nextToken(p)

	local value = parseExpression(p, LOWEST)

	if peekTokenIs(p, tokens.SEMICOLON) then
		nextToken(p)
	end

	return ast.LetStatement(token, name, value)
end

local function parseReturnStatement(p)
	local token = p[_curToken]
	nextToken(p)
	local returnValue = parseExpression(p, LOWEST)
	while peekTokenIs(p, tokens.SEMICOLON) do
		nextToken(p)
	end
	return ast.ReturnStatement(token, returnValue)
end

local function parseExpressionStatement(p)
	local token = p[_curToken]
	local expression = parseExpression(p, LOWEST)
	if peekTokenIs(p, tokens.SEMICOLON) then
		nextToken(p)
	end
	return ast.ExpressionStatement(token, expression)
end

local function parseStatement(p)
	local curTokenType = tokens.getTokenType(p[_curToken])
	if curTokenType == tokens.LET then
		return parseLetStatement(p)
	end
	if curTokenType == tokens.RETURN then
		return parseReturnStatement(p)
	end
	return parseExpressionStatement(p)
end

parseBlockStatement = function(p)
	local token = p[_curToken]
	local statements = {}
	nextToken(p)

	while (not curTokenIs(p, tokens.RBRACE)) and (not curTokenIs(p, tokens.EOF)) do
		local statement = parseStatement(p)
		if statement ~= nil then
			table.insert(statements, statement)
		end
		nextToken(p)
	end
	return ast.BlockStatement(token, statements)
end

function _parser.Parser(lexer)
	local this = { lexer, {}, nil, nil }
	nextToken(this)
	nextToken(this)
	return this
end

function _parser.parseProgram(parser)
	local statements = {}
	while tokens.getTokenType(parser[_curToken]) ~= tokens.EOF do
		local statement = parseStatement(parser)
		if statement ~= nil then
			table.insert(statements, statement)
		end
		nextToken(parser)
	end
	return ast.Program(statements)
end

function _parser.getErrors(parser)
	return parser[_errors]
end

return _parser
