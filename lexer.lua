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

local lexer = {}

function lexer.Lexer(input)
	local this = { input, 1, 1, _ZERO }
	readChar(this)
	return this
end

function lexer.nextToken(_lexer)
	local function endsWithEqual(oneChar, twoChar, duplicateChar)
		if peakChar(_lexer) ~= "=" then
			return token(_lexer, oneChar)
		end
		local currentChar = _lexer[_ch]
		readChar(_lexer)
		return tokens.Token(
			twoChar,
			utils.ternary(
				duplicateChar,
				string.format("%s%s", currentChar, currentChar),
				string.format("%s%s", currentChar, _lexer[_ch])
			)
		)
	end
	skipWhitespace(_lexer)

	local r = nil

	if _lexer[_ch] == "=" then
		r = endsWithEqual(tokens.ASSIGN, tokens.EQ, true)
	elseif _lexer[_ch] == ";" then
		r = token(_lexer, tokens.SEMICOLON)
	elseif _lexer[_ch] == ":" then
		r = token(_lexer, tokens.COLON)
	elseif _lexer[_ch] == "," then
		r = token(_lexer, tokens.COMMA)
	elseif _lexer[_ch] == "(" then
		r = token(_lexer, tokens.LPAREN)
	elseif _lexer[_ch] == ")" then
		r = token(_lexer, tokens.RPAREN)
	elseif _lexer[_ch] == "{" then
		r = token(_lexer, tokens.LBRACE)
	elseif _lexer[_ch] == "}" then
		r = token(_lexer, tokens.RBRACE)
	elseif _lexer[_ch] == "[" then
		r = token(_lexer, tokens.LBRACKET)
	elseif _lexer[_ch] == "]" then
		r = token(_lexer, tokens.RBRACKET)
	elseif _lexer[_ch] == "+" then
		r = token(_lexer, tokens.PLUS)
	elseif _lexer[_ch] == "-" then
		r = token(_lexer, tokens.MINUS)
	elseif _lexer[_ch] == "*" then
		r = token(_lexer, tokens.ASTERISK)
	elseif _lexer[_ch] == "/" then
		r = token(_lexer, tokens.SLASH)
	elseif _lexer[_ch] == ">" then
		r = token(_lexer, tokens.GT)
	elseif _lexer[_ch] == "<" then
		r = token(_lexer, tokens.LT)
	elseif _lexer[_ch] == "!" then
		r = endsWithEqual(tokens.BANG, tokens.NOT_EQ, false)
	elseif _lexer[_ch] == '"' then
		r = tokens.Token(tokens.STRING, readString(_lexer))
	elseif _lexer[_ch] == _ZERO then
		r = tokens.Token(tokens.EOF, _ZERO)
	end

	if r ~= nil then
		readChar(_lexer)
		return r
	end

	if isIdentifier(_lexer[_ch]) then
		local identifier = readIdentifer(_lexer)
		return tokens.Token(tokens.lookupIdent(identifier), identifier)
	end

	if isDigit(_lexer[_ch]) then
		return tokens.Token(tokens.INT, readNumber(_lexer))
	end

	return tokens.Token(tokens.ILLEGAL, lexer[_ch])
end

return lexer
