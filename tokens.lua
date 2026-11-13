local tokens = {}

tokens.ILLEGAL = "ILLEGAL"
tokens.EOF = "EOF"
tokens.ASSIGN = "="
tokens.EQ = "=="
tokens.NOT_EQ = "!="
tokens.IDENT = "IDENT"
tokens.INT = "INT"
tokens.PLUS = "+"
tokens.COMMA = ","
tokens.SEMICOLON = ";"
tokens.COLON = ":"
tokens.MINUS = "-"
tokens.BANG = "!"
tokens.SLASH = "/"
tokens.ASTERISK = "*"
tokens.LT = "<"
tokens.GT = ">"
tokens.LPAREN = "("
tokens.RPAREN = ")"
tokens.LBRACE = "{"
tokens.RBRACE = "}"
tokens.LBRACKET = "["
tokens.RBRACKET = "]"
tokens.FUNCTION = "FUNCTION"
tokens.LET = "LET"
tokens.TRUE = "TRUE"
tokens.FALSE = "FALSE"
tokens.IF = "IF"
tokens.ELSE = "ELSE"
tokens.RETURN = "RETURN"
tokens.STRING = "STRING"

local function keywords(name)
	if name == "fn" then
		return tokens.FUNCTION
	end
	if name == "let" then
		return tokens.LET
	end
	if name == "true" then
		return tokens.TRUE
	end
	if name == "false" then
		return tokens.FALSE
	end
	if name == "if" then
		return tokens.IF
	end
	if name == "else" then
		return tokens.ELSE
	end
	if name == "return" then
		return tokens.RETURN
	end
	return nil
end

function tokens.lookupIdent(name)
	local reserved = keywords(name)
	if reserved == nil then
		return tokens.IDENT
	end
	return reserved
end

function tokens.Token(tokenType, literal)
	return { tokenType, literal }
end

local _tokenType = 1
function tokens.getTokenType(token)
	return token[_tokenType]
end

local _literal = 2
function tokens.getLiteral(token)
	return token[_literal]
end

function tokens.toString(token)
	return string.format("Token(tokenType:%s, literal:'%s')", token[_tokenType], token[_literal])
end

return tokens
