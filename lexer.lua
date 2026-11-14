local tokens = require("tokens")
local utils = require("utils")

local function isIdentifier(char)
	if string.match(char, "%a") or char == "_" then
		return true
	end
	return false
end

local function isDigit(char)
	if tonumber(char) ~= nil then
		return true
	end
	return false
end

local _ZERO = ""

local _input = 1
local _position = 2
local _readPosition = 3
local _ch = 4

local function peakChar(l)
	if l[_readPosition] > #l[_input] then
		return _ZERO
	end
	return string.sub(l[_input], l[_readPosition], l[_readPosition])
end

local function readChar(l)
	l[_ch] = peakChar(l)
	l[_position] = l[_readPosition]
	l[_readPosition] = l[_readPosition] + 1
end

local function skipWhitespace(l)
	local function isWhiteSpace(char)
		if char == " " or char == "\n" or char == "\t" or char == "\r" then
			return true
		end
		return false
	end

	while isWhiteSpace(l[_ch]) do
		readChar(l)
	end
end

local function token(l, tokenType)
	return tokens.Token(tokenType, l[_ch])
end

local function readValue(l, predicate)
	local currentPosition = l[_position]
	while predicate(l[_ch]) do
		readChar(l)
	end
	return string.sub(l[_input], currentPosition, (l[_position] - 1))
end

local function readIdentifer(l)
	return readValue(l, isIdentifier)
end

local function readNumber(l)
	return readValue(l, isDigit)
end

local function readString(l)
	local start = l[_position] + 1
	while true do
		readChar(l)
		if l[_ch] == '"' or l[_ch] == _ZERO then
			break
		end
	end
	return string.sub(l[_input], start, (l[_position] - 1))
end

local _lexer = {}

function _lexer.Lexer(input)
	local this = { input, 1, 1, _ZERO }
	readChar(this)
	return this
end

function _lexer.nextToken(lexer)
	local function endsWithEqual(oneChar, twoChar, duplicateChar)
		if peakChar(lexer) ~= "=" then
			return token(lexer, oneChar)
		end
		local currentChar = lexer[_ch]
		readChar(lexer)
		return tokens.Token(
			twoChar,
			utils.ternary(
				duplicateChar,
				string.format("%s%s", currentChar, currentChar),
				string.format("%s%s", currentChar, lexer[_ch])
			)
		)
	end
	skipWhitespace(lexer)

	local r = nil

	if lexer[_ch] == "=" then
		r = endsWithEqual(tokens.ASSIGN, tokens.EQ, true)
	elseif lexer[_ch] == ";" then
		r = token(lexer, tokens.SEMICOLON)
	elseif lexer[_ch] == ":" then
		r = token(lexer, tokens.COLON)
	elseif lexer[_ch] == "," then
		r = token(lexer, tokens.COMMA)
	elseif lexer[_ch] == "(" then
		r = token(lexer, tokens.LPAREN)
	elseif lexer[_ch] == ")" then
		r = token(lexer, tokens.RPAREN)
	elseif lexer[_ch] == "{" then
		r = token(lexer, tokens.LBRACE)
	elseif lexer[_ch] == "}" then
		r = token(lexer, tokens.RBRACE)
	elseif lexer[_ch] == "[" then
		r = token(lexer, tokens.LBRACKET)
	elseif lexer[_ch] == "]" then
		r = token(lexer, tokens.RBRACKET)
	elseif lexer[_ch] == "+" then
		r = token(lexer, tokens.PLUS)
	elseif lexer[_ch] == "-" then
		r = token(lexer, tokens.MINUS)
	elseif lexer[_ch] == "*" then
		r = token(lexer, tokens.ASTERISK)
	elseif lexer[_ch] == "/" then
		r = token(lexer, tokens.SLASH)
	elseif lexer[_ch] == ">" then
		r = token(lexer, tokens.GT)
	elseif lexer[_ch] == "<" then
		r = token(lexer, tokens.LT)
	elseif lexer[_ch] == "!" then
		r = endsWithEqual(tokens.BANG, tokens.NOT_EQ, false)
	elseif lexer[_ch] == '"' then
		r = tokens.Token(tokens.STRING, readString(lexer))
	elseif lexer[_ch] == _ZERO then
		r = tokens.Token(tokens.EOF, _ZERO)
	end

	if r ~= nil then
		readChar(lexer)
		return r
	end

	if isIdentifier(lexer[_ch]) then
		local identifier = readIdentifer(lexer)
		return tokens.Token(tokens.lookupIdent(identifier), identifier)
	end

	if isDigit(lexer[_ch]) then
		return tokens.Token(tokens.INT, readNumber(lexer))
	end

	return tokens.Token(tokens.ILLEGAL, lexer[_ch])
end

return _lexer
