local _lexer = require("lexer")
local tokens = require("tokens")
local _parser = {}
local ast = require("ast")

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
	end
	return nil
end

local function infixParser(tokenType)
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

local function peekPrecedence(p)
	return findPrecedence(tokens.getTokenType(p[_peekToken]))
end

local function prefixParserError(p, tokenType)
	table.insert(p[_errors], string.format("no prefix parser for %s token type", tokenType))
end

local function parseExpression(p, precedence)
	local prefix = prefixParser(tokens.getTokenType(p[_curToken]))
	if prefix == nil then
		prefixParserError(p, tokens.getTokenType(p[_curToken]))
		return nil
	end
	local left = prefix(p)
	while not (peekTokenIs(p, tokens.SEMICOLON) and (precedence < peekPrecedence(p))) do
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
