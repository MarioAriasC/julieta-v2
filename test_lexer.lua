local _lexer = require("lexer")
local ut = require("utilstest")
local tokens = require("tokens")
require("busted.runner")()
describe("A lexer", function()
	it("should produce valid tokens", function()
		local code = [[
let five = 5;
let ten = 10;

let add = fn(x, y) {
	x + y;
}

let result = add(five, ten);
!-/*5;
5 < 10 > 5;

if (5 < 10) {
	return true;
} else {
	return false;
}

10 == 10;
10 != 9;
"foobar"
"foo bar"
[1,2];
{"foo":"bar"}
        ]]
		local lexer = _lexer.Lexer(code)
		local expected = {
			{ tokens.LET, "let" },
			{ tokens.IDENT, "five" },
			{ tokens.ASSIGN, "=" },
			{ tokens.INT, "5" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.LET, "let" },
			{ tokens.IDENT, "ten" },
			{ tokens.ASSIGN, "=" },
			{ tokens.INT, "10" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.LET, "let" },
			{ tokens.IDENT, "add" },
			{ tokens.ASSIGN, "=" },
			{ tokens.FUNCTION, "fn" },
			{ tokens.LPAREN, "(" },
			{ tokens.IDENT, "x" },
			{ tokens.COMMA, "," },
			{ tokens.IDENT, "y" },
			{ tokens.RPAREN, ")" },
			{ tokens.LBRACE, "{" },
			{ tokens.IDENT, "x" },
			{ tokens.PLUS, "+" },
			{ tokens.IDENT, "y" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.RBRACE, "}" },
			{ tokens.LET, "let" },
			{ tokens.IDENT, "result" },
			{ tokens.ASSIGN, "=" },
			{ tokens.IDENT, "add" },
			{ tokens.LPAREN, "(" },
			{ tokens.IDENT, "five" },
			{ tokens.COMMA, "," },
			{ tokens.IDENT, "ten" },
			{ tokens.RPAREN, ")" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.BANG, "!" },
			{ tokens.MINUS, "-" },
			{ tokens.SLASH, "/" },
			{ tokens.ASTERISK, "*" },
			{ tokens.INT, "5" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.INT, "5" },
			{ tokens.LT, "<" },
			{ tokens.INT, "10" },
			{ tokens.GT, ">" },
			{ tokens.INT, "5" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.IF, "if" },
			{ tokens.LPAREN, "(" },
			{ tokens.INT, "5" },
			{ tokens.LT, "<" },
			{ tokens.INT, "10" },
			{ tokens.RPAREN, ")" },
			{ tokens.LBRACE, "{" },
			{ tokens.RETURN, "return" },
			{ tokens.TRUE, "true" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.RBRACE, "}" },
			{ tokens.ELSE, "else" },
			{ tokens.LBRACE, "{" },
			{ tokens.RETURN, "return" },
			{ tokens.FALSE, "false" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.RBRACE, "}" },
			{ tokens.INT, "10" },
			{ tokens.EQ, "==" },
			{ tokens.INT, "10" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.INT, "10" },
			{ tokens.NOT_EQ, "!=" },
			{ tokens.INT, "9" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.STRING, "foobar" },
			{ tokens.STRING, "foo bar" },
			{ tokens.LBRACKET, "[" },
			{ tokens.INT, "1" },
			{ tokens.COMMA, "," },
			{ tokens.INT, "2" },
			{ tokens.RBRACKET, "]" },
			{ tokens.SEMICOLON, ";" },
			{ tokens.LBRACE, "{" },
			{ tokens.STRING, "foo" },
			{ tokens.COLON, ":" },
			{ tokens.STRING, "bar" },
			{ tokens.RBRACE, "}" },
			{ tokens.EOF, "" },
		}
		ut.forEachTests(expected, 2, function(tokenType, literal)
			local token = _lexer.nextToken(lexer)
			assert.are.same(tokenType, tokens.getTokenType(token))
			assert.are.same(literal, tokens.getLiteral(token))
		end)
	end)
end)
