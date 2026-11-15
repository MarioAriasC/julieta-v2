local ut = require("utilstest")
local ast = require("ast")
require("busted.runner")()

describe("A parser", function()
	describe("should parse", function()
		it("let statements", function()
			local tests = {
				{ "let x = 5;", "x", 5 },
				{ "let y = true;", "y", true },
				{ "let foobar = y;", "foobar", "y" },
			}
			ut.forEachTests(tests, 3, function(input, expectedIdentifier, expectedValue)
				local program = ut.createProgram(input)
				ut.countStatements(1, program, assert)
				local statement = ast.program.getStatements(program)[1]
				ut.assertLetStatement(statement, expectedIdentifier, assert)
				local value = ast.letStatement.getValue(statement)
				ut.assertLiteralExpression(value, expectedValue, assert)
			end)
		end)
		it("return statements", function()
			local tests = {
				{ "return 5;", 5 },
				{ "return true;", true },
				{ "return foobar;", "foobar" },
			}
			ut.forEachTests(tests, 2, function(input, expectedIdentifier)
				local program = ut.createProgram(input)
				ut.countStatements(1, program, assert)
				local statement = ast.program.getStatements(program)[1]
				assert.are.same("return", ast.getTokenLiteral(statement))
				ut.assertLiteralExpression(ast.returnStatement.getReturnValue(statement), expectedIdentifier, assert)
			end)
		end)
		it("identifier expression", function()
			local input = "foobar;"
			local program = ut.createProgram(input)
			ut.countStatements(1, program, assert)
			local statement = ast.program.getStatements(program)[1]
			local identifier = ast.expressionStatement.getExpression(statement)
			assert.are.same("foobar", ast.identifier.getValue(identifier))
			assert.are.same("foobar", ast.getTokenLiteral(identifier))
		end)
	end)
end)
