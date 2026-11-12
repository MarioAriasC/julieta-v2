ILLEGAL = "ILLEGAL"
EOF = "EOF"
ASSIGN = "="
EQ = "=="
NOT_EQ = "!="
IDENT = "IDENT"
INT = "INT"
PLUS = "+"
COMMA = ","
SEMICOLON = ";"
COLON = ":"
MINUS = "-"
BANG = "!"
SLASH = "/"
ASTERISK = "*"
LT = "<"
GT = ">"
LPAREN = "("
RPAREN = ")"
LBRACE = "{"
RBRACE = "}"
LBRACKET = "["
RBRACKET = "]"
FUNCTION = "FUNCTION"
LET = "LET"
TRUE = "TRUE"
FALSE = "FALSE"
IF = "IF"
ELSE = "ELSE"
RETURN = "RETURN"
STRING = "STRING"

local function keywords(name)
	if name == "fn" then
		return FUNCTION
	end
	if name == "let" then
		return LET
	end
	if name == "true" then
		return TRUE
	end
	if name == "false" then
		return FALSE
	end
	if name == "if" then
		return IF
	end
	if name == "else" then
		return ELSE
	end
	if name == "return" then
		return RETURN
	end
	return nil
end

function LookupIdent(name)
	local reserved = keywords(name)
	if reserved == nil then
		return IDENT
	end
	return reserved
end

function Token(tokenType, literal)
	return { tokenType, literal }
end

Token_tokenType = 1
function Token_getTokenType(token)
	return token[Token_tokenType]
end
Token_literal = 2
function Token_getLiteral(token)
	return token[Token_tokenType]
end
function Token_toString(token)
	return string.format("Token(tokenType:%s, literal:'%s')", token[Token_tokenType], token[Token_literal])
end
